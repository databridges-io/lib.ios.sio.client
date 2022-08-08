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


enum MessageType
{
    static let SUBSCRIBE_TO_CHANNEL = 11
    static let CONNECT_TO_CHANNEL = 12
    static let UNSUBSCRIBE_DISCONNECT_FROM_CHANNEL = 13
    static let PUBLISH_TO_CHANNEL = 16
    static let SERVER_SUBSCRIBE_TO_CHANNEL = 111
    static let SERVER_UNSUBSCRIBE_DISCONNECT_FROM_CHANNEL = 113
    static let SERVER_PUBLISH_TO_CHANNEL = 116
    static let SERVER_CHANNEL_SENDMSG = 117
    static let LATENCY = 99
    static let SYSTEM_MSG = 0
    static let PARTICIPANT_JOIN = 17
    static let PARTICIPANT_LEFT = 18
    static let CF_CALL_RECEIVED_OR_CALL = 44
    
    static let CF_CALL_RESPONSE = 46
    static let CF_CALL_TIMEOUT = 49
    static let CF_RESPONSE_TRACKER = 48
    static let CF_CALLEE_QUEUE_EXCEEDED = 50
    static let REGISTER_RPC_SERVER = 51
    static let UNREGISTER_RPC_SERVER = 52
    static let CONNECT_TO_RPC_SERVER = 53
    //static let CALL_RPC_FUNCTION = 54
    static let CALL_RPC_FUNCTION_OR_RECEIVED = 54
    static let CALL_CHANNEL_RPC_FUNCTION = 55
    
    static let RPC_CALL_RESPONSE = 56
    static let RPC_CALL_TIMEOUT = 59
    static let RPC_RESPONSE_TRACKER = 58
    static let RPC_CALLEE_QUEUE_EXCEEDED = 60

}
