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

public class Channels {

    static let  _channel_type = ["pvt", "prs", "sys"]
    var _channelsid_registry:[String:Any]=[:]
    var _channelname_sid:[String:String]=[:]
    var _dbcore:databridges_sio_swift_client
    var _dispatch:EventDispatcher
    static let  regex:String  = "^[a-zA-Z0-9@$&-.+:]*$"
    //static let  pattern:Pattern
    
    init(_ dBCoreObject: databridges_sio_swift_client)
    {
    
        self._dbcore = dBCoreObject
        self._dispatch = EventDispatcher()
        self._channelname_sid=[:]
        self._channelsid_registry=[:]
        
      //  pattern = Pattern.compile(regex)
    }
    
    
    
   public func bind(_ eventName: String, _ eventhandler: @escaping dBChannelCallBack) throws {
        try self._dispatch.bind(eventName, eventhandler)
    }


    public func unbind(_ eventName: String) throws {
        
        self._dispatch.unbind(eventName)
    }
    
    
    
    public func unbind(){
        self._dispatch.unbind()
    }

    public func bind_all( _ eventhandler: @escaping dBChannelCallBack  ) throws {
         self._dispatch.bind_all(eventhandler)
    }

    
    public func unbind_all( ) {
      self._dispatch.unbind_all()
    }
    
    
    func _handledispatcher(_ eventName: String , _ eventInfo: String, _ MetaDatav:MetaData)
    {
       
        self._dispatch.emit_channelStatus(eventName, eventInfo, MetaDatav)
    }
    
    
    func _handledispatcher(_ eventName: String , _ eventInfo: dBError, _ MetaDatav:MetaData)
    {
       
        self._dispatch.emit_channelStatus(eventName, eventInfo, MetaDatav)
    }
    
    
    func _handledispatcher(_ eventName: String , _ eventInfo: Any, _ MetaDatav:MetaData)
    {
        
        self._dispatch.emit_channelStatus(eventName, eventInfo, MetaDatav)
    }
    
    
    func _handledispatcherEvents(_ eventName: String, _ eventInfo:Any , _ channelName: String , _ metadata: MetaData) {
          self._dispatch.emit_channelStatus(eventName, eventInfo, metadata)
        let sid:String = self._channelname_sid[channelName]!
        let m_object: dbPacket = self._channelsid_registry[sid] as! dbPacket
       // if (m_object == nil) { return }
        (m_object.ino as! Subscribe).emit_channelStatus(eventName, eventInfo, metadata)
        }
    
    
    func _handledispatcher(_ eventName: String , _ eventInfo: Any, _ channelName: String,_ MetaDatav:MetaData)
    {
        self._dispatch.emit_channelStatus(eventName, eventInfo, MetaDatav)
        if (self._channelname_sid[channelName] != nil){
        let sid: String =  self._channelname_sid[channelName]!
        if(self._channelsid_registry[sid] != nil)
        {
            let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
            if (m_object.type == "s")
            {
                let channel_object:Subscribe  =  m_object.ino as! Subscribe
                channel_object.emit_channelStatus(eventName, eventInfo, MetaDatav)
            }else{
                let channelnbd_object = m_object.ino as! Connect
                channelnbd_object.emit_channelStatus(eventName, eventInfo, MetaDatav)
            }
        }
        }
    }
    
    func isPrivateChannel(_ channelName:String)->Bool{
        var flag:Bool = false
        if(channelName.contains(":")){
            let sdata = channelName.lowercased().components(separatedBy: ":")
            if(Channels._channel_type.contains(sdata[0])){ flag = true}
        }else{
            flag=false
        }
        return flag
    }
    
