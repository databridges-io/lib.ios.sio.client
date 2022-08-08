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

public class RpcResponse{
    private var type:String
    private var _functionName:String
    private var _returnSubsect:String
    private var _sid: String
    private var _dbcore:databridges_sio_swift_client
    private var _isend: Bool
    private var _id:String
    public var tracker: Bool
    
    public init(_ type: String , _ functionName: String, _ returnSubect: String, _ sid: String, _ dbcoreobject: databridges_sio_swift_client){
        self.type = type
        self._functionName = functionName
        self._returnSubsect = returnSubect
        self._sid = sid
        self._dbcore = dbcoreobject
        self._isend = false
        self._id = returnSubect
        self.tracker = false
    }
    
    public func id()->String{
        return self._id
    }
    
    public func next(_ data: String) throws {
        let cstatus:Bool
       if (!self._isend) {
        if (self.type ==  "CF"){
            cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.CF_CALL_RESPONSE, "", self._returnSubsect, "", self._sid, data, self._isend, self.tracker)
        }else{
            cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.RPC_CALL_RESPONSE, "", self._returnSubsect, "", self._sid, data, self._isend, self.tracker)
        }
        
        if(!cstatus){
            if (self.type ==  "CF"){
                throw dBError("E068")
            }else{
                throw dBError("E079")
            }
        }
        
       }else{
        if (self.type ==  "CF"){
            throw dBError("E105")
        }else{
            throw dBError("E106")
        }
       }
        
        
    }
    
    
    public func end(_ data:String) throws {
        let cstatus:Bool
        if (!self._isend) {
            self._isend =  true
            if (self.type ==  "CF"){
                cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.CF_CALL_RESPONSE, "", self._returnSubsect, "", self._sid, data, self._isend, self.tracker)
            }else{
                cstatus = Util.updatedBNewtworkCF(self._dbcore, MessageType.RPC_CALL_RESPONSE, "", self._returnSubsect, "", self._sid, data, self._isend, self.tracker)
            }
            
            if(!cstatus){
                if (self.type ==  "CF"){
                    throw dBError("E068")
                }else{
                    throw dBError("E079")
                }
            }
        }else{
            if (self.type ==  "CF"){
                throw dBError("E105")
            }else{
                throw dBError("E106")
            }
        }
    }
    
    public func exception(_ errorCode: String, _ errorMessage: String) throws {
        do {
            let data:[String:String] =  [ "c": errorCode, "m": errorMessage ]
            
            try self.end(data.description)
        }catch {
            throw error
        }
    }
    
    
    
}
