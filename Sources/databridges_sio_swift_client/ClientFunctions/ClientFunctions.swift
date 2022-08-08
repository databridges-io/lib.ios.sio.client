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


public class ClientFunctions{ 
    
    private var _dispatch:EventDispatcher
    private var _dbcore:databridges_sio_swift_client
    public var enable:Bool
    public var functions:dBClientFunctions?
    private var _functionNames:[String] 
    
    public init(_ dbcore: databridges_sio_swift_client)
    {
        self._dispatch = EventDispatcher()
        self._dbcore =  dbcore
        self.enable = false
        self.functions =  nil
        self._functionNames =  ["cf.response.tracker", "cf.callee.queue.exceeded"]
    }
    
    
    public func _verify_function() throws -> Bool {
        var mflag:Bool = false;
        if (self.enable) {
            if(self.functions == nil) {
                throw (dBError("E009"))
            }
             
            mflag =  true
        }else{
          mflag = true
        }
        return mflag;
      }
    
    
    
    public func regfn(_ functionName:String, _ callback:  @escaping  dBInFunction) throws {
        if (functionName.isEmpty) { throw dBError("E110") } 
        if (self._functionNames.contains(functionName)) { throw dBError("E110") }
        try self._dispatch.bind(functionName, callback)
        
    }
    
    
    public func unregfn(_ functionName: String ) {
        if(self._functionNames.contains(functionName)) { return }
        self._dispatch.unbind(functionName);
      }

    
    public func bind(_ functionName:String, _ callback:  @escaping  dBInFunction) throws {
        if (functionName.isEmpty) { throw dBError("E066") } 
        if (self._functionNames.contains(functionName)) { throw dBError("E066") }
        try self._dispatch.bind(functionName, callback)
        
    }
    
    public func unbind(_ functionName: String) {
        if(self._functionNames.contains(functionName)) { return }
        self._dispatch.unbind(functionName);
      }

    

    
    public func _handle_dispatcher(_ functionName:String, _ returnSubect: String, _ sid: String, _ payload: String) {
        let response = RpcResponse("CF", functionName, returnSubect, sid, self._dbcore)
        self._dispatch.emit_clientfunction(functionName, payload, response)
      }
    
    
    public func _handle_tracker_dispatcher(_ responseid: String, _ errorcode: String) {

        self._dispatch.emit_clientfunction("cf.response.tracker", responseid, errorcode)
      }

      public func _handle_exceed_dispatcher() {
        let err = dBError("E070");
        err.updateCode("CALLEE_QUEUE_EXCEEDED")
        self._dispatch.emit_clientfunction("cf.callee.queue.exceeded", err, "")
      }

      public func resetqueue() throws {
        let m_status  = Util.updatedBNewtworkCF(self._dbcore, MessageType.CF_CALLEE_QUEUE_EXCEEDED, "", "", "", "", "", false, false)
        if (!m_status) { throw  dBError("E068") }
      }

    
    
    
}
