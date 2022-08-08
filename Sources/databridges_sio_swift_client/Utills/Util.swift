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

public class Util
{
    
   static func stringTOArray(_ data:String)-> [UInt8] {
        var buffer: [UInt8];
        
        if !data.isEmpty{
            let bytes = data.utf8
             buffer = [UInt8](bytes)
        }else{
            let bytes = "".utf8
            buffer = [UInt8](bytes)
        }
        return buffer
    }

   static func GenerateUniqueId(_ len:Int)->String{
        var number = String()
        for _ in 1...len{
            number += "\(Int.random(in: 1...9))"
        }
        return number
    }

    
   static func updatedBNewtworkSC(_ dbcore: databridges_sio_swift_client , _ dbmsgtype: Int , _ channelName: String , _ sid: String, _ channelToken: String, _ subject: String , _ source_id: String, _ t1: Int64, _ seqnum: Int64)->Bool{
        
        
        var tseqnum:String = ""
        tseqnum =  (seqnum == 0) ? "" : String(seqnum)
        
    var nsid:Int32? = 0
    if (!sid.isEmpty) { nsid = Int32(sid)}
    
    let  msgDbp:[Any] = [
             dbmsgtype,
            (subject.isEmpty) ? NSNull() : subject ,
            NSNull(),
            sid,
            (channelToken.isEmpty) ? Data("".utf8) : Data( channelToken.utf8),
            channelName,
            NSNull(),
            NSNull(),
            NSNull(),
            (t1 == 0) ? NSNull() :  t1,
            NSNull(),
            0,
            (source_id.isEmpty) ? NSNull() :  source_id,
            NSNull(),
            NSNull(),
        (tseqnum.isEmpty) ? NSNull() :  tseqnum]
        
            return dbcore.send(msgDbp)
        }

    static func  updatedBNewtworkCF(_ dbcore: databridges_sio_swift_client, _ dbmsgtype: Int, _ sessionid: String, _ functionName: String, _ returnSubject: String, _ sid: String, _ payload: String, _ rspend: Bool, _ rtrack: Bool) ->Bool {
        
        let msgDbp:[Any] = [
          dbmsgtype,
          functionName,
          returnSubject,
          sid,
          (payload.isEmpty) ? Data("".utf8) : Data( payload.utf8),
          sessionid,
          rspend,
          rtrack,
          "",
          0,
          0,
          0,
          "",
          "",
          0,
          ""]
        return dbcore.send(msgDbp)
      }
}

