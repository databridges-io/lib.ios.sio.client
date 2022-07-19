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


public class AccessResponse {
    var dbobject: Any   //channels dbchannel;
    var Name: String;
    var sid: String;
    var mtype: Int;

   public init(_ mtype: Int , _ Name: String, _ sid: String ,  _ dbobject: Any) {
        self.dbobject = dbobject;
        self.mtype = mtype;
        self.Name = Name;
        self.sid =  sid;
    }
    
   public func end(_ data:AccessInfo){
       if self.dbobject is Channels{
            let caller = self.dbobject as! Channels
            caller._send_to_dbr(self.mtype ,  self.Name , self.sid , data );
        }
        
       if self.dbobject is Rpc{
           let caller = self.dbobject as! Rpc
            caller._send_to_dbr(self.mtype ,  self.Name , self.sid , data );
    }
        
        
    }

    public func exception(_ info:String){
        let accessinfo:AccessInfo = AccessInfo(9, info , "")
        self.end(accessinfo)
    }
}

