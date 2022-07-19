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


public class ServerMetaData
{
    
    
    
    private var _serverName:String
    var serverName:String {
        get {return _serverName }
        set {_serverName =  newValue}
    }
    
    private var  _eventName:String
    var  eventName:String {
        get {return _eventName }
        set {_eventName =  newValue }
    }
    
    private var _sourcesysid:String
    var sourcesysid:String {
        get {return _sourcesysid }
        set { _sourcesysid = newValue }
        
    }
    
    
    private var  _seqnum:String
    var  seqnum:String {
        get {return _seqnum}
        set {_seqnum =  newValue}
    }
    
    private var _sessionid:String
    var sessionid:String {
        get {return _sessionid}
        set {_sessionid = newValue}
        
    }
    
    private var _intime:Int64
    public var intime:Int64{
        get{return _intime}
        
    }
    
    
  public init()
  {
       self._serverName = ""
       self._eventName = ""
       self._sourcesysid = ""
       self._seqnum = ""
       self._sessionid = ""
       self._intime = Int64((Date().timeIntervalSince1970 * 1000).rounded())
 }

    public init(_ Name:String , _ eventName:String)
    {
        self._serverName = Name
        self._eventName = eventName
        self._sourcesysid = ""
        self._seqnum = ""
        self._sessionid = ""
        self._intime = Int64((Date().timeIntervalSince1970 * 1000).rounded())
    }
 
    public init(_ Name:String , _ eventName:String ,  _ sourcesysid:String , _ seqnum:String, _ sessionid:String ,  intime:Int64)
    {
        self._serverName = Name
        self._eventName = eventName
        self._sourcesysid = sourcesysid
        self._seqnum = seqnum
        self._sessionid = sessionid
        self._intime = intime
    }
    
    
    
    public func ToString() -> String
    {
        var m_tempstring:String = ""
        m_tempstring = "{serverName:\"" +  self._serverName + "\"" +
            ", eventName:\"" +  self._eventName +  "\"" +
            ", sourceid:\"" +  self._sourcesysid +  "\"" +
            ", sqnum:\"" +  self._seqnum +  "\"" +
            ", sessionid:\"" +  self._sessionid +  "\"" +
            ", intime:\"" +  String(self._intime) +  "\"}"
        
        return m_tempstring
    }
}
