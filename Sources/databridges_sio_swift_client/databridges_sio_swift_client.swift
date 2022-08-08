
//
//        DataBridges Swift client Library targeting iOS
//        https://www.databridges.io/
//
//
//
//        Copyright 2022 Optomate Technologies Private Limited.
//
//        Licensed under the Apache License, Version 2.0 (the "License");
//        you may not use this file except in compliance with the License.
//        You may obtain a copy of the License at
//
//            http://www.apache.org/licenses/LICENSE-2.0
//
//        Unless required by applicable law or agreed to in writing, software
//        distributed under the License is distributed on an "AS IS" BASIS,
//        WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//        See the License for the specific language governing permissions and
//        limitations under the License.
//

import Foundation

import SocketIO

public class databridges_sio_swift_client{
    
    public var appkey:String?
    private  var ClientSocket:SocketIOClient?
    private  var  options:SocketIOClientOption?
    private var  socketManage: SocketManager?
    public var auth_url:String?
    public var connectionstate:ConnectionState?
    public var channel: Channels?
    public var sessionid:String?
    private var count:Int?

    public var maxReconnectionDelay:UInt
    public var minReconnectionDelay:UInt
    public var reconnectionDelayGrowFactor:Double
    public var minUptime:UInt
    public var connectionTimeout:UInt
    public var maxReconnectionRetries:UInt
    private var uptimeTimeout:UInt
    private var retryCount:UInt
    public var autoReconnect:Bool
    private var lifeCycle:UInt
    private var isServerReconnect:Bool
    private let  dispatch:EventDispatcher
    public var cf: ClientFunctions?
    public var rpc:Rpc?

    
    public init()
    {
        self.ClientSocket = nil
        self.sessionid = ""
         
        
        self.options = nil

        
        self.maxReconnectionRetries = 10;
        self.maxReconnectionDelay = 120000;
        self.minReconnectionDelay = 1000 + UInt.random(in: 0..<1)  * 4000;
        self.reconnectionDelayGrowFactor = 1.3;
        self.minUptime = 500 ;
        self.connectionTimeout = 10000;
        self.autoReconnect = true;
        
        
        self.uptimeTimeout = 0
        self.retryCount = 0
        self.lifeCycle = 0
        self.isServerReconnect = false

        self.appkey = ""

        self.dispatch = EventDispatcher()
        self.connectionstate = ConnectionState(self)
        self.channel = Channels(self)
        self.cf =  ClientFunctions(self)
        self.rpc =  Rpc(self)
    }
    
    
    
    public func access_token(_ callback: @escaping dBAccessToken) throws
    {
       
     if (!self.dispatch.isEventExists("dbridges:access_token")){
        try? self.dispatch.bind("dbridges:access_token", callback)
      }else{
          throw dBError("E004")
      }
    }


    public func accesstoken_dispatcher(_ channelName: String, _ action: String, _ response:Any) throws
    {
          if (self.dispatch.isEventExists("dbridges:access_token")){
            self.dispatch.emit2("dbridges:access_token" , channelName ,  self.sessionid ?? "" , action ,  response )
              }else{
                throw  dBError("E004")
              }
    }
    


    public func GetDBRInfo( _ url:String, _ apikey:String)->APIResponce
    {
        let m_apiresponce:APIResponce =  APIResponce()
        
        guard let serviceUrl = URL(string: url) else { return m_apiresponce}
      
        var request = URLRequest(url: serviceUrl)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(apikey, forHTTPHeaderField: "x-api-key")
        request.addValue("sio", forHTTPHeaderField: "lib-transport")
        request.httpBody = Data("{}".utf8)
        
        
        
        let session = URLSession.shared
        
       let sem = DispatchSemaphore.init(value: 0)

        let task = session.dataTask(with: request) { data, response, error in
            defer { sem.signal() }
            if let error = error {
             
                m_apiresponce.update(0 , error.localizedDescription )
              return
            }
            
            guard let httpResponse = response as? HTTPURLResponse,
                  (200...299).contains(httpResponse.statusCode)
            else {
                let htr = response! as? HTTPURLResponse
                m_apiresponce.update(htr!.statusCode ,  String(htr!.statusCode))
              
              return
            }
      
            guard let responseData = data else {
              
            m_apiresponce.update(httpResponse.statusCode ,  "nil Data received from the server")
              return
            }
            
            do {
              if let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: .mutableContainers) as? [String: Any] {
                m_apiresponce.update(jsonResponse)
              } else {
                throw URLError(.badServerResponse)
              }
            } catch _ {
              
            }
          }
          
