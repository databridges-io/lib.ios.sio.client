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

public class APIResponce
{
  public var secured:Bool
  public var wsip:String
  public var wsport:String
  public var sessionkey:String
  public var statuscode:Int
  public var reasonphrase:String


   public init()
   {
       self.secured = false
       self.wsip = ""
       self.wsport = ""
       self.sessionkey = ""
       self.statuscode = 0
       self.reasonphrase = ""
   }

   public func update(_ statuscode:Int, _ reasonphrase:String)
   {
       self.statuscode = statuscode
       self.reasonphrase = reasonphrase
   }
    
    public func update(_ json: [String: Any])
    { 
         let secured = json["secured"] as? Bool
        let wsip = json["wsip"] as? String
        let wsport = json["wsport"] as? String
        let sessionkey = json["sessionkey"] as? String
        let statuscode = 200
        let reasonphrase = ""

        self.secured = secured ?? false
        self.wsip = wsip ?? ""
        self.wsport = wsport ?? ""
        self.sessionkey = sessionkey ?? ""
        self.statuscode = statuscode 
        self.reasonphrase = reasonphrase
         
        
    }
    
    
    public func  ToString()->String
    { 
        
     let m_tempstring = "{secured: \"" + String(self.secured) + "\"," +
         "wsip: \"" + self.wsip + "\" ," +
         "wsport: \"" + self.wsport + "\"," +
        "sessionkey: \"" + self.sessionkey + "\" ," +
        "statuscode: \"" + String(self.statuscode) + "\" ," +
        "reasonphrase: \"" + self.reasonphrase +  "\" }"
        
             
     return m_tempstring;
    }

    
}