    func _communicateR(_ mtype:Int, _ channelName:  String, _ sid: String, _ access_token:String  ) throws{
        var cStatus:Bool = false
        if(mtype == 0){
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.SUBSCRIBE_TO_CHANNEL, channelName, sid ,  access_token,  "", "",0 , 0)
        }else{
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_CHANNEL, channelName, sid ,  access_token, "","",0 , 0)
        }
        if (!cStatus) {
            if (mtype == 0) {
                throw ( dBError("E024"))
            } else {
                throw ( dBError("E090"))
            }
        }
     
    }
    

    func _ReSubscribe(_ sid: String , _ channelName:String ){
       
        if(self._channelsid_registry[sid] == nil) {return}
        
        let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
        let access_token:String = ""
        let mprivate:Bool = self.isPrivateChannel(m_object.name)
        
        switch(m_object.status)
        {
        case ChannelStatus.SUBSCRIPTION_ACCEPTED, ChannelStatus.SUBSCRIPTION_INITIATED:
                do {
                    if(!mprivate){
                        try self._communicateR(0, m_object.name , sid, access_token)
                    }else{
                        let response:AccessResponse  =  AccessResponse(0 , m_object.name ,  sid , self)
                        try? self._dbcore.accesstoken_dispatcher(m_object.name , AccessTokens.CHANNELSUBSCRIBE ,  response )
                    }

                } catch let error {
                    let eventsexp:[String] = [systemEvents.OFFLINE]
                    self._handleSubscribeEvents(eventsexp , error,  m_object)
                    return
                }
                break
        case ChannelStatus.CONNECTION_INITIATED, ChannelStatus.CONNECTION_ACCEPTED:
                do {
                    if(!mprivate){
                        try self._communicateR(1, m_object.name , sid, access_token)
                    }else{
                        let response:AccessResponse =  AccessResponse(1 , m_object.name ,  sid , self)
                        try self._dbcore.accesstoken_dispatcher(m_object.name , AccessTokens.CHANNELCONNECT ,  response )
                    }


                } catch let  e {
                    let eventsexpc:[String] = [ systemEvents.OFFLINE ]
                    self._handleSubscribeEvents(eventsexpc , e ,  m_object)
                    return
                }
                break

        case ChannelStatus.UNSUBSCRIBE_INITIATED:
            let channel_object : Subscribe = m_object.ino as! Subscribe
            channel_object.set_isOnline(false)
                
            let eventsexpus:[String] = [ systemEvents.UNSUBSCRIBE_SUCCESS, systemEvents.REMOVE]
                self._handleSubscribeEvents( eventsexpus, "" ,  m_object)
            self._channelname_sid.removeValue(forKey: m_object.name)
            self._channelsid_registry.removeValue(forKey:sid)

                break

        case ChannelStatus.DISCONNECT_INITIATED:
            let channelnbd_object : Connect = m_object.ino as! Connect
            channelnbd_object.set_isOnline(false)
            let eventsexpdi:[String] = [ systemEvents.DISCONNECT_SUCCESS, systemEvents.REMOVE]
                self._handleSubscribeEvents(eventsexpdi , "" ,  m_object)
                self._channelname_sid.removeValue(forKey: m_object.name)
                self._channelsid_registry.removeValue(forKey: sid)
                break
        default:
            break
        }
    }


    
    
    func _ReSubscribeAll() {
        
        for (key , value) in self._channelname_sid {
            self._ReSubscribe(value, key)
        }
    }

    
    func  isEmptyOrSpaces(_ str:String)->Bool{
        if (str.isEmpty) {return false}
        let str2:String = str.trimmingCharacters(in: .whitespacesAndNewlines)
        return str2.isEmpty
         
       }

        
    func _validateChanelName(_ channelName:String)throws ->Bool  {
        return try self._validateChanelName(channelName , 0)
      }
    
    
    
    func  isAlphaNumeric( _ s:String)->Bool {
        //"^[a-zA-Z0-9@$&-.+:]*$"
        if(s.isEmpty) { return false }
        
        if ( s.range(of: "^[a-zA-Z0-9@$&-.+:]*$", options: .regularExpression) == nil) { return false }
        return true
        
    }


    func  _validateChanelName(_ channelName: String, _ error_type: Int) throws ->Bool {
        if (!(self._dbcore.connectionstate!.isconnected())) {
                switch (error_type) {
                    case 0:
                        throw dBError("E024")
                        //break
                    case 1:
                        throw dBError("E030")
                        //break
                    default:
                        break
                }

            }
            if (self.isEmptyOrSpaces(channelName)) {
                switch (error_type) {
                    case 0:
                        throw  dBError("E025")
                        //break
                    case 1:
                        throw dBError("E030")
                        //break

                    default:
                        break
                }
            }
        if (channelName.count > 64) {
                switch (error_type) {
                    case 0:
                        throw  dBError("E027")
                        //break
                    case 1:
                        throw  dBError("E030")
                        //break

                    default:
                        break
                }

            }
            //if(!channelName.matches("[a-zA-Z0-9\\.:_-]") ) {
                if(!isAlphaNumeric(channelName)){
                switch (error_type) {
                    case 0:
                        throw  dBError("E028")
                        //break
                    case 1:
                        throw dBError("E030")
                        //break

                    default:
                        break
                }
            }

        if (channelName.contains(":")) {
            let sdata: [String] = channelName.lowercased().components(separatedBy: ":")
            if(!Channels._channel_type.contains(sdata[0]))
            {
                switch (error_type) {
                case 0:
                    throw dBError("E028")
                    //break
                case 1:
                    throw dBError("E030")
                    //break
                default:
                    break
            }
                }
            }
            return true
        }


    func _communicate(_ mtype:Int , _ channelName: String, _ mprivate: Bool , _ action:String) throws ->Any {
        var cStatus:Bool =  false
        var m_channel:Any
        var m_value:dbPacket
        let access_token:String = ""
        let sid:String =  Util.GenerateUniqueId(6)

          if(!mprivate){
              if(mtype ==  0){
                cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.SUBSCRIBE_TO_CHANNEL, channelName, sid ,  access_token, "" ,"",0 , 0)
              }else{
                cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_CHANNEL, channelName, sid ,  access_token, "" , "", 0 ,0)
              }
              if(!cStatus) {
                  if (mtype == 0) {
                      throw  dBError("E024")
                  } else {
                      throw dBError("E090")
                  }
              }
          }else{
            let response:AccessResponse =   AccessResponse(mtype , channelName ,  sid , self)
              try? self._dbcore.accesstoken_dispatcher(channelName , action ,  response )
          }

          if(mtype ==  0){
              m_channel =   Subscribe(channelName ,  sid, self._dbcore ) as Any
            m_value =  dbPacket(channelName , "s", ChannelStatus.SUBSCRIPTION_INITIATED, m_channel )
          }else{
              m_channel =  Connect(channelName ,  sid, self._dbcore ) as Any
            m_value =  dbPacket(channelName , "c", ChannelStatus.CONNECTION_INITIATED, m_channel )
          }
          self._channelsid_registry[sid] = m_value
          self._channelname_sid[channelName] = sid
          return m_channel
      }

    
    func _failure_dispatcher(_ mtype:Int , _ sid:String , _ reason:String)
    {
        if(self._channelsid_registry[sid] == nil) {return}
        let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
      
        
        if(mtype == 0){
            let m_channel:Subscribe =  m_object.ino as! Subscribe
            m_channel.set_isOnline(false)
            let eventssu:[String] = [systemEvents.SUBSCRIBE_FAIL]
            self._handleSubscribeEvents( eventssu, reason ,  m_object)

        }else{
            let m_channelnbd:Connect =  m_object.ino as! Connect
            
            m_channelnbd.set_isOnline(false)
            let eventsds:[String] = [systemEvents.CONNECT_FAIL]
            self._handleSubscribeEvents(eventsds, reason ,  m_object)

        }
        self._channelname_sid.removeValue(forKey: m_object.name)
        self._channelsid_registry.removeValue(forKey: sid)
    }

    func _send_to_dbr(_ mtype: Int , _ channelName:String ,  _ sid: String ,  _ access_data:AccessInfo)
    {
        var cStatus:Bool = false

            if(access_data.statuscode != 0 ){
                self._failure_dispatcher(mtype , sid ,  access_data.error_message)
                return
            }


        if(mtype ==  0){
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.SUBSCRIBE_TO_CHANNEL, channelName, sid ,  access_data.accesskey , "", "", 0, 0)
        }else{
            cStatus = Util.updatedBNewtworkSC(self._dbcore, MessageType.CONNECT_TO_CHANNEL, channelName, sid ,  access_data.accesskey , "", "", 0, 0)
        }

        if(!cStatus){
            self._failure_dispatcher(mtype , sid ,  "library is not connected with the dbridges network")
        }
    }

    
   public func  subscribe(_ channelName:String) throws ->Subscribe{
       
           do {
            let _:Bool = try self._validateChanelName(channelName)
           } catch let e {
               throw(e)
           }


        if(self._channelname_sid[channelName] != nil) { throw  dBError("E093")}

        let mprivate:Bool =  self.isPrivateChannel(channelName)

        var m_channel:Subscribe
        var m_actiontype:String = ""
        if (channelName.lowercased().starts(with: "sys:")) {
            m_actiontype = AccessTokens.SYSTEM_CHANNELSUBSCRIBE
           } else {
            m_actiontype = AccessTokens.CHANNELSUBSCRIBE
           }


           do {
            m_channel = try self._communicate(0 , channelName, mprivate, m_actiontype) as! Subscribe
           } catch let e {
               throw(e)
           }
           return m_channel
       }

    
    
    public func  connect(_ channelName:String) throws ->Connect{
       
        if (channelName.lowercased() != "sys:*"){
           do {
            let _:Bool = try self._validateChanelName(channelName)
           } catch let e {
               throw(e)
           }
        }


        if(self._channelname_sid[channelName] != nil) { throw  dBError("E093")}
        if (channelName.lowercased().starts(with:"sys:")) {throw  dBError("E095")}

        let mprivate:Bool =  self.isPrivateChannel(channelName)

        var m_channel:Connect
        let m_actiontype:String = AccessTokens.CHANNELCONNECT


           do {
            m_channel = try self._communicate(1, channelName, mprivate, m_actiontype) as! Connect
           } catch let e {
               throw(e)
           }
           return m_channel
       }

   public func unsubscribe(_ channelName:String) throws {

        if (self._channelname_sid[channelName] == nil) {throw  dBError("E030") }

        let  sid:String = self._channelname_sid[channelName]!
        let m_object:dbPacket =  self._channelsid_registry[sid]! as! dbPacket
        var m_status:Bool = false
        if(m_object.type != "s"){ throw dBError("E096") }

        if(m_object.status == ChannelStatus.UNSUBSCRIBE_INITIATED) { throw dBError("E097") }

        if(m_object.status == ChannelStatus.SUBSCRIPTION_ACCEPTED ||
            m_object.status == ChannelStatus.SUBSCRIPTION_INITIATED ||
            m_object.status == ChannelStatus.SUBSCRIPTION_PENDING ||
            m_object.status == ChannelStatus.SUBSCRIPTION_ERROR ||
            m_object.status == ChannelStatus.UNSUBSCRIBE_ERROR ){
            m_status = Util.updatedBNewtworkSC(self._dbcore, MessageType.UNSUBSCRIBE_DISCONNECT_FROM_CHANNEL, channelName, sid , "" , "", "", 0, 0)
            }

        if(!m_status) {throw  dBError("E098") }

        (self._channelsid_registry[sid] as! dbPacket).status = ChannelStatus.UNSUBSCRIBE_INITIATED
    }

    
   public func disconnect(_ channelName:String) throws {
        if (self._channelname_sid[channelName] == nil) { throw dBError("E099") }

        let  sid:String = self._channelname_sid[channelName]!
        let m_object:dbPacket =  self._channelsid_registry[sid]! as! dbPacket
        var m_status:Bool = false
        
        if(m_object.type != "c") { throw dBError("E100") }

        if(m_object.status == ChannelStatus.DISCONNECT_INITIATED) { throw dBError("E101") }

        if(m_object.status == ChannelStatus.CONNECTION_ACCEPTED ||
            m_object.status == ChannelStatus.CONNECTION_INITIATED ||
            m_object.status == ChannelStatus.CONNECTION_PENDING ||
            m_object.status == ChannelStatus.CONNECTION_ERROR ||
            m_object.status == ChannelStatus.DISCONNECT_ERROR ){
            m_status = Util.updatedBNewtworkSC(self._dbcore, MessageType.UNSUBSCRIBE_DISCONNECT_FROM_CHANNEL, channelName, sid ,  "" , "", "", 0, 0)
           }

        if(!m_status) {throw dBError("E012") }

        (self._channelsid_registry[sid] as! dbPacket).status = ChannelStatus.DISCONNECT_INITIATED
    }

    
    func dispatchEvents(_ eventName: String  ,  _ eventData:String , _  m_object:dbPacket) {
        let md:MetaData =  MetaData()
        md.eventName =  eventName
        if(m_object.type == "s") {
            let channel_object:Subscribe = m_object.ino as! Subscribe
            md.channelName =  channel_object.getChannelName()
            channel_object.emit_channelStatus(eventName, eventData, md)
            
            self._handledispatcher(eventName, eventData, md)
        }else{
            let channel_object:Connect = m_object.ino as! Connect
            md.channelName =  channel_object.getChannelName()
            channel_object.emit_channelStatus(eventName, eventData, md)
            
            self._handledispatcher(eventName, eventData, md)
        }
    }

    func dispatchEvents(_ eventName: String  ,  _ eventData:Any , _  m_object:dbPacket) {
        let md:MetaData =  MetaData()
            md.eventName =  eventName
        if(m_object.type == "s") {
            let channel_object:Subscribe = m_object.ino as! Subscribe
            md.channelName =  channel_object.getChannelName()
            channel_object.emit_channelStatus(eventName, eventData, md)
            
            self._handledispatcher(eventName, eventData, md)
        }else{
            let channel_object:Connect = m_object.ino as! Connect
            md.channelName =  channel_object.getChannelName()
            channel_object.emit_channelStatus(eventName, eventData, md)
            
            self._handledispatcher(eventName, eventData, md)
        }
    }

    
    func _handleSubscribeEvents(_ eventName:[String] , _ eventData:String , _  m_object:dbPacket)
       {
        
        for en in eventName{
            self.dispatchEvents(en ,  eventData ,  m_object)
        }
       }

    func _handleSubscribeEvents(_ eventName:[String] , _ eventData:Any , _  m_object:dbPacket)
       {
        
        for en in eventName{
            self.dispatchEvents(en ,  eventData ,  m_object)
        }
       }

    
    func _updateSubscribeStatus(_ sid:String , _ status:String , _ reason:String)
        {
        if(self._channelsid_registry[sid] ==  nil) {return}
        let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
            switch(m_object.type)
            {
                case "s":
                    let channel_object:Subscribe =  m_object.ino as! Subscribe
                    switch(status){
                    case ChannelStatus.SUBSCRIPTION_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(true)
                        let events:[String] = [systemEvents.SUBSCRIBE_SUCCESS, systemEvents.ONLINE]
                        
                            self._handleSubscribeEvents( events , "" ,  m_object)
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = status
                            
                            channel_object.set_isOnline(false)
                            let events:[String] = [systemEvents.SUBSCRIBE_FAIL]
                            
                                self._handleSubscribeEvents( events , reason ,  m_object)
                            self._channelname_sid.removeValue(forKey: m_object.name)

                            self._channelsid_registry.removeValue(forKey: sid)
                            break

                    }
                    break
                case "c":
                    let channel_object:Connect =  m_object.ino as! Connect
                    switch(status){
                    case ChannelStatus.CONNECTION_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(true)
                        let eventsc:[String] = [systemEvents.CONNECT_SUCCESS, systemEvents.ONLINE]
                        
                            self._handleSubscribeEvents( eventsc , "" ,  m_object)
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = status
                            
                            channel_object.set_isOnline(false)
                            let eventcf:[String] = [systemEvents.CONNECT_FAIL]
                            
                                self._handleSubscribeEvents( eventcf , reason ,  m_object)
                            self._channelname_sid.removeValue(forKey: m_object.name)

                            self._channelsid_registry.removeValue(forKey: sid)
                          
                            break

                    }
                    break
                default:
                    break
            }

        }
    
    
    
    
    func _updateSubscribeStatusRepeat(_ sid:String , _ status:String , _ reason:String)
        {
        if(self._channelsid_registry[sid] ==  nil) {return}
        let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
            switch(m_object.type)
            {
                case "s":
                    let channel_object:Subscribe =  m_object.ino as! Subscribe
                    switch(status){
                    case ChannelStatus.SUBSCRIPTION_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(true)
                        let events:[String] = [systemEvents.RESUBSCRIBE_SUCCESS, systemEvents.ONLINE]
                        
                            self._handleSubscribeEvents( events , "" ,  m_object)
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = status
                            
                            channel_object.set_isOnline(false)
                            let events:[String] = [systemEvents.OFFLINE]
                            
                                self._handleSubscribeEvents( events , reason ,  m_object)
                           
                    }
                    break
                case "c":
                    let channel_object:Connect =  m_object.ino as! Connect
                    switch(status){
                    case ChannelStatus.CONNECTION_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(true)
                        let eventsc:[String] = [systemEvents.RECONNECT_SUCCESS, systemEvents.ONLINE]
                        
                            self._handleSubscribeEvents( eventsc , "" ,  m_object)
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = status
                            
                            channel_object.set_isOnline(false)
                            let eventcf:[String] = [systemEvents.OFFLINE]
                            
                                self._handleSubscribeEvents( eventcf , reason ,  m_object)
                          
                            break

                    }
                    break
                default:
                    break
            }

        }
    
    
    func _updateChannelsStatusAddChange(_ life_cycle:Int, _ sid:String , _  status:String ,  _ reason:Any)
       {
           if(life_cycle == 0)  // first time subscription
           {
            if( reason is  String ){
                   self._updateSubscribeStatus(sid , status, reason as! String)
            }

           }else{ // resubscribe due to network failure
            if( reason is String ){
                   self._updateSubscribeStatusRepeat(sid , status, reason as! String)
            }
           }
       }

    
    
    func _updateChannelsStatusRemove(_ sid:String , _ status:String , _ reason:Any)
        {
        if(self._channelsid_registry[sid] ==  nil) {return}
        let m_object:dbPacket = self._channelsid_registry[sid] as! dbPacket
            switch(m_object.type)
            {
                case "s":
                    let channel_object:Subscribe =  m_object.ino as! Subscribe
                    switch(status){
                    case ChannelStatus.UNSUBSCRIBE_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(false)
                        let events:[String] = [systemEvents.UNSUBSCRIBE_SUCCESS, systemEvents.REMOVE]
                        
                            self._handleSubscribeEvents( events , "" ,  m_object)
                        self._channelname_sid.removeValue(forKey: m_object.name)

                        self._channelsid_registry.removeValue(forKey: sid)
                        
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = ChannelStatus.SUBSCRIPTION_ACCEPTED
                            
                            channel_object.set_isOnline(true)
                            let events:[String] = [systemEvents.UNSUBSCRIBE_FAIL,  systemEvents.ONLINE]
                            
                                self._handleSubscribeEvents( events , reason ,  m_object)
                            
                            break

                    }
                    break
                case "c":
                    let channel_object:Connect =  m_object.ino as! Connect
                    switch(status){
                    case ChannelStatus.DISCONNECT_ACCEPTED:
                        (self._channelsid_registry[sid] as! dbPacket).status = status
                        
                        channel_object.set_isOnline(false)
                        let eventsc:[String] = [systemEvents.DISCONNECT_SUCCESS, systemEvents.REMOVE]
                        
                            self._handleSubscribeEvents( eventsc , "" ,  m_object)
                        self._channelname_sid.removeValue(forKey: m_object.name)

                        self._channelsid_registry.removeValue(forKey: sid)
                            break
                        default:
                            (self._channelsid_registry[sid] as! dbPacket).status = ChannelStatus.CONNECTION_ACCEPTED
                            
                            channel_object.set_isOnline(true)
                            let eventcf:[String] = [systemEvents.DISCONNECT_FAIL, systemEvents.ONLINE]
                            
                                self._handleSubscribeEvents( eventcf , reason ,  m_object)
                            break

                    }
                    break
                default:
                    break
            }

        }
    
    
    func _isonline( _ sid:String)->Bool
    {
        if(self._channelsid_registry[sid] == nil) {return false}
        let m_object:dbPacket =  self._channelsid_registry[sid] as! dbPacket
        if(m_object.status == ChannelStatus.CONNECTION_ACCEPTED || m_object.status == ChannelStatus.SUBSCRIPTION_ACCEPTED) { return true}
           return false
       }

    
    public func isOnline(_ channelName: String) ->Bool
    {
        if(self._channelname_sid[channelName] == nil) {return false}
        if(!self._dbcore._isSocketConnected()) {return false}
        let sid:String = self._channelname_sid[channelName]!
        return self._isonline(sid)
    }
    
    
    public func list() -> [ChannelInfo]
    {
        var linfo:[ChannelInfo] = []
        for (key , value) in self._channelsid_registry {
            
            let dbpacket:dbPacket = value as! dbPacket
            let sname:String =  dbpacket.name
            let stype:String
            if (dbpacket.type == "s"){
                stype = "subscribed"
                
            }else{
            stype = "connect"
            }
            let sisonline:Bool =  self._isonline(key)
            let info:ChannelInfo = ChannelInfo(name: sname , type: stype, isonline: sisonline)
            linfo.append(info)
        }
        return linfo
    }

    
    func _send_OfflineEvents(){
        for (_ , value) in self._channelsid_registry {
            let dbpacket:dbPacket = value as! dbPacket
            let md:MetaData =  MetaData()
            md.channelName =  dbpacket.name
            md.eventName = systemEvents.OFFLINE
           
            if (dbpacket.type == "s")
            {
                let channel_object:Subscribe  =  dbpacket.ino as! Subscribe
                channel_object.set_isOnline(false)
            }else{
                let channelnbd_object:Connect = dbpacket.ino as! Connect
                channelnbd_object.set_isOnline(false)
            }
            
            self._handledispatcher(systemEvents.OFFLINE,"", md)
        }
    }

    
    
    func _get_subscribeStatus(_ sid:String)->String
    {
        if(self._channelsid_registry[sid] == nil) {return ""}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.status
    }
    
    
    func _get_channelType(_ sid:String)->String{
        
        if(self._channelsid_registry[sid] == nil) {return ""}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.type
        
    }
    
    
    func _get_channelName(_ sid:String)->String{
        
        if(self._channelsid_registry[sid] == nil) {return ""}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.name
        
    }
    
  
    func getConnectStatus(_ sid:String)->String{
        
        if(self._channelsid_registry[sid] == nil) {return ""}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.status
        
    }
   
    
    func getChannel(_ sid:String)->Any?{
        
        if(self._channelsid_registry[sid] == nil) {return nil}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.ino
        
    }
    
    
    
    func getChannelName(_ sid:String)->String{
        
        if(self._channelsid_registry[sid] == nil) {return ""}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        return dbpacket.name
        
    }
    
    
    func isSubscribedChannel(_ sid:String)->Bool{
        
        if(self._channelsid_registry[sid] == nil) {return false}
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        if (dbpacket.type == "s")
        {
            let channel_object:Subscribe  =  dbpacket.ino as! Subscribe
            return channel_object.isOnline()
        }
        return false
    }
    
    
    
    func clean_channel(_ sid:String){
        
        if(self._channelsid_registry[sid] == nil) {return }
        let dbpacket:dbPacket = self._channelsid_registry[sid] as! dbPacket
        if (dbpacket.type == "s")
        {
            let channel_object:Subscribe  =  dbpacket.ino as! Subscribe
            channel_object.unbind()
            channel_object.unbind_all()
        }else{
            let channel_object:Connect  =  dbpacket.ino as! Connect
            channel_object.unbind()
        }
    
    }
   
    
    func cleanUp_All(){
        for (key , value) in self._channelsid_registry {
            let dbpacket:dbPacket = value as! dbPacket
            let md:MetaData =  MetaData()
            md.channelName =  dbpacket.name
            md.eventName = systemEvents.REMOVE
            self._handledispatcher(systemEvents.REMOVE,"", md)
            self.clean_channel(key)
            self._channelname_sid.removeValue(forKey: dbpacket.name)
            self._channelsid_registry.removeValue(forKey:key)
        }
    }

    

    
}