        task.resume()
        sem.wait()
        
        return m_apiresponce
        }
    
    
    
    public func shouldRestart(_ ekey: Any)
    {
        if (self.autoReconnect)
        {
            if (!(self.connectionstate?.get_newLifeCycle() ?? false)){
            
                if (ekey is String){
                    self.connectionstate?.handledispatcher(States.RECONNECT_ERROR, dBError(ekey as! String))
                }else{
                     self.connectionstate?.handledispatcher(States.RECONNECT_ERROR, ekey)
                        self.reconnect();
                }
            }else{
                if (ekey is String){
                     self.connectionstate?.handledispatcher(States.ERROR, dBError(ekey as! String))
                }else{
                     self.connectionstate?.handledispatcher(States.ERROR, ekey)
                }
            }
        }
    }

    
    func getNextDelay() -> UInt
    {
        var delay:UInt = 0;
       if (self.retryCount > 0) {
        let in_delay = pow(Double(self.reconnectionDelayGrowFactor), Double(self.retryCount - 1) )
           delay =  UInt(self.minReconnectionDelay) * UInt(in_delay)
        
        if(delay > self.maxReconnectionDelay)
        {
            delay =  self.maxReconnectionDelay
        }
        if (delay < self.minReconnectionDelay){
            delay =  self.minReconnectionDelay
        }
       }
       return delay;
   }

    
    
    
    
    func reconnect()
    {
        if (self.retryCount >= self.maxReconnectionRetries) {
       
        self.connectionstate?.handledispatcher(States.RECONNECT_FAILED, dBError("E060"))
        self.connectionstate?.handledispatcher(States.DISCONNECTED, "")
          self.channel?.cleanUp_All()
          self.rpc?.cleanUp_All()
          self.connectionstate?.state("")
          self.lifeCycle =  0;
          self.retryCount = 0;
          self.connectionstate?.set_newLifeCycle(true);
            
        return
        }else{
            self.retryCount = self.retryCount + 1;
            let delay = self.getNextDelay()
            DispatchQueue.main.asyncAfter(deadline: DispatchTime(uptimeNanoseconds: UInt64(delay)), execute: {
                self.connectionstate?.reconnect_attempt =  Int(self.retryCount)
                self.connectionstate?.handledispatcher(States.RECONNECTING, self.retryCount)
                do{
                    try self.connect()
                }catch _{
                }
            })
        }
   }

    
    public func connect() throws {
        
        if(self.retryCount == 0  && (!(self.connectionstate?.get_newLifeCycle())!)){
            self.connectionstate?.set_newLifeCycle(true)
        }
        
        
        if((self.auth_url!.isEmpty)){
            if((self.connectionstate?.get_newLifeCycle()) != nil) {
                throw dBError("E001")
                
            }
            self.shouldRestart("E001")
            return
        }
      
        
        if((self.appkey!.isEmpty)){
            if((self.connectionstate?.get_newLifeCycle()) != nil) {
                throw dBError("E002")
                
            }
            self.shouldRestart("E002")
            return
        }
       
       
    
    do
      {
        let _ = try self.cf?._verify_function();
      }
      catch let dberror
      {

        if (self.connectionstate?.get_newLifeCycle() != nil) { throw dberror }
          self.shouldRestart(dberror)
          return
      }
        
    
        let result:APIResponce = self.GetDBRInfo(self.auth_url ?? "", self.appkey ?? "")
      
        
        if(result.statuscode != 200){
            let dberror:dBError = dBError("E006", String(result.statuscode), result.reasonphrase)
            if ((self.connectionstate?.get_newLifeCycle()) != nil){ throw dberror }
            self.shouldRestart(dberror);
            return;
        }
        
        var uri:String  = ""
        if(result.secured) {
            uri =  "https://"
            
        }
        else{
            uri =  "http://"
        }
        
        uri = uri + result.wsip + ":" + result.wsport
        let cfvalue = true ? 1 : 0
       
        self.socketManage = SocketManager(socketURL: URL(string: uri)!, config: [
            .log(false),
            .forceWebsockets(true),
            .compress,
            .secure(true),
            .reconnects(false),
            .connectParams(["EIO": "3",
                            "sessionkey" :  result.sessionkey,
                           "version": "1.1" ,
                           "libtype": "swift",
                           "cf" : String(cfvalue)])
            
            
        
        ])
        
        self.ClientSocket = self.socketManage?.defaultSocket
        
        self.ClientSocket?.on(clientEvent: .disconnect,callback: { (data, ack)  in
            self.IOReconnect(data[0] as! String)
            
        })
        
        self.ClientSocket?.on("db", callback: { (data_array: [Any], ack:SocketAckEmitter) in
            do{
               
                let dbmessage = MessageStructure()
                dbmessage.Parse(data_array)
                    self.IOMessage(dbmessage)
              
            }catch let error{
               
            }
        })
        
        if (self.lifeCycle == 0) {
            self.connectionstate?.handledispatcher(States.CONNECTING, nil);
        }
        
        
        self.ClientSocket?.connect()
    }
    
    
    public func disconnect()
    {
        self.ClientSocket?.disconnect()
    }

    internal func IOReconnect(_ reason:String)
    {
        self.channel?._send_OfflineEvents()
        self.rpc?._send_OfflineEvents()
        switch reason {
        case  "io server disconnect":
            self.connectionstate?.handledispatcher(States.ERROR,  dBError("E061"))
            if (self.ClientSocket != nil)  {
                self.ClientSocket?.removeAllHandlers()
                
            }
            if(!self.autoReconnect){
                  self.connectionstate?.handledispatcher(States.DISCONNECTED, "")
                self.channel?.cleanUp_All()
                self.rpc?.cleanUp_All()
                self.connectionstate?.state("")
                self.lifeCycle =  0;
                self.retryCount = 0;
                self.connectionstate?.set_newLifeCycle(true);
            }else{
                self.reconnect()
            }
            
            break
        case "io client disconnect":
            self.connectionstate?.handledispatcher(States.CONNECTION_BREAK, dBError("E062"));
            if (self.isServerReconnect) {
                if (self.ClientSocket != nil)  {
                    self.ClientSocket?.removeAllHandlers()
                    
                }
                if(!self.autoReconnect){
                    self.connectionstate?.handledispatcher(States.DISCONNECTED, "")
                    self.channel?.cleanUp_All()
                    self.rpc?.cleanUp_All()
                    self.connectionstate?.state("")
                    self.lifeCycle =  0;
                    self.retryCount = 0;
                    self.connectionstate?.set_newLifeCycle(true);
                }else{
                    self.reconnect()
                }
            }else{
                if (self.ClientSocket != nil)  {
                    self.ClientSocket?.removeAllHandlers()
                }
                
                self.connectionstate?.handledispatcher(States.DISCONNECTED, "")
              self.channel?.cleanUp_All()
              self.rpc?.cleanUp_All()
              self.connectionstate?.state("")
              self.lifeCycle =  0;
              self.retryCount = 0;
              self.connectionstate?.set_newLifeCycle(true);
                
            }
            break
        default:
            
            self.connectionstate?.handledispatcher(States.CONNECTION_BREAK,  dBError("E063"))
            if (self.ClientSocket != nil)  {
                self.ClientSocket?.removeAllHandlers()
            }
            if(!self.autoReconnect){
                  self.connectionstate?.handledispatcher(States.DISCONNECTED, "")
                self.channel?.cleanUp_All()
                self.rpc?.cleanUp_All()
                self.connectionstate?.state("")
                self.lifeCycle =  0;
                self.retryCount = 0;
                self.connectionstate?.set_newLifeCycle(true);
            }else{
                self.reconnect()
            }
            
            break
        }
    }
        
    internal func IOMessage(_ message: MessageStructure)
    {
        switch(message.dbmsgtype)
        {
        case MessageType.SYSTEM_MSG:
            self.Handle_System_Message(message)
            break
        case MessageType.SUBSCRIBE_TO_CHANNEL:
            
            self.Handle_Subscribe_to_Channel_Message(message)
            break
        case MessageType.CONNECT_TO_CHANNEL:
            self.Handle_Connect_to_Channel_Message(message)
            break
        case MessageType.UNSUBSCRIBE_DISCONNECT_FROM_CHANNEL:
            self.Handle_unsubscribe_Disconnect_from_Channel_Message(message)
            break
        case MessageType.PUBLISH_TO_CHANNEL:
            self.Handle_Publish_Message(message)
            break
        case MessageType.PARTICIPANT_JOIN:
            self.Handle_PJOIN_Message(message)
            break
        case MessageType.PARTICIPANT_LEFT:
            self.Handle_PLEFT_Message(message)
            break
        case MessageType.CF_CALL_RECEIVED_OR_CALL:
            self.Handle_CF_CALL_RECIEVED_Message(message)
            break
        case MessageType.CF_RESPONSE_TRACKER:
            self.Handle_CF_RESPONSE_TRACKER_Message(message)
            break
        case MessageType.CF_CALLEE_QUEUE_EXCEEDED:
            self.Handle_CF_CALLEE_QUEUE_EXCEEDED_Message(message)
            break
        case MessageType.CONNECT_TO_RPC_SERVER:
            self.Handle_CONNECT_TO_RPC_SERVER_Message(message)
            break
        case MessageType.RPC_CALL_RESPONSE:
            self.Handle_RPC_CALL_RESPONSE_Message(message)
            break
        case MessageType.RPC_RESPONSE_TRACKER:
            self.Handle_RPC_RESPONSE_TRACKER_Message(message)
            break
        case MessageType.RPC_CALLEE_QUEUE_EXCEEDED:
            self.Handle_RPC_CALLEE_QUEUE_EXCEEDED_Message(message)
            break
        default:
               break
        }
    }
    
    
    
    internal func acceptOpen()
    {
        self.retryCount = 0
        self.connectionstate?.reconnect_attempt =  Int(self.retryCount)
        
        if(self.ClientSocket?.status == SocketIOStatus.connected){
            if(self.lifeCycle == 0){
                self.connectionstate?.handledispatcher(States.CONNECTED, nil)
            }else{
                self.connectionstate?.handledispatcher(States.RECONNECTED, nil)
            }
        }
    }

    
    internal func RttpPong(_ message: MessageStructure ,  _ subject : String , _ latency: Int64){
        
        let  msgDbp:[Any] = [
            message.dbmsgtype,
            (subject.isEmpty) ? NSNull() :  subject,
            (message.rsub == nil) ? NSNull() :  message.rsub as Any,
            (message.sid == nil) ? NSNull() :  message.sid as Any,
            
            (message.payload == nil) ? Data("".utf8) : Data( message.payload!.utf8),
             
            (message.fenceid == nil) ? NSNull() :  message.fenceid as Any,
             false ,
            false ,
            (message.rtrackstat  == nil) ? NSNull() : message.rtrackstat  as Any,
            (message.t1  == nil) ? NSNull() :   message.t1!,
            latency,
            NSNull(),
            (message.sourceid  == nil) ? NSNull() :   message.sourceid! as Any,
            (message.sourceip  == nil) ? NSNull() :  message.sourceip! as Any,
            NSNull()  ,
            (message.oqueumonitorid  == nil) ? NSNull() : message.oqueumonitorid! as Any]
            let _ = self.send(msgDbp)
    }
    
    
    
    internal func Handle_System_Message(_ message: MessageStructure)
    {
        let lib_latency:Int64  = Int64((Date().timeIntervalSince1970 * 1000).rounded()) - message.t1!
        switch message.subject {
        case "connection:success":
            self.sessionid =  message.payload
            if(self.connectionstate!.get_newLifeCycle())
            {
                if(self.cf?.functions != nil){
                    self.cf?.functions!()
                }
            }
            
            
            var minuptime:Double =  1
            if (self.minUptime > 0 ){
                minuptime =  Double((self.minUptime / 1000))
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + minuptime) {
                self.acceptOpen()
            }
            
            
            self.rpc?._ReSubscribeAll();
            self.channel?._ReSubscribeAll();
            
            if (message.t1 != 0){
                self.RttpPong(message ,  "rttpong" ,  lib_latency)
            }
        case "rttping":
            if (message.t1 != 0){
                self.RttpPong(message ,  "rttpong" ,  lib_latency)
            }
            
        case "rttpong":
            if (message.t1 != 0) {
                self.connectionstate?.rttms(lib_latency)
                self.connectionstate?.handledispatcher(States.RTTPONG, lib_latency)
          }
        case "reconnect":
            self.isServerReconnect = true
            self.ClientSocket?.disconnect()
            
        default:
           break
        }
    }
    
    
    internal func Handle_Subscribe_to_Channel_Message(_ message: MessageStructure)
    {
        switch (message.subject) {
           case "success":
            switch (self.channel?._get_subscribeStatus(message.sid!)) {
             case ChannelStatus.SUBSCRIPTION_INITIATED:
                self.channel?._updateChannelsStatusAddChange(0, message.sid!, ChannelStatus.SUBSCRIPTION_ACCEPTED, "");
               break;
             case ChannelStatus.SUBSCRIPTION_ACCEPTED, ChannelStatus.SUBSCRIPTION_PENDING:
                self.channel?._updateChannelsStatusAddChange(1, message.sid!, ChannelStatus.SUBSCRIPTION_ACCEPTED, "");
               break;
            default:
                break
            }
             break;
           default:
            let dberr: dBError =  dBError("E064");
            dberr.updateCode(message.subject!.uppercased(), message.payload!)

            switch (self.channel?._get_subscribeStatus(message.sid!)) {
             case ChannelStatus.SUBSCRIPTION_INITIATED:
                self.channel?._updateChannelsStatusAddChange(0, message.sid!, ChannelStatus.SUBSCRIPTION_ERROR, dberr);
               break;
             case ChannelStatus.SUBSCRIPTION_ACCEPTED, ChannelStatus.SUBSCRIPTION_PENDING:
                self.channel?._updateChannelsStatusAddChange(1, message.sid!, ChannelStatus.SUBSCRIPTION_PENDING, dberr);
               break;
            default:
                break
            }
             break;
           }
    }
    
    
    internal func Handle_Connect_to_Channel_Message(_ message: MessageStructure){
        switch (message.subject) {
           case "success":
            switch (self.channel?._get_subscribeStatus(message.sid!)) {
             case ChannelStatus.CONNECTION_INITIATED:
                self.channel?._updateChannelsStatusAddChange(0, message.sid!, ChannelStatus.CONNECTION_ACCEPTED, "");
               break;
             case ChannelStatus.CONNECTION_ACCEPTED, ChannelStatus.CONNECTION_PENDING:
                self.channel?._updateChannelsStatusAddChange(1, message.sid!, ChannelStatus.CONNECTION_ACCEPTED, "");
               break;
            default:
                break
            }
             break;
           default:
            let dberr: dBError =  dBError("E084");
            dberr.updateCode(message.subject!.uppercased(), message.payload!)

            switch (self.channel?._get_subscribeStatus(message.sid!)) {
             case ChannelStatus.CONNECTION_INITIATED:
                self.channel?._updateChannelsStatusAddChange(0, message.sid!, ChannelStatus.CONNECTION_ERROR, dberr);
               break;
             case ChannelStatus.CONNECTION_ACCEPTED, ChannelStatus.CONNECTION_PENDING:
                self.channel?._updateChannelsStatusAddChange(1, message.sid!, ChannelStatus.CONNECTION_PENDING, dberr);
               break;
            default:
                break
            }
             break;
           }
    }
    
    
    
    internal func Handle_unsubscribe_Disconnect_from_Channel_Message(_ message: MessageStructure){
        switch (message.subject!) {
            case "success":

                switch (self.channel?._get_channelType(message.sid!)) {
              case "s":
                self.channel?._updateChannelsStatusRemove(message.sid!, ChannelStatus.UNSUBSCRIBE_ACCEPTED, "")
                break
              case "c":
                self.channel?._updateChannelsStatusRemove(message.sid!, ChannelStatus.DISCONNECT_ACCEPTED, "")
                break
                default:
                    break
                }
              break;
            default:
                switch (self.channel?._get_channelType(message.sid!)) {
                  case "s":
                    let dberr:dBError =  dBError("E065");
                    dberr.updateCode(message.subject!.uppercased(), message.payload!)

                    self.channel?._updateChannelsStatusRemove(message.sid!, ChannelStatus.UNSUBSCRIBE_ERROR, dberr)
                    break;
                  case "c":
                    let dberr:dBError = dBError("E088")
                    dberr.updateCode(message.subject!.uppercased(), message.payload!)
                    self.channel?._updateChannelsStatusRemove(message.sid!, ChannelStatus.DISCONNECT_ERROR, "")
                    break
                default:
                    break
                    }
                  break
            }
        
    }
    
    
    internal func Handle_Publish_Message(_ message: MessageStructure){
    
        let mchannelName: String? = self.channel?._get_channelName(message.sid!)
        let metadata: MetaData = MetaData()
        metadata.eventName = message.subject!
        metadata.sourcesysid = message.sourceid!
        metadata.sessionid = message.sourceip!
        metadata.seqnum = message.oqueumonitorid!
        if (message.t1 != 0) { metadata.intime = message.t1! }


        if ((mchannelName?.lowercased().starts(with: "sys:*")) != nil) {
            metadata.channelName = message.fenceid!
         } else {
            metadata.channelName = mchannelName!
         }


        self.channel?._handledispatcherEvents(message.subject!, message.payload!, mchannelName!, metadata);
    }
    
    
    
    internal func Handle_PJOIN_Message(_ message: MessageStructure){
        let mchannelName:String?  = self.channel?._get_channelName(message.sid!)
        let metadata:MetaData = MetaData()
        metadata.eventName = "dbridges:participant.joined"
        metadata.sourcesysid = message.sourceid!
        metadata.sessionid = message.sourceip!
        metadata.seqnum = message.oqueumonitorid!
        metadata.channelName = mchannelName!
        if (message.t1 != 0) { metadata.intime = message.t1! }

        if (mchannelName!.lowercased().starts(with: "sys:") || mchannelName!.lowercased().starts(with: "prs:")) {
            let extradata = self._convertToObject(message.sourceip!, message.sourceid!, message.fenceid!)
                metadata.sourcesysid = extradata.sourcesysid
                metadata.sessionid = extradata.sessionid
            if (mchannelName?.lowercased().starts(with:"sys::*") != nil) {
                  self.channel?._handledispatcherEvents("dbridges:participant.joined", extradata, mchannelName!, metadata);
                } else {
                  self.channel?._handledispatcherEvents("dbridges:participant.joined", extradata, mchannelName!, metadata);
                }
              } else {
                let m_dic: [String: String] = ["sourcesysid" : message.sourceid!]
                
                self.channel?._handledispatcherEvents("dbridges:participant.joined", m_dic.description, mchannelName!, metadata);
              }
    }
    
    
    
    internal func _convertToObject(_ sourceip:String , _ sourceid: String , _ channelname : String ) ->ExtraData {
        
        let exd: ExtraData =  ExtraData()
        
        if (!sourceid.isEmpty) {
            let strData = sourceid.components(separatedBy: "#")
            if (strData.count > 1) { exd.sessionid = strData[0] }
            if (strData.count > 2) { exd.libtype = strData[1] }
            if (strData.count > 3) { exd.sourceipv4 = strData[2] }
            if (strData.count > 4) { exd.sourceipv6 = strData[3] }
            if (strData.count >= 5) { exd.sourcesysid = strData[4] }
        }
        
        exd.sysinfo =  sourceip
        if(!channelname.isEmpty){ exd.channelname =  channelname }
        return exd
    }
    
    internal func Handle_PLEFT_Message(_ message: MessageStructure){
        let mchannelName:String?  = self.channel?._get_channelName(message.sid!)
        let metadata:MetaData = MetaData()
        metadata.eventName = "dbridges:participant.left"
        metadata.sourcesysid = message.sourceid!
        metadata.sessionid = message.sourceip!
        metadata.seqnum = message.oqueumonitorid!
        metadata.channelName = mchannelName!
        if (message.t1 != 0) { metadata.intime = message.t1! }

        if (mchannelName!.lowercased().starts(with: "sys:") || mchannelName!.lowercased().starts(with: "prs:")) {
            let extradata = self._convertToObject(message.sourceip!, message.sourceid!, message.fenceid!)
                metadata.sourcesysid = extradata.sourcesysid
                metadata.sessionid = extradata.sessionid
            if (mchannelName?.lowercased().starts(with:"sys::*") != nil) {
                  self.channel?._handledispatcherEvents("dbridges:participant.left", extradata, mchannelName!, metadata);
                } else {
                  self.channel?._handledispatcherEvents("dbridges:participant.left", extradata, mchannelName!, metadata);
                }
              } else {
                let m_dic: [String: String] = ["sourcesysid" : message.sourceid!]
                
                self.channel?._handledispatcherEvents("dbridges:participant.left", m_dic.description, mchannelName!, metadata);
              }
    }

    
    internal func Handle_CF_CALL_RECIEVED_Message(_ message: MessageStructure){
        if (message.sid! == "0") {
          
            self.cf?._handle_dispatcher(message.subject!, message.rsub!, message.sid!, message.payload!);
        }
    }
    
    
    internal func Handle_CF_RESPONSE_TRACKER_Message(_ message: MessageStructure){
        self.cf?._handle_tracker_dispatcher(message.subject!, message.rsub!)
    }
    
    
    internal func Handle_CF_CALLEE_QUEUE_EXCEEDED_Message(_ message: MessageStructure){
        self.cf?._handle_exceed_dispatcher()
    }
    
  
    internal func Handle_CONNECT_TO_RPC_SERVER_Message(_ message: MessageStructure){
        switch (message.subject!) {
                case "success":
                    switch (self.rpc?._get_rpcStatus(message.sid!)) {
                  case RpcStatus.RPC_CONNECTION_INITIATED:
                    self.rpc?._updateRegistrationStatusAddChange(0, message.sid!, RpcStatus.RPC_CONNECTION_ACCEPTED, "");
                    break;
                  case RpcStatus.RPC_CONNECTION_ACCEPTED , RpcStatus.RPC_CONNECTION_PENDING:
                    self.rpc?._updateRegistrationStatusAddChange(1, message.sid!, RpcStatus.RPC_CONNECTION_ACCEPTED, "");
                    break;
                    default:
                        break
                  }
                  break;
                default:
                    let dberr:dBError = dBError("E082");
                    dberr.updateCode(message.subject!.uppercased(), "");
                    switch (self.rpc?._get_rpcStatus(message.sid!)) {
                  case RpcStatus.RPC_CONNECTION_INITIATED:
                    self.rpc?._updateRegistrationStatusAddChange(0, message.sid!, RpcStatus.RPC_CONNECTION_ERROR, dberr);
                    break;
                  case RpcStatus.RPC_CONNECTION_ACCEPTED,  RpcStatus.RPC_CONNECTION_PENDING:
                    self.rpc?._updateRegistrationStatusAddChange(1, message.sid!, RpcStatus.RPC_CONNECTION_PENDING, dberr);
                    break;
                  default:
                    break
                  }
                  break;
                }
    }
  
    internal func Handle_RPC_CALL_RESPONSE_Message(_ message: MessageStructure){
        
        let rpccaller:RpcClient = (self.rpc?.get_object(message.sid!))!
        rpccaller._handle_callResponse(message.sid!, message.payload!, message.rspend!, message.rsub!)
    }
    
    
    internal func Handle_RPC_RESPONSE_TRACKER_Message(_ message: MessageStructure){
        
        let rpccaller:RpcClient = (self.rpc?.get_object(message.sid!))!
        rpccaller._handle_tracker_dispatcher(message.subject!, message.rsub!)
    }
    
    
    
    internal func Handle_RPC_CALLEE_QUEUE_EXCEEDED_Message(_ message: MessageStructure){
        
        let rpccaller:RpcClient = (self.rpc?.get_object(message.sid!))!
        rpccaller._handle_exceed_dispatcher()
    }
    
    
    
    public func send(_ data: [Any]) -> Bool
    {
        var m_flag:Bool = false
       
        if(self.ClientSocket?.status == SocketIOStatus.connected)
        {
           
            DispatchQueue.main.async {
               
                do{
                    self.socketManage?.defaultSocket.emit("db",with: data)
                    
                }catch let error{
               
                }
                
            }
            m_flag = true
            
        }else{
            m_flag=false
        }
        return m_flag
    }
    
   
    
    public func _isSocketConnected()->Bool{
        if(self.ClientSocket?.status == SocketIOStatus.connected){
            return true
        }
        return false
    }
    
}
