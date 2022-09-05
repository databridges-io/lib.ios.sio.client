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

public class Rpc{
    private var _dbcore:databridges_sio_swift_client
        
    private var _serverName_sid: [String: [String:String]]
    private var _serverSid_registry: [String : Any]
    private var _dispatch:EventDispatcher
    private var _callersid_object: [String: Any]
    static let _server_type = ["pvt", "prs", "sys"];
    
    public init(_ dBCoreObject: databridges_sio_swift_client){
        self._dbcore =  dBCoreObject
        self._serverName_sid = [: ]
        self._serverSid_registry = [: ]
        self._dispatch =  EventDispatcher()
        self._callersid_object = [:]
    }
    
    
    private func  isEmptyOrSpaces(_ str:String)->Bool{
        if (str.isEmpty) {return false}
        let str2:String = str.trimmingCharacters(in: .whitespacesAndNewlines)
        return str2.isEmpty
         
       }
    
    private func  isAlphaNumeric( _ s:String)->Bool {
        if(s.isEmpty) { return false }
        
        if ( s.range(of: "^[a-zA-Z0-9.:_-]*$", options: .regularExpression) == nil) { return false }
        return true
    }
    
    
    
    func  _validateServerName(_ Name: String, _ error_type: Int) throws ->Bool {
     
            if (self.isEmptyOrSpaces(Name)) {
                
                switch (error_type) {
                    case 1:
                        throw dBError("E048") 
                    default:
                        break
                }
            }
        if (Name.count > 64) {
            
                switch (error_type) {
                    case 1:
                        throw  dBError("E051") 
                    default:
                        break
                }

            }
            if(!isAlphaNumeric(Name)){
                switch (error_type) {
                    case 1:
                        throw dBError("E052")

                    default:
                        break
                }
            }

        if (Name.contains(":")) {
            let sdata: [String] = Name.lowercased().components(separatedBy: ":")
            if(!Channels._channel_type.contains(sdata[0]))
            {
                switch (error_type) {
                case 1:
                    throw dBError("E052")
                default:
                    break
            }
                }
            }
            return true
        }
    
    
    public func _get_rpcStatus(_ sid: String) -> String{
        return (self._serverSid_registry[sid] as! dbPacket).status
     }
    
    
    
    public func bind(_ eventName: String, _ callback: @escaping dBInFunction) throws {

        try self._dispatch.bind(eventName, callback)
      }

    public func  unbind(_ eventName: String, _ callback: @escaping dBInFunction) {
        self._dispatch.unbind(eventName, callback);
      }

    public func bind_all(_ callback: @escaping dBInFunction) {
        self._dispatch.bind_all(callback);
      }

    public func unbind_all(_ callback: @escaping dBInFunction) {
        self._dispatch.unbind_all(callback);
      }

    
    func isPrivate(_ serverName:String)->Bool{
        var flag:Bool = false
        if(serverName.contains(":")){
            let sdata = serverName.lowercased().components(separatedBy: ":")
            if(Rpc._server_type.contains(sdata[0])){ flag = true}
        }else{
            flag=false
        }
        return flag
    }
    
