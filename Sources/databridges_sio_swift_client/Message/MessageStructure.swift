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

public class MessageStructure
{
    public let eventname: String = "db"
    public var dbmsgtype: Int
    public var subject: String?
    public var rsub: String?
    public var sid: String?
    public var payload: String?
    
    public var fenceid: String?
    public var rspend: Bool?
    public var rtrack: Bool?
    public var rtrackstat: String?
    public var t1: Int64?
    public var latency: Int64?
    public  var globmatch: Int?
    public var sourceid: String?
    public var sourceip: String?
    public var replylatency: Int?
    public var oqueumonitorid: String?

    init() {
        self.dbmsgtype =  MessageType.SYSTEM_MSG
        self.subject=""
        self.rsub=""
        self.sid=""
        self.payload=nil
        
        self.fenceid=""
        self.rspend=false
        self.rtrack=false
        self.rtrackstat=""
        self.t1=0
        self.latency=0
        self.globmatch=0
        self.sourceid=""
        self.sourceip=""
        self.replylatency=0
        self.oqueumonitorid=""
    }
    
    public func getString(_ inPartmessage: Any? ) -> String? {
        if( (inPartmessage is NSNull) || (inPartmessage == nil)){
            return ""
        }else{
            let newDetail:String = String(format: "%@", inPartmessage as! CVarArg)
            if newDetail.isEmpty{
                return ""
            }else{
                return newDetail
            }
                
        }
    }
    
    
    public func getArraytoString(_ inPartmessage: Data) -> String?{
        if( (inPartmessage.isEmpty) || (inPartmessage is NSNull)){
            return ""
        }else{
            let s:String = String(decoding: inPartmessage , as: UTF8.self)
            if s.isEmpty {
                return ""
            }else{
              return  s;
            }
           
        }
    }
   
    
    public func getBool(_ inPartmessage: Any? ) -> Bool {
        if( (inPartmessage is NSNull) || (inPartmessage == nil)){
            return false
        }else{
            return (inPartmessage as? Bool)!
        }
    }
    
    public func getInt64(_ inPartmessage: Any? ) -> Int64 {
        if( (inPartmessage is NSNull) || (inPartmessage == nil)){
            return 0
        }else{
            return (inPartmessage as? Int64)!
        }
    }
    
    public func getInt(_ inPartmessage: Any? ) -> Int {
        if( (inPartmessage is NSNull) || (inPartmessage == nil)){
            return 0
        }else{
            return (inPartmessage as? Int)!
        }
    }
    
    
    public  func Parse(_ inmessage: [Any])
    {
        for index in 0...inmessage.count-1{
            switch index {
            case 0:
                self.dbmsgtype =  (inmessage[0] as? Int)!
                break
            case 1:
                self.subject = getString(inmessage[1]) 
                break
            case 2:
            
                self.rsub = getString(inmessage[2]) 
                break
            case 3:
                self.sid =  getString(inmessage[3]) 
                break
            case 4:
                if inmessage[4] is NSNull{
                    self.payload = ""
                }else{
                self.payload = getArraytoString( inmessage[4] as! Data)
                }
                break
            case 5:
                self.fenceid = getString(inmessage[5])
                break
            case 6:
                self.rspend = getBool(inmessage[6])
                break
            case 7:
                self.rtrack = getBool(inmessage[7])
                break
            case 8:
                self.rtrackstat =  getString(inmessage[8])
                break
            case 9:
                self.t1 =  getInt64(inmessage[9])
                break
            case 10:
                self.latency = getInt64(inmessage[10])
                break
            case 11:
                self.globmatch = getInt(inmessage[11])
                break
            case 12:
                self.sourceid =  getString(inmessage[12])
                break
            case 13:
                self.sourceip = getString(inmessage[13])
                break
            case 14:
                self.replylatency = getInt(inmessage[14])
                break
            case 15:
                self.oqueumonitorid = getString(inmessage[15])
                break
            default:
                break
            }
        }
    }
}
