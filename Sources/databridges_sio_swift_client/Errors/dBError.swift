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


public class dBError : Error
{
    public var  source: String = ""
    public var  code: String = ""
    public var  message: String = ""
    private var _EKEY: String = ""
    
    
    

    private func updateClassProperty(_ ekey:String, _ source:String, _ code:String, _ message:String)
    {
       self._EKEY = ekey;
       self.source = source;
       self.code = code;
       self.message = message;

    }

    public init (_ ekey:String, _ codeext: String = "",  _ message:String = "")
   {
       self.updateClassProperty("", "", "", "");

       if (!ErrorMessage.keys.contains(ekey))
       {
           self.updateClassProperty(ekey, ekey, ekey, "key is missing from the lookup tables. contact support");
           return;
       }
       
        let value:[Int] = ErrorMessage[ekey] ?? []
        if(value.count != 2)
       {
           self.updateClassProperty(ekey, ekey, ekey, "key , value structure is invalid. contact support");
           return;
       }


        if (!SourceLookUp.keys.contains(value[0])){
           self.updateClassProperty(ekey, String(value[0]), "", "source lookup key is invalid. contact support");
           return;
       }

       if (!CodeLookUp.keys.contains(value[1]))
       {
        self.updateClassProperty(ekey, SourceLookUp[value[0]] ?? "", String(value[1]), "code lookup key is invalid. contact support");
           return;
       }

        self.updateClassProperty(ekey, SourceLookUp[value[0]] ?? "" , CodeLookUp[value[1]] ?? "" , "");


        if(!codeext.isEmpty)
       {
            if(!(self.code.hasSuffix("_")))
           {
               self.code = self.code + "_" + codeext;
           }
           else
           {
               self.code = codeext;
           }
       }

       if(!message.isEmpty){
           self.message = message;
       }

   }

    public func updateCode( _ code:String,  _ message:String = "")
    {
        if(!code.isEmpty){
            if  (!code.isEmpty)
           {
                if(self.code.isEmpty)
               {
                   self.code = code;
               }
               else
               {
                   if (!self.code.hasSuffix("_"))
                   {
                       self.code = self.code + "_" + code;
                   }
                   else
                   {
                       self.code = self.code + code;
                   }
               }
          }
      }
      if(!message.isEmpty){
        self.message = message;
      }

   }

   public func GetEKEY()->String
   {
       return self._EKEY;
   }


   public func  ToString()->String
   {
    var m_tempstring:String = ""
    m_tempstring = "{source: \"" + self.source + "\" ," +
        "code: \"" + self.code + "\" ," +
        "message: \"" + self.message + "\" }"
            
    return m_tempstring;
   }

}
