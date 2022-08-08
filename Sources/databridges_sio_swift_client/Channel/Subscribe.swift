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
import PromiseKit

public class Subscribe: EventDispatcher {
    var  _channelName:String
    var _sid:String
    var  _dbcore:databridges_sio_swift_client
    var _isOnline: Bool;
   // var _dispatch: dispatcher;
    let ccSupportedFunctions:[String] = [
           "channelMemberList",
           "channelMemberInfo",
           "timeout" ,
           "err"
       ]

    init(_ channelName:String, _ sid: String , _ dBCoreObject: databridges_sio_swift_client)
    {
        self._channelName = channelName;
        self._sid = sid;
        self._dbcore = dBCoreObject;
        self._isOnline = false;
       // self._dispatch = dispatcher();
    }

    public func getChannelName()->String{
        return self._channelName;
    }

    public func  isOnline()->Bool {
        return self._isOnline;
    }

    public func set_isOnline(_ value:Bool) {
        self._isOnline = value;
    }


    public func publish(_ eventName: String  , _ eventData: String, _ seqnum: Int64) throws  {
        if !self._isOnline { throw dBError("E014" ) }
        
        if self._channelName.lowercased() == "sys:*" { throw  dBError("E015") }
        
        if eventName.isEmpty { throw dBError("E058") }
        
        let m_status:Bool = Util.updatedBNewtworkSC(self._dbcore, MessageType.PUBLISH_TO_CHANNEL, self._channelName, "", eventData, eventName, "", 0, seqnum);
        if !m_status {throw dBError("E014") }
        return;
    }

    public func publish(_ eventName: String  ,_ eventData:String) throws {
    if !self._isOnline { throw dBError("E014" ) }
    
    if self._channelName.lowercased() == "sys:*" { throw  dBError("E015") }
    
    if eventName.isEmpty { throw dBError("E058") }
    
        let m_status:Bool = Util.updatedBNewtworkSC(self._dbcore, MessageType.PUBLISH_TO_CHANNEL, self._channelName, "", eventData, eventName, "", 0, 0);
    
    if !m_status {throw dBError("E014") }
        return;
    }

public func call(_ functionName: String, _ inparameter: String, _ ttlms: Int, _ progress_callback: @escaping dBProgress)  -> Promise<Any> {
        let (promise, resolver) = Promise<Any>.pending()
        
        if ccSupportedFunctions.contains(functionName) {
            if (self._channelName.lowercased().starts(with: "prs:") ||
                    self._channelName.lowercased().starts(with: "sys:")) {
                let caller: RpcClient = (self._dbcore.rpc?.ChannelCall(self._channelName))!;
                caller.call(functionName, inparameter, ttlms, progress_callback)
                .done { data in
                    resolver.fulfill(data)
                }.catch{ error in
                    resolver.reject(error)
                }
                    

            }else {
                resolver.reject( dBError("E039"));
            }
        }else{
            resolver.reject ( dBError("E038"));
        }
        return promise
    }
}
