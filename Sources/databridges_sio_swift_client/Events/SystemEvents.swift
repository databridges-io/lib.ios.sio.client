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



enum systemEvents{
    static let SUBSCRIBE_SUCCESS = "dbridges:subscribe.success"
    static let SUBSCRIBE_FAIL = "dbridges:subscribe.fail"
    static let ONLINE = "dbridges:channel.online"
    static let OFFLINE = "dbridges:channel.offline"
    static let REMOVE = "dbridges:channel.removed"
    static let UNSUBSCRIBE_SUCCESS = "dbridges:unsubscribe.success"
    static let UNSUBSCRIBE_FAIL = "dbridges:unsubscribe.fail"
    static let CONNECT_SUCCESS = "dbridges:connect.success"
    static let CONNECT_FAIL = "dbridges:connect.fail"
    static let DISCONNECT_SUCCESS = "dbridges:disconnect.success"
    static let DISCONNECT_FAIL = "dbridges:disconnect.fail"
    static let RESUBSCRIBE_SUCCESS = "dbridges:resubscribe.success"
    static let RESUBSCRIBE_FAIL = "dbridges:resubscribe.fail"
    static let RECONNECT_SUCCESS = "dbridges:reconnect.success"
    static let RECONNECT_FAIL = "dbridges:reconnect.fail"
    static let PARTICIPANT_JOINED = "dbridges:participant.joined"
    static let PARTICIPANT_LFET = "dbridges:participant.left"
    static let REGISTRATION_SUCCESS = "dbridges:rpc.server.registration.success"
    static let REGISTRATION_FAIL = "dbridges:rpc.server.registration.fail"
    static let SERVER_ONLINE = "dbridges:rpc.server.online"
    static let SERVER_OFFLINE = "dbridges:rpc.server.offline"
    static let UNREGISTRATION_SUCCESS = "dbridges:rpc.server.unregistration.success"
    static let UNREGISTRATION_FAIL = "dbridges:rpc.server.unregistration.fail"
    static let RPC_CONNECT_SUCCESS = "dbridges:rpc.server.connect.success"
    static let RPC_CONNECT_FAIL = "dbridges:rpc.server.connect.fail"
    static let CF_RESPONSE_TRACKER = "cf.response.tracker"
    static let CF_CALLEE_QUEUE_EXCEED = "cf.callee.queue.exceeded"
    static let RPC_RESPONSE_TRACKER = "rpc.response.tracker"
    static let RPC_CALLEE_QUEUE_EXCEED = "rpc.callee.queue.exceeded"
}
