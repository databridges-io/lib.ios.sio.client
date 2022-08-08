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


public class RpcClient{
    private var _dispatch:EventDispatcher
    private var _dbcore: databridges_sio_swift_client
    private var _rpccore: Rpc

    private var _sid_functionname:[String:String]
    private var _serverName: String
    private var _isOnline: Bool
    private var _callerTYPE: String
    
    
    public init(_ serverName: String, _ dBCoreObject: databridges_sio_swift_client , _ rpccoreobject: Rpc, _ callertype: String) {
        self._dispatch =  EventDispatcher()
        self._serverName =  serverName
        self._dbcore =  dBCoreObject
        self._rpccore =  rpccoreobject
        self._isOnline =  false
        self._callerTYPE = callertype
        self._sid_functionname = [:]
    }
    
    
    
    public init(_ serverName: String, _ dBCoreObject: databridges_sio_swift_client , _ rpccoreobject: Rpc) {
        self._dispatch =  EventDispatcher()
        self._serverName =  serverName
        self._dbcore =  dBCoreObject
        self._rpccore =  rpccoreobject
        self._isOnline =  false
        self._callerTYPE = "RPC"
        self._sid_functionname = [:]
    }
    
    
    public func  getServerName() -> String{
         return self._serverName
     }

    public func isOnline() ->Bool {
         return self._isOnline
     }

    public func set_isOnline(_ value: Bool) {
         self._isOnline = value
     }

    
    public func bind(_ eventName: String , _ handler: @escaping dBInFunction) throws  {
        if eventName.isEmpty { throw dBError("E076") }
            
        try self._dispatch.bind(eventName , handler)
    }

    
    
    public func bind(_ eventName: String , _ handler: @escaping dBInFunction2) throws  {
        if eventName.isEmpty { throw dBError("E076") }
            
        try self._dispatch.bind(eventName , handler)
    }
    
    public func unbind(_ eventName: String) {
            self._dispatch.unbind(eventName)
    }
    public func unbind() {
            self._dispatch.unbind()
    }
    
    
    public func unbind_all() {
            self._dispatch.unbind_all()
    }
    
    public func _handle_callResponse(_ sid:String, _ payload:String?, _ isend:Bool, _ rsub:String?) {
        if (self._sid_functionname[sid] != nil) {

            self._dispatch.emit_rpcFunction(sid, payload, isend, rsub!)
        }
    }

    public func  _handle_tracker_dispatcher(_ responseid:String, _ errorcode: String) {
        self._dispatch.emit_rpcFunction("rpc.response.tracker", responseid, errorcode)
    }

   public func  _handle_exceed_dispatcher() {
    let err:dBError =  dBError("E054")
    err.updateCode("CALLEE_QUEUE_EXCEEDED", "");
        self._dispatch.emit_rpcFunction("rpc.callee.queue.exceeded", err, nil)
    }


    public func emit_rpcStatus(_ eventName: String ,  _ payload: Any,  _ metadata: ServerMetaData){
          self._dispatch.emit_rpcStatus(eventName ,  payload,  metadata)
         
      }

    
    
    private  func combineGetUniqueSid(_ sid: String) -> String{
        var nsid:String =  Util.GenerateUniqueId(6)
        if(self._sid_functionname[nsid] != nil){
            nsid =  Util.GenerateUniqueId(6)
        }
        return nsid;
    }

