//
//  ServiceStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/17/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity
import SwiftState

class ServiceStore: NSObject {
    static let shared:ServiceStore = ServiceStore()
    
    let browser = MCNearbyServiceBrowser(peer: MatchTransfer.localPeerID,
                                         serviceType: MatchTransfer.serviceType)
    let advertiser = MCNearbyServiceAdvertiser(peer: MatchTransfer.localPeerID,
                                               discoveryInfo: [
                                                MatchTransferDiscoveryInfo.DeviceName: UIDevice().name,
                                                MatchTransferDiscoveryInfo.MatchTypeKey: "PowerScout",
                                                MatchTransferDiscoveryInfo.VersionKey: MatchTransferDiscoveryInfo.SendVersion],
                                               serviceType: MatchTransfer.serviceType)
    
    var _stateMachine:StateMachine<ServiceState, ServiceEvent>? = nil
    
    var stateMachine:StateMachine<ServiceState, ServiceEvent> {
        return _stateMachine!
    }
    
    weak var delegate:ServiceStoreDelegate?
    var foundPeers:[MCPeerID:[String:String]] = [:]
    var sessionState:MCSessionState = .notConnected
    
    var machineState:ServiceState {
        return stateMachine.state
    }
    
    var advertising: Bool {
        return [
            ServiceState.advertSelectingData,
            ServiceState.advertReady,
            ServiceState.advertRunning,
            ServiceState.advertInvitationPending,
            ServiceState.advertConnecting,
            ServiceState.advertSendingData
        ].contains(stateMachine.state)
    }
    
    var browsing:Bool {
        return [
            ServiceState.browseRunning,
            ServiceState.browseConnecting,
            ServiceState.browseReceivingData
        ].contains(stateMachine.state)
    }
    
    fileprivate override init() {
        super.init()
        _stateMachine = _createServiceStateMachine()
        browser.delegate = self
        advertiser.delegate = self
        MatchTransfer.session.delegate = self
        print("Setting up ServiceStore")
    }
    
    func proceedWithAdvertising() {
        _triggerEvent(.advertProceed)
    }
    
    func goBackWithAdvertising() {
        _triggerEvent(.advertGoBack)
    }
    
    func errorOutWithAdvertising() {
        _triggerEvent(.advertErrorOut)
    }
    
    func proceedWithBrowsing() {
        _triggerEvent(.browseProceed)
    }
    
    func goBackWithBrowsing() {
        _triggerEvent(.browseGoBack)
    }
    
    func errorOutWithBrowsing() {
        _triggerEvent(.browseErrorOut)
    }
    
    func resetStateMachine() {
        _triggerEvent(.reset)
    }
    
    func sendData(_ data:Data) {
        if(sessionState != .connected) {
            print("ERROR: state is not connected -- can't send data!")
            return
        }
        do {
            try MatchTransfer.session.send(data, toPeers: MatchTransfer.session.connectedPeers, with: .reliable)
        } catch {
            print("ERROR: could not send data!")
        }
    }
    
    func sendMessage(_ message:String) {
        if let data = message.data(using: .utf8) {
            sendData(data)
        }
    }
    
    private func _handleStartAdvertising() {
        MatchTransfer.session.delegate = self
        advertiser.startAdvertisingPeer()
        print("Started Advertiser")
    }
    
    private func _handleStopAdvertising() {
        MatchTransfer.session.disconnect()
        advertiser.stopAdvertisingPeer()
        MatchTransfer.session.delegate = nil
        print("Stopped Advertiser")
    }
    
    private func _handleStartBrowser() {
        MatchTransfer.session.delegate = self
        browser.startBrowsingForPeers()
        print("Started Browsing")
    }
    
    private func _handleStopBrowser() {
        MatchTransfer.session.disconnect()
        browser.stopBrowsingForPeers()
        MatchTransfer.session.delegate = nil
        print("Stopped Browser")
    }
    
    private func _handleDelegateCall(fromState:ServiceState, toState:ServiceState, forEvent event:ServiceEvent, withUserInfo userInfo:Any?) {
        delegate?.serviceStore(self, transitionedFromState: fromState, toState: toState, forEvent: event, withUserInfo: userInfo)
    }
    