    private func _communicateR( _ serverName:  String, _ sid: String, _ access_token:String  ) throws{
        var cStatus:Bool = false
        
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_RPC_SERVER, serverName, sid ,  access_token,  "", "",0 , 0)
        if (!cStatus) {
                throw ( dBError("E024"))
        }
     
    }
    
    private func _ReSubscribe(_ sid: String , _ serverName:String ){
       
        if(self._serverSid_registry[sid] == nil) {return}
        
        let m_object:dbPacket = self._serverSid_registry[sid] as! dbPacket
        let access_token:String = ""
        let mprivate:Bool = self.isPrivate(m_object.name)
        
        switch(m_object.status)
        {
        case RpcStatus.RPC_CONNECTION_ACCEPTED, RpcStatus.RPC_CONNECTION_INITIATED:
                do {
                    if(!mprivate){
                        try self._communicateR(m_object.name , sid, access_token)
                    }else{
                        let response:AccessResponse  =  AccessResponse(0 , m_object.name ,  sid , self)
                        try? self._dbcore.accesstoken_dispatcher(m_object.name , AccessTokens.RPCCONNECT ,  response )
                    }

                } catch let error {
                    let eventsexp:[String] = [systemEvents.OFFLINE]
                    self._handleRegisterEvents(eventsexp , error,  m_object)
                    return
                }
                break
        default:
            break
        }
    }

    public func _ReSubscribeAll() {
        
       var publicList:[String] =  [String]()
       var privateList:[String] = [String]()
        
        for (key , value) in self._serverName_sid {
            for (k2 , v2) in value as! [String: String]{
                if(self.isPrivate (key)){
                    privateList.append(k2)
                }else{
                    publicList.append(k2)
                }
            }
        }

        for ks in publicList{
            self._ReSubscribe(ks ,  "")
        }
        
        for k2s in privateList{
            self._ReSubscribe(k2s , "")
        }
    }

    
    public func dispatchEvents(_ eventName:String ,  _ eventData: Any , _ m_object: dbPacket) {
        let metadata: ServerMetaData = ServerMetaData()
        metadata.eventName = eventName
        metadata.serverName = m_object.name
        self._dispatch.emit_rpcStatus(eventName, eventData, metadata)
        (m_object.ino as! RpcClient).emit_rpcStatus(eventName, eventData, metadata)
    }


    public func _handleRegisterEvents(_ eventName: [String] , _ eventData:Any , _ m_object: dbPacket){
        
        for en in eventName{
            self.dispatchEvents(en ,  eventData ,  m_object)
        }
    }
    
    
    
    public func _updateRegistrationStatus(_ sid:String , _ status: String , _ reason: Any){
        if(self._serverSid_registry[sid] == nil) { return }
        
        
        let m_object: dbPacket =  self._serverSid_registry[sid] as! dbPacket
        var events: [String]
        switch(m_object.type)
        {
            case "c":
                switch(status){
                    case RpcStatus.RPC_CONNECTION_ACCEPTED:
                        (self._serverSid_registry[sid] as! dbPacket).status = status
                        (m_object.ino as! RpcClient).set_isOnline(true)
                        events = [systemEvents.RPC_CONNECT_SUCCESS, systemEvents.SERVER_ONLINE]
                        self._handleRegisterEvents(events , "" ,  m_object)
                        break
                    default:
                        (self._serverSid_registry[sid] as! dbPacket).status  = status
                        (m_object.ino as! RpcClient).set_isOnline(false)
                        events = [systemEvents.RPC_CONNECT_FAIL]
                        self._handleRegisterEvents( events, reason ,  m_object)
                        self._serverName_sid.removeValue(forKey: m_object.name)  //delete(m_object.name);
                        self._serverSid_registry.removeValue(forKey: sid)

                        break;

                }
                break;
            default:
                break;
        }

    }

    public func _updateRegistrationStatusRepeat(_ sid:String , _ status: String , _ reason: Any){
        if(self._serverSid_registry[sid] == nil) { return }
        
        
        let m_object: dbPacket =  self._serverSid_registry[sid] as! dbPacket
        var events: [String]
        switch(m_object.type)
        {
            case "c":
                switch(status){
                    case RpcStatus.RPC_CONNECTION_ACCEPTED:
                        (self._serverSid_registry[sid] as! dbPacket).status = status
                        (m_object.ino as! RpcClient).set_isOnline(true)
                        events =  [systemEvents.SERVER_ONLINE]
                        self._handleRegisterEvents(events , "" ,  m_object);
                        break
                    default:
                        (self._serverSid_registry[sid] as! dbPacket).status  = status
                        (m_object.ino as! RpcClient).set_isOnline(false)
                        events = [ systemEvents.SERVER_OFFLINE]
                        self._handleRegisterEvents( events, reason ,  m_object)
                        break;

                }
                break;
            default:
                break;
        }

    }

    public func _updateRegistrationStatusAddChange(_ life_cycle: Int, _ sid:String ,  _ status:String ,  _ reason: Any)
    {
        if(life_cycle == 0){
            
            self._updateRegistrationStatus(sid , status, reason);
        }else{ // resubscribe due to network failure
            self._updateRegistrationStatusRepeat(sid , status, reason);
        }
    }

    func _communicate(_ serverName: String, _ mprivate: Bool , _ action:String) throws ->Any {
        var cStatus:Bool =  false
        var m_server:Any
        var m_value:dbPacket
        let access_token:String = ""
        let sid:String =  Util.GenerateUniqueId(6)

          if(!mprivate){
            
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_RPC_SERVER, serverName, sid ,  access_token, "" , "", 0 ,0)
              if(!cStatus) {
                throw  dBError("E053")
              }
          }else{
            let response:AccessResponse =   AccessResponse(0 , serverName ,  sid , self)
              try? self._dbcore.accesstoken_dispatcher(serverName , action ,  response )
          }

         
              m_server =  RpcClient(serverName , self._dbcore, self , "rpc" ) as Any
        m_value =  dbPacket(serverName , "c", RpcStatus.RPC_CONNECTION_INITIATED, m_server )
          
        self._serverSid_registry[sid] = m_value
        
        if (self._serverName_sid[serverName] ==  nil){
            self._serverName_sid[serverName] = [:]
            self._serverName_sid[serverName]?[sid] = ""
        }else{
            self._serverName_sid[serverName]?[sid] = ""
        }
        
        //self._serverName_sid[serverName] = sid
          return m_server
      }

    
    func _failure_dispatcher(_ mtype:Int , _ sid:String , _ reason:String)
    {
        if(self._serverSid_registry[sid] == nil) {return}
        let m_object:dbPacket = self._serverSid_registry[sid] as! dbPacket
      
        
        if(mtype == 0){
            let m_channelnbd:RpcClient =  m_object.ino as! RpcClient
            
            m_channelnbd.set_isOnline(false)
            let eventsds:[String] = [systemEvents.RPC_CONNECT_FAIL]
            self._handleRegisterEvents(eventsds, reason ,  m_object)

        }
        if ((self._serverName_sid[m_object.name]?.keys.contains(sid)) != nil){
            self._serverName_sid[m_object.name]?.removeValue(forKey: sid)
        }else{
            self._serverName_sid .removeValue(forKey: m_object.name)
        }
        
        self._serverSid_registry.removeValue(forKey: sid)
    }

    func _send_to_dbr(_ mtype: Int , _ serverName:String ,  _ sid: String ,  _ access_data:AccessInfo)
    {
        var cStatus:Bool = false

            if(access_data.statuscode != 0 ){
                self._failure_dispatcher(mtype , sid ,  access_data.error_message)
                return
            }


        if(mtype ==  0){
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_RPC_SERVER, serverName, sid ,  access_data.accesskey , "", "", 0, 0)
        }

        if(!cStatus){
            self._failure_dispatcher(mtype , sid ,  "library is not connected with the dbridges network")
        }
    }

    
    
    public func connect(_ serverName: String) throws -> RpcClient{
       
        do {
         let _:Bool = try self._validateServerName(serverName, 1)
        } catch let e {
            throw(e)
        }

        
        let mprivate:Bool =  self.isPrivate(serverName)

        var m_caller:RpcClient

         do {
            m_caller = try self._communicate(serverName, mprivate, AccessTokens.RPCCONNECT) as! RpcClient
         } catch  let error {
             throw( error)
         }
         return m_caller
     }
    
    
    
    public func ChannelCall( _ channelName: String) -> RpcClient {

        if(self._serverName_sid[channelName] != nil){
            let sids:[String:String] = self._serverName_sid[channelName]!
            let sid  =  Array(sids.keys)[0]
            
            let mobject:dbPacket = self._serverSid_registry[sid] as! dbPacket
            (self._serverSid_registry[sid] as! dbPacket).count = mobject.count + 1
            return mobject.ino as! RpcClient
        }
        
        let sid: String =  Util.GenerateUniqueId(6)
        let rpccaller: RpcClient =  RpcClient(channelName,self._dbcore, self, "ch")
        
        if(!self._serverName_sid.keys.contains(channelName)){
            self._serverName_sid[channelName] =  [:]
            self._serverName_sid[channelName]?[sid] = ""
        }else{
            self._serverName_sid[channelName]?[sid] =  ""
        }
        
        
        let m_value:dbPacket = dbPacket(channelName,  "X" , RpcStatus.RPC_CONNECTION_INITIATED, rpccaller)
        self._serverSid_registry[sid] = m_value
        return rpccaller;
    }

    /*public func  ClearChannel(_ channelName: String){
        
        if(self._serverName_sid[channelName] == nil){ return }
        let sid:String = self._serverName_sid[channelName]!
        
        if((self._serverSid_registry[sid] as! dbPacket).count  == 1){
            self._serverName_sid.removeValue(forKey: channelName) ;
            self._serverSid_registry.removeValue(forKey: sid)

        }else{
            let mobject:dbPacket = self._serverSid_registry[sid] as! dbPacket
            (self._serverSid_registry[sid] as! dbPacket).count = mobject.count - 1
        }
    }*/

    public func store_object(_ sid:String , _ rpccaller: RpcClient){
            self._callersid_object[sid] = rpccaller
    }

    public func delete_object(_ sid: String){
        self._callersid_object.removeValue(forKey: sid)
    }

    public func get_object(_ sid: String) -> RpcClient? {
        
        if(self._callersid_object[sid] == nil){ return nil}
        
        let rpccaller: RpcClient = self._callersid_object[sid] as! RpcClient
        return rpccaller
    }
    
    
    func _send_OfflineEvents(){
        
        for (_ , value) in self._serverSid_registry {
            var events: [String]
            events = [ systemEvents.SERVER_OFFLINE]
            self._handleRegisterEvents( events, "" ,  (value as! dbPacket))
            
        }
    }
    
    func clean_rpc(_ sid:String)-> Bool{
        
        if(self._serverSid_registry[sid] == nil) {return false }
        let dbpacket:dbPacket = self._serverSid_registry[sid] as! dbPacket
        if (dbpacket.type == "c")
        {
            let channel_object:RpcClient  =  dbpacket.ino as! RpcClient
            channel_object.unbind()
            channel_object.unbind_all()
            return true
        }
        return false
    }
   
    
    
    func cleanUp_All(){
        for (key , value) in self._serverSid_registry {
            let dbpacket:dbPacket = value as! dbPacket
            let md:ServerMetaData =  ServerMetaData()
            md.serverName =  dbpacket.name
            md.eventName = systemEvents.OFFLINE
            //self._handledispatcher(systemEvents.REMOVE,"", md)
            if (self.clean_rpc(key)){
                if (self._serverName_sid.keys.contains(key)){
                    self._serverName_sid[dbpacket.name]?.removeValue(forKey: key)
                }else{
                    self._serverName_sid.removeValue(forKey: dbpacket.name)
                }
                self._serverSid_registry.removeValue(forKey:key)
            }
        }
    }
    

}