    public func cleanup(_ sid:String)
    {
        self._dispatch.unbind(sid);
        self._sid_functionname.removeValue(forKey: sid)
    }

    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                //print(error.localizedDescription)
            }
        }
        return nil
    }
    
    
    public func _call_internal(_ sessionid:String, _ functionName: String, _ inparameter: String, _ sid: String, _ progress_callback: @escaping dBProgress) -> Promise<Any>{
        let (promise, resolver) = Promise<Any>.pending()
        
        let cstatus:Bool
        if (self._callerTYPE == "rpc") {
            cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.CALL_RPC_FUNCTION_OR_RECEIVED, sessionid, functionName, "", sid, inparameter,false ,false )
        } else {
            cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.CALL_CHANNEL_RPC_FUNCTION, sessionid, functionName, "", sid, inparameter ,  false, false)
        }
        if (!cstatus) {
            if (self._callerTYPE == "rpc") {
                resolver.reject( dBError("E079"))
            } else {
                resolver.reject( dBError("E033"))
            }
        }
        
        do{
            try self.bind(sid, { ( response:Any, rspend: Bool, rsub:String) in
            let dberror:dBError
            let eobject:[String:Any]?
               if (!rspend) {
                  progress_callback(response as! String)
               } else {
                if (!rsub.isEmpty) {
                    switch (rsub.uppercased()) {
                       case "EXP": //exception from callee
                        let mstrresponse : String = response as! String
                        eobject = self.convertToDictionary(text: mstrresponse)
                         if (self._callerTYPE == "rpc") {
                           dberror = dBError("E055")
                            dberror.updateCode(eobject!["c"] as! String, eobject!["m"] as! String)
                            resolver.reject(dberror)
                         } else { //Channel call
                           dberror =  dBError("E041")
                           dberror.updateCode(eobject!["c"] as! String, eobject!["m"] as! String)
                            resolver.reject(dberror)
                         }
                         break;
                       default: // DBNET ERROR
                         if (self._callerTYPE == "rpc") {
                           dberror =  dBError("E054")
                           dberror.updateCode(rsub.uppercased(), "")
                            resolver.reject(dberror)
                         } else { //Channel call
                           dberror =  dBError("E040")
                           dberror.updateCode(rsub.uppercased(), "")
                            resolver.reject(dberror)
                         }
                         break
                   }

                 } else {
                    resolver.fulfill(response)
                 }
                 self.unbind(sid)
                 self._sid_functionname.removeValue(forKey: sid)
               }
            
        })
        } catch let err{
            resolver.reject(err)
        }
        return promise
    }
    
    
    public func timeout(_ ttlms: Int) -> Promise<Any> {
        let (promise, resolver) = Promise<Any>.pending()
        after(.milliseconds(ttlms)).done {
            if (self._callerTYPE == "rpc") {
                resolver.reject(dBError("E080"))
            }else{
                resolver.reject(dBError("E042"))
            }
            
            }
        return promise
    }
    
    
    
    public func call(_ functionName: String, _ inparameter: String, _ ttlms: Int, _ progress_callback: @escaping dBProgress) -> Promise<Any> {
        let (promise, resolver) = Promise<Any>.pending()
        
        var sid :String = ""
        var sid_created :Bool = true
        var loop_index:Int = 0
        let loop_counter: Int = 3
        var mflag: Bool = false
        sid = Util.GenerateUniqueId(6)

        repeat {
            if (self._sid_functionname[sid] != nil) {
                sid = self.combineGetUniqueSid (sid)
                   loop_index +=  1
                 } else {
                   self._sid_functionname[sid] =  functionName
                   mflag = true
                 }
            
            
        }while ((loop_index < loop_counter) && (!mflag))
        
        if (!mflag) {
              sid = self.combineGetUniqueSid(sid);
              if (self._sid_functionname[sid] == nil) {
                self._sid_functionname[sid] = functionName
              } else {
                sid_created = false
              }
            }

            if (!sid_created) {
              if (self._callerTYPE == "rpc") {
                resolver.reject (dBError("E108"))
              } else {
                resolver.reject( dBError("E109")) //need to change this 109
              }
            }

        self._rpccore.store_object(sid, self)

        
        
        PromiseKit.race([self._call_internal(self._serverName, functionName, inparameter, sid , progress_callback) ,  self.timeout(ttlms)])
            .done{ data in
                resolver.fulfill(data)
            }.catch{ error in
                resolver.reject(error)
            }
        
        return promise
    }
    
    
    
}