    private func _setupStateMachineHandlers(_ machine:StateMachine<ServiceState, ServiceEvent>) {
        // Add Advert Proceed Event Handlers
        machine.addHandler(event: .advertProceed) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Proceed Events
            case (.advertReady,             .advertRunning) :
                print("Start Advertiser")
                self._handleStartAdvertising()
                fallthrough
            case (.notReady,                .advertSelectingData)     : fallthrough
            case (.advertSelectingData,     .advertReady)             : fallthrough
            case (.advertRunning,           .advertInvitationPending) : fallthrough
            case (.advertInvitationPending, .advertConnecting)        : fallthrough
            case (.advertConnecting,        .advertSendingData)       : fallthrough
            case (.advertSendingData,       .notReady) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertProceed): \(fromState) => \(toState)")
        }
        
        // Add Advert Go Back Event Handlers
        machine.addHandler(event: .advertGoBack) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Go Back Events
            case (.advertRunning,       .advertReady)         :
                print("Stop Advertiser")
                self._handleStopAdvertising()
                fallthrough
            case (.advertSelectingData, .notReady)            : fallthrough
            case (.advertReady,         .advertSelectingData) : fallthrough
            case (.advertInvitationPending, .advertRunning)   : fallthrough
            case (.advertConnecting, .advertRunning) : fallthrough
            case (.advertSendingData, .advertRunning) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default :
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertGoBack): \(fromState) => \(toState)")
        }
        
        // Add Advert Error Out Event Handlers
        machine.addHandler(event: .advertErrorOut) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advert Error Out Events
            case (.advertRunning, .notReady) : fallthrough
            case (.advertConnecting, .notReady) : fallthrough
            case (.advertSendingData, .notReady) :
                self._handleStopAdvertising()
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.advertErrorOut): \(fromState) => \(toState)")
        }
        
        // Add Browse Proceed Event Handlers
        machine.addHandler(event: .browseProceed) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Proceed Events
            case (.notReady, .browseRunning) :
                print("Start Browser")
                self._handleStartBrowser()
                fallthrough
            case (.browseRunning, .browseConnecting) : fallthrough
            case (.browseConnecting, .browseReceivingData) : fallthrough
            case (.browseReceivingData, .notReady) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseProceed): \(fromState) => \(toState)")
        }
        
        // Add Browse Go Back Event Handlers
        machine.addHandler(event: .browseGoBack) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Go Back Events
            case (.browseRunning, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                fallthrough
            case (.browseConnecting, .browseRunning) : fallthrough
            case (.browseReceivingData, .browseRunning) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseGoBack): \(fromState) => \(toState)")
        }
        
        // Add Browse Error Out Event Handlers
        machine.addHandler(event: .browseErrorOut) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Browse Error Out Events
            case (.browseRunning, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseErrorOut): \(fromState) => \(toState)")
        }
        
        // Add Reset Event Handlers
        machine.addHandler(event: .reset) {[unowned self] (event: ServiceEvent?, fromState: ServiceState, toState: ServiceState, userInfo: Any?) -> () in
            switch(fromState, toState) {
            // Advertise Reset Transitions
            case (.advertRunning, .notReady) : fallthrough
            case (.advertInvitationPending, .notReady) : fallthrough
            case (.advertConnecting, .notReady) : fallthrough
            case (.advertSendingData, .notReady) :
                print("Stop Advertiser")
                self._handleStopAdvertising()
                fallthrough
            case (.advertSelectingData, .notReady) : fallthrough
            case (.advertReady, .notReady) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Advertise State Reset")
                break
                
            // Browse Reset Transitions
            case (.browseRunning, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._handleStopBrowser()
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Browse State Reset")
                break
                
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.browseErrorOut): \(fromState) => \(toState)")
        }
    }
    
    private func _createServiceStateMachine() -> StateMachine<ServiceState, ServiceEvent> {
        return StateMachine<ServiceState, ServiceEvent>(state: .notReady, initClosure: { [unowned self] machine in
            // MARK: Add Advertisement Transitions
            
            /// Not Ready => Selecting Data
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to handle selecting data and notify machine when data has been selected
            machine.addRoute(.notReady => .advertSelectingData)
            
            /// Selecting Data => Ready
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Update machine state
            machine.addRoute(.advertSelectingData => .advertReady)
            
            /// Selecting Data => Not Ready
            /// Triggered by: GoBack, Reset
            /// Handlers:     GoBack - Allow Delegate to update UI
            ///               Reset  - Allow Delegate to update UI
            machine.addRoute(.advertSelectingData => .notReady)
            
            /// Ready => Running
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Start Advertiser
            machine.addRoute(.advertReady => .advertRunning)
            
            /// Ready => Selecting Data
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to select new data (delegate will notify machine when data has been selected)
            machine.addRoute(.advertReady => .advertSelectingData)
            
            /// Ready => Not Ready
            /// Triggered by: Reset
            /// Handlers:     Reset - Allow Delegate to update UI, update state
            machine.addRoute(.advertReady => .notReady)
            
            /// Running => Invitation Pending
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.advertRunning => .advertInvitationPending)
            
            /// Running => Ready
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI, stop advertiser
            machine.addRoute(.advertRunning => .advertReady)
            
            /// Running => Not Ready
            /// Triggered by: ErrorOut, Reset
            /// Handlers:     ErrorOut - Allow Delegate to update UI, stop advertiser
            ///               Reset    - Allow Delegate to update UI, stop advertiser
            machine.addRoute(.advertRunning => .notReady)
            
            /// Invitation Pending => Connecting
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.advertInvitationPending => .advertConnecting)
            
            /// Invitation Pending => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
            machine.addRoute(.advertInvitationPending => .advertRunning)
            
            /// Invitation Pending => Not Ready
            /// Triggered by: Reset
            /// Handlers:     Reset - Allow Delegate to update UI, stop advertiser
            machine.addRoute(.advertInvitationPending => .notReady)
            
            /// Connecting => Sending Data
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.advertConnecting => .advertSendingData)
            
            /// Connecting => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
            machine.addRoute(.advertConnecting => .advertRunning)
            
            /// Connecting => Not Ready
            /// Triggered by: ErrorOut, Reset
            /// Handlers:     ErrorOut - Allow Delegate to update UI, stop advertiser
            ///               Reset    - Allow Delegate to update UI, stop advertiser
            machine.addRoute(.advertConnecting => .notReady)
            
            /// Sending Data => Not Ready
            /// Triggered by: Proceed, ErrorOut, Reset
            /// Handlers:     Proceed  - Allow Delegate to update UI, stop advertiser
            ///               ErrorOut - Allow Delegate to update UI, stop advertiser
            ///               Reset    - Allow Delegate to update UI, stop advertiser
            machine.addRoute(.advertSendingData => .notReady)
            
            /// Sending Data => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Reset state back to running
            machine.addRoute(.advertSendingData => .advertRunning)
            
            // MARK: Add Browse Transitions
            
            /// Not Ready => Running
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI, start browser
            machine.addRoute(.notReady => .browseRunning)
            
            /// Running => Connecting
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.browseRunning => .browseConnecting)
            
            /// Running => Not Ready
            /// Triggered by: GoBack, ErrorOut, Reset
            /// Handlers:     GoBack   - Allow Delegate to update UI, stop browser
            ///               ErrorOut - Allow Delegate to update UI, stop browser
            ///               Reset    - Allow Delegate to update UI, stop browser
            machine.addRoute(.browseRunning => .notReady)
            
            /// Connecting => Receiving Data
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.browseConnecting => .browseReceivingData)
            
            /// Connecting => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI
            machine.addRoute(.browseConnecting => .browseRunning)
            
            /// Connecting => Not Ready
            /// Triggered by: ErrorOut, Reset
            /// Handlers:     ErrorOut - Allow Delegate to update UI, stop browser
            ///               Reset    - Allow Delegate to update UI, stop browser
            machine.addRoute(.browseConnecting => .notReady)
            
            /// Receiving Data => Not Ready
            /// Triggered by: Proceed, ErrorOut, Reset
            /// Handlers:     Proceed  - Allow Delegate to update UI, stop browser
            ///               ErrorOut - Allow Delegate to update UI, stop browser
            ///               Reset    - Allow Delegate to update UI, stop browser
            machine.addRoute(.browseReceivingData => .notReady)
            
            /// Receiving Data => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI, reset state back to running
            machine.addRoute(.browseReceivingData => .browseRunning)
            
            // Add Default Error Handler
            machine.addErrorHandler { event, fromState, toState, userInfo in
                print("[ERROR] ServiceStateMachine: \(fromState) => \(toState), \(String(describing: event)) with user info \(String(describing: userInfo))")
            }
            
            machine.addRouteMapping { event, fromState, userInfo -> ServiceState? in
                guard let event = event else { return nil }
                
                switch(event, fromState) {
                // Advert Proceed Events
                case (.advertProceed, .notReady)                : return .advertSelectingData
                case (.advertProceed, .advertSelectingData)     : return .advertReady
                case (.advertProceed, .advertReady)             : return .advertRunning
                case (.advertProceed, .advertRunning)           : return .advertInvitationPending
                case (.advertProceed, .advertInvitationPending) : return .advertConnecting
                case (.advertProceed, .advertConnecting)        : return .advertSendingData
                case (.advertProceed, .advertSendingData)       : return .notReady
                    
                // Advert GoBack Events
                case (.advertGoBack, .advertSelectingData)      : return .notReady
                case (.advertGoBack, .advertReady)              : return .advertSelectingData
                case (.advertGoBack, .advertRunning)            : return .advertReady
                case (.advertGoBack, .advertInvitationPending)  : return .advertRunning
                case (.advertGoBack, .advertConnecting)         : return .advertRunning
                case (.advertGoBack, .advertSendingData)        : return .advertRunning
                    
                // Advert ErrorOut Events
                case (.advertErrorOut, .advertRunning)          : return .notReady
                case (.advertErrorOut, .advertConnecting)       : return .notReady
                case (.advertErrorOut, .advertSendingData)      : return .notReady
                    
                // Browse Proceed Events
                case (.browseProceed, .notReady)                : return .browseRunning
                case (.browseProceed, .browseRunning)           : return .browseConnecting
                case (.browseProceed, .browseConnecting)        : return .browseReceivingData
                case (.browseProceed, .browseReceivingData)     : return .notReady
                    
                // Browse GoBack Events
                case (.browseGoBack, .browseRunning)            : return .notReady
                case (.browseGoBack, .browseConnecting)         : return .browseRunning
                case (.browseGoBack, .browseReceivingData)      : return .browseRunning
                    
                // Browse ErrorOut Events
                case (.browseErrorOut, .browseRunning)          : return .notReady
                case (.browseErrorOut, .browseConnecting)       : return .notReady
                case (.browseErrorOut, .browseReceivingData)    : return .notReady
                    
                // Reset Events
                case (.reset, .advertSelectingData)             : return .notReady
                case (.reset, .advertReady)                     : return .notReady
                case (.reset, .advertRunning)                   : return .notReady
                case (.reset, .advertInvitationPending)         : return .notReady
                case (.reset, .advertConnecting)                : return .notReady
                case (.reset, .advertSendingData)               : return .notReady
                case (.reset, .browseRunning)                   : return .notReady
                case (.reset, .browseConnecting)                : return .notReady
                case (.reset, .browseReceivingData)             : return .notReady
                    
                default:
                    return nil
                }
            }
            
            self._setupStateMachineHandlers(machine)
        })
    }
    
    fileprivate func _triggerEvent(_ event:ServiceEvent) {
        print("event: \(event), browsing: \(browsing), advertising: \(advertising)")
        if([.advertProceed, .advertGoBack, .advertErrorOut].contains(event) && browsing) {
            print("WARN: Cannot send advertise event while browsing -- reset state machine first!")
            return
        } else if([.browseProceed, .browseGoBack, .browseErrorOut].contains(event) && advertising) {
            print("WARN: Cannot send browse event while advertising -- reset state machine first!")
            return
        }
        
        stateMachine <-! event
    }
}
