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


public class ConnectionState
{
    private var _state: String;
    private var _isconnected:  Bool;
    private var _rttms: Int64;

    public func state(_ value: String){
        self._state = value
    }
    
    public func state()->String{
        return _state
    }
    
    public func isconnected()->Bool{
        return _isconnected
    }

    public func rttms()->Int64{
        return _rttms
    }

    
    public func rttms(_ value: Int64){
        self._rttms =  value
    }
    
    private var newLifeCycle:Bool
    public var reconnect_attempt:Int
    private var  dbcore:databridges_sio_swift_client
    private static let no_changelist:[String] = [ "reconnect_attempt", "rttpong", "rttping" ]

    private let registry:EventDispatcher;
    
    public init(_ dBCoreObject:databridges_sio_swift_client)
    {
        self._state = "";
        self._isconnected = false;
        // this.registry = new dispatcher();
        self.registry = EventDispatcher()
        self.newLifeCycle = true;
        self.reconnect_attempt = 0;
        self.dbcore = dBCoreObject;
        self._rttms = 0;
    }

    
    public func rttping(_ payload:String = "") throws
    {
        let t1:Int64 =  Int64((Date().timeIntervalSince1970 * 1000).rounded())
      
        
        let m_status:Bool = Util.updatedBNewtworkSC(self.dbcore, MessageType.SYSTEM_MSG,
                                                    "", "", payload, "rttping", "", t1, 0)
        if (!m_status){
            throw  dBError("E011")
        }
    }
        
    public func set_newLifeCycle(_ value:Bool)
    {
        self.newLifeCycle = value
    }

    public func get_newLifeCycle() ->Bool
    {
       return self.newLifeCycle
    }
    
    
    public func bind(_ eventName:String , _ callback: @escaping  dBConnectCallBack) throws
    {
               //console.log(eventName);

        if (eventName.isEmpty)  {
           throw  dBError("E012")
       }

     

        if(!States.supportedEvents.contains(eventName)){
            throw  dBError("E013")
       }
       
       try self.registry.bind(eventName , callback)
   }

    
    
    public func unbind()
    {
        self.registry.unbind();
    }

    public func unbind(_ eventName:String, _ callback : @escaping dBConnectCallBack)
    {
        self.registry.unbind(eventName, callback);
    }

    

    public func updatestates(_ eventName: String)
    {

        if ( (eventName == States.CONNECTED) ||
             (eventName == States.RECONNECTED) ||
             (eventName == States.RTTPONG) ||
             (eventName == States.RTTPING) ){
            self._isconnected = true;
        }
        else{
            self._isconnected = false;
        }

    }


    public func handledispatcher(_ eventName:String , _ eventInfo:Any?)
    {
        let previous:String = self._state;

        if (!ConnectionState.no_changelist.contains(eventName))
        {
                self._state = eventName;
        }

            self.updatestates(eventName);
            if (eventName != previous)
            {
                if (!ConnectionState.no_changelist.contains(eventName))
                {
                    if (!ConnectionState.no_changelist.contains(previous))
                    {
                        let sc:StateChange = StateChange(previous, eventName);
                        self._state = eventName;
                        self.registry.emit_connectionState(States.STATE_CHANGE, sc)
                    }
                }
            }

            if (eventInfo != nil) {
                self.registry.emit_connectionState(eventName, eventInfo);
            }
            else
            {
                self.registry.emit_connectionState(eventName);
            }
        if (eventName == "reconnected") {
            self._state = "connected"
        }
    }

    
}
