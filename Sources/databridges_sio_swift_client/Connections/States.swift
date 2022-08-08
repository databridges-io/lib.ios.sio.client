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


public  class States
{
    public static let  CONNECTED:String = "connected"
    public static let  ERROR:String = "connect_error"
    public static let  DISCONNECTED:String = "disconnected"
    public static let  RECONNECTING:String = "reconnecting"
    public static let  CONNECTING:String = "connecting"
    public static let  STATE_CHANGE:String = "state_change"
    public static let  RECONNECT_ERROR:String = "reconnect_error"
    public static let  RECONNECT_FAILED:String = "reconnect_failed"
    public static let  RECONNECTED:String = "reconnected"
    public static let  CONNECTION_BREAK:String = "connection_break"

    public static let  RTTPONG:String = "rttpong"
    public static let  RTTPING:String = "rttping"

    public static let supportedEvents:[String] = ["connect_error" , "connected",
                                                  "disconnected", "reconnecting",
                                                  "connecting", "state_change",
                                                  "reconnect_error", "reconnect_failed",
                                                  "reconnected", "connection_break",
                                                  "rttpong"];

}
