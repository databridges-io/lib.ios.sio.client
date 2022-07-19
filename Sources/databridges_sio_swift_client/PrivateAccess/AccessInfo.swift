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


public class AccessInfo: Decodable{
    public var statuscode: Int
    public  var error_message: String
    public var accesskey: String
    
   public init() {
        self.statuscode =  9
        self.error_message = "unknown error"
        self.accesskey = ""
    }
    
   
   public init(_ scode: Int , _ error_message: String, _ accesskey: String) {
        self.statuscode = scode;
        self.error_message = error_message;
        self.accesskey = accesskey;
    }

    
}
