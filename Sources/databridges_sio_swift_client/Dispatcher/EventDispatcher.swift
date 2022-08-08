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



public typealias dBConnectCallBack = (Any) -> ()
public typealias dBChannelCallBack =  (Any ,  MetaData) -> ()
public typealias dBAccessToken =  (String ,  String , String ,  Any) -> ()
public typealias dBClientFunctions = () -> ()
public typealias dBInFunction = (Any ,  Any) -> ()
public typealias dBInFunction2 = (Any ,  Bool ,  String) -> ()

public typealias dBProgress = (Any) -> ()
//public typealias dBRpcCallBack = (Any ,  Any) -> ()

public class EventDispatcher
{
    private var local_register: [String: [Any]]
    private var global_register: [Any]

    
    public init()
    {
        self.local_register = [String: [Any]]()
        self.global_register = [Any]()
    }

    
    public func isEventExists(_ eventName: String) -> Bool{
        return self.local_register.keys.contains(eventName)
    }
    
    
    public func bind(_ eventName:String ,  _ callback: @escaping dBConnectCallBack ) throws
    {
        if eventName.isEmpty { throw  dBError("E012") }
        
        if !self.local_register.keys.contains(eventName){
            self.local_register[eventName] =  [callback as Any]
        }else{
            self.local_register[eventName]?.append(callback as Any)
        }
    }

    
    
    public func bind(_ eventName:String ,  _ callback: @escaping dBChannelCallBack ) throws
    {
        if eventName.isEmpty { throw  dBError("E012") }
        
        if !self.local_register.keys.contains(eventName){
            self.local_register[eventName] =  [callback as Any]
        }else{
            self.local_register[eventName]?.append(callback as Any)
        }
    }
    
    
    
    public func bind(_ eventName:String ,  _ callback: @escaping dBInFunction ) throws
    {
        if eventName.isEmpty { throw  dBError("E012") }
        
        if !self.local_register.keys.contains(eventName){
            self.local_register[eventName] =  [callback as Any]
        }else{
            self.local_register[eventName]?.append(callback as Any)
        }
    }
    
  
    public func bind(_ eventName:String ,  _ callback: @escaping dBInFunction2 ) throws
    {
        if eventName.isEmpty { throw  dBError("E012") }
        
        if !self.local_register.keys.contains(eventName){
            self.local_register[eventName] =  [callback as Any]
        }else{
            self.local_register[eventName]?.append(callback as Any)
        }
    }

  
    
    
    public func bind(_ eventName:String ,  _ callback: @escaping dBAccessToken ) throws
    {
        if eventName.isEmpty { throw  dBError("E012") }
        
        if !self.local_register.keys.contains(eventName){
            self.local_register[eventName] =  [callback as Any]
        }else{
            self.local_register[eventName]?.append(callback as Any)
        }
    }

    
    
    public func unbind(_ eventName:String , _ callback : @escaping  dBConnectCallBack)
    {
        
            if self.local_register.keys.contains(eventName){
                self.local_register.remove(at: self.local_register.index(forKey: eventName)!)
            }
        
    }

    public func unbind(_ eventName:String , _ callback : @escaping  dBInFunction)
    {
        
            if self.local_register.keys.contains(eventName){
                self.local_register.remove(at: self.local_register.index(forKey: eventName)!)
            }
        
    }


    
    
    public func unbind(_ eventName:String )
    {
       
        if self.local_register.keys.contains(eventName){
            self.local_register.remove(at: self.local_register.index(forKey: eventName)!)
        }
    }

    
    
    public func unbind()
    {
        self.local_register = [:]
    }
    
    public func bind_all(_ callback: @escaping dBConnectCallBack)
    {
        self.global_register.append(callback as Any)
    }
    
    
    public func bind_all(_ callback: @escaping dBChannelCallBack)
    {
        self.global_register.append(callback as Any)
    }
    
    
    public func bind_all(_ callback: @escaping dBInFunction)
    {
        self.global_register.append(callback as Any)
    }
    
    
    public func unbind_all(_ callback: @escaping dBInFunction)
    {
        self.global_register.removeAll()
    }
    
    
    public func unbind_all()
    {
        self.global_register.removeAll()
    }
    

    public func emit_connectionState(_ eventName:String , _ info :  Any? = nil )
    {
        if(!self.local_register.keys.contains(eventName)) {
            return
        }
        
        guard let callbacks =  self.local_register[eventName] else {   return }

        for callback  in callbacks{
            let cb =  callback as! dBConnectCallBack
            DispatchQueue.main.async { cb(info ?? nil) }
        }
    }
    
    
    public func emit2(_ eventName:String , _ channelname:String, _ sessionid:String, _ action:String, _ response: Any)
    {
        if(!self.local_register.keys.contains(eventName)) {
            return
        }
        
        guard let callbacks =  self.local_register[eventName] else {   return }

        for callback  in callbacks{
            let cb =  callback as! dBAccessToken
            DispatchQueue.main.async{  cb(channelname, sessionid, action, response ) }
        }
    }
    
    
    func emit_channelStatus(_ eventName:String , _ payload: Any , _ matadata:MetaData){
        
        
        for global_callback  in self.global_register{
            let cb =  global_callback as! dBChannelCallBack
            DispatchQueue.main.async{  cb(payload, matadata ) }
        }
            
            
        if(!self.local_register.keys.contains(eventName)) {
            return
        }

        
        guard let callbacks =  self.local_register[eventName] else {   return }
        
        for callback  in callbacks{
            let cb =  callback as! dBChannelCallBack
            DispatchQueue.main.async{  cb(payload, matadata ) }
            
        }
    }
    
    func emit_clientfunction(_ eventName:String,  _ payload: Any , _ response:Any ){

        for global_callback  in self.global_register{
            let cb =  global_callback as! dBInFunction
            DispatchQueue.main.async{  cb(payload, response) }
        }
            
        if(!self.local_register.keys.contains(eventName)) {
            return
        }

        
        guard let callbacks =  self.local_register[eventName] else {   return }
        
        for callback  in callbacks{
            let cb =  callback as! dBInFunction
            DispatchQueue.main.async{  cb(payload, response) }
        }
    }
    
    
    func emit_rpcStatus(_ eventName:String,  _ payload: Any , _ response:Any ) {
        self.emit_clientfunction(eventName, payload ,response)
    }

    
    func emit_rpcFunction(_ eventName:String,  _ payload: Any , _ response:Any? ) {
        self.emit_clientfunction(eventName, payload ,response!)
    }
   
    
    func emit_rpcFunction(_ eventName:String,  _ payload: Any , _ isend:Bool, _ rsub: String ) {
        guard let callbacks =  self.local_register[eventName] else {   return }
        
        for callback  in callbacks{
            let cb =  callback as! dBInFunction2
            DispatchQueue.main.async{  cb(payload, isend ,  rsub ) }
            
        }
    }
   
    
}
