//
//  ServiceState.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 7/25/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import SwiftState

enum ServiceState: StateType {
    case notReady
    case advertSelectingData
    case advertReady
    case advertRunning
    case advertInvitationPending
    case advertConnecting
    case advertSendingData
    case browseRunning
    case browseInvitationPending
    case browseConnecting
    case browseReceivingData
}

enum ServiceEvent: EventType {
    case reset
    case advertProceed
    case advertGoBack
    case advertErrorOut
    case browseProceed
    case browseGoBack
    case browseErrorOut
}

enum ServiceError: Error {
    case advertRuntime
    case advertConnect
    case advertSend
    case browseRuntime
    case browseConnect
    case browseReceive
}
