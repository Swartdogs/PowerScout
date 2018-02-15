//
//  ServiceStore.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 6/17/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import CoreBluetooth
import MultipeerConnectivity
import SwiftState

class ServiceStore: NSObject {
    let browser = MCNearbyServiceBrowser(peer: MatchTransfer.localPeerID,
                                         serviceType: MatchTransfer.serviceType)
    let advertiser = MCNearbyServiceAdvertiser(peer: MatchTransfer.localPeerID,
                                               discoveryInfo: [
                                                MatchTransferDiscoveryInfo.DeviceName: UIDevice().name,
                                                MatchTransferDiscoveryInfo.MatchTypeKey: "PowerScout",
                                                MatchTransferDiscoveryInfo.VersionKey: MatchTransferDiscoveryInfo.SendVersion],
                                               serviceType: MatchTransfer.serviceType)
    let matchStore:MatchStore!
    var peripheralManager:CBPeripheralManager!
    var centralManager:CBCentralManager!
    
    var dataCharateristic:CBCharacteristic? = nil
    var connectCharacteristic:CBCharacteristic? = nil
    var doneCharacteristic:CBCharacteristic? = nil
    var lengthCharacteristic:CBCharacteristic? = nil
    var transferCharacteristic:CBCharacteristic? = nil
    var transferLength:Int = 0
    var dataTransferred:Int = 0
    var dataReceived:Int = 0
    var transferData:Data = Data()
    
    var transferType:MatchTransferType = .coreBluetooth
    var _stateMachine:StateMachine<ServiceState, ServiceEvent>? = nil
    var filters:[UUID:RollingAverage] = [:]
    
    var stateMachine:StateMachine<ServiceState, ServiceEvent> {
        return _stateMachine!
    }
    
    weak var delegate:ServiceStoreDelegate?
    var foundNearbyDevices:[NearbyDevice] = []
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
            ServiceState.browseInvitationPending,
            ServiceState.browseConnecting,
            ServiceState.browseReceivingData
        ].contains(stateMachine.state)
    }
    
    init(withMatchStore matchStore: MatchStore) {
        print("Setting up ServiceStore")
        self.matchStore = matchStore
        super.init()
        _stateMachine = _createServiceStateMachine()
        browser.delegate = self
        advertiser.delegate = self
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil, options: nil)
        centralManager = CBCentralManager(delegate: self, queue: nil, options: nil)
        MatchTransfer.session.delegate = self
    }
    
    func setupCBAdvertisementServices() {
        let dataCharacteristic = CBMutableCharacteristic(type: MatchTransferUUIDs.dataCharacteristic, properties: CBCharacteristicProperties.read, value: nil, permissions: CBAttributePermissions.readable)
        let connectCharacteristic = CBMutableCharacteristic(type: MatchTransferUUIDs.connectCharacteristic, properties: .write, value: nil, permissions: .writeable)
        let doneCharacteristic = CBMutableCharacteristic(type: MatchTransferUUIDs.doneCharacteristic, properties: .write, value: nil, permissions: .writeable)
        let lengthCharacteristic = CBMutableCharacteristic(type: MatchTransferUUIDs.lengthCharacteristic, properties: .read, value: nil, permissions: CBAttributePermissions.readable)
        let transferCharacteristic = CBMutableCharacteristic(type: MatchTransferUUIDs.transferCharacteristic, properties: .write, value: nil, permissions: .writeable)
        let service = CBMutableService(type: MatchTransferUUIDs.dataService, primary: true)
        service.characteristics = [dataCharacteristic, connectCharacteristic, doneCharacteristic, lengthCharacteristic, transferCharacteristic]
        peripheralManager.add(service)
    }
    
    // MARK: Convenience event triggers
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
    
    func proceedWithBrowsing(andSelectDevice device: NearbyDevice) {
        _triggerEvent(.browseProceed, withUserInfo: device)
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
    
    private func _disconnectSession() {
        
        foundNearbyDevices.removeAll()
        
        guard sessionState != .notConnected else {
            print("Can't Disconnect the session if it's already disconnected!")
            MatchTransfer.session.delegate = nil
            MatchTransfer.session = MCSession(peer: MatchTransfer.localPeerID, securityIdentity: nil, encryptionPreference: .none)
            MatchTransfer.session.delegate = self
            return
        }
        
        MatchTransfer.session.delegate = nil
        MatchTransfer.session.disconnect()
        MatchTransfer.session = MCSession(peer: MatchTransfer.localPeerID, securityIdentity: nil, encryptionPreference: .none)
        MatchTransfer.session.delegate = self
        sessionState = .notConnected
        delegate?.serviceStore(self, withSession: MatchTransfer.session, didChangeState: .notConnected)
    }
    
    private func _handleStartAdvertising() {
        if transferType == .multipeerConnectivity {
            MatchTransfer.session.delegate = self
            advertiser.startAdvertisingPeer()
        } else if transferType == .coreBluetooth {
            peripheralManager.startAdvertising([
                CBAdvertisementDataLocalNameKey: UIDevice.current.name,
                CBAdvertisementDataServiceUUIDsKey: [MatchTransferUUIDs.dataService]
                ])
        }
        print("Started Advertiser")
    }
    
    private func _handleStopAdvertising() {
        if transferType == .multipeerConnectivity {
            MatchTransfer.session.disconnect()
            advertiser.stopAdvertisingPeer()
            MatchTransfer.session.delegate = nil
        } else if transferType == .coreBluetooth {
            peripheralManager.stopAdvertising()
        }
        print("Stopped Advertiser")
    }
    
    private func _handleStartBrowser() {
        if transferType == .multipeerConnectivity {
            MatchTransfer.session.delegate = self
            browser.startBrowsingForPeers()
        } else if transferType == .coreBluetooth {
            filters.removeAll()
            centralManager.scanForPeripherals(withServices: [MatchTransferUUIDs.dataService], options: [
                CBCentralManagerScanOptionAllowDuplicatesKey: true])
        }
        print("Started Browsing")
    }
    
    private func _handleStopBrowser() {
        if transferType == .multipeerConnectivity {
            MatchTransfer.session.disconnect()
            browser.stopBrowsingForPeers()
            MatchTransfer.session.delegate = nil
        } else if transferType == .coreBluetooth {
            centralManager.stopScan()
        }
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
            case (.advertConnecting,        .advertSendingData)       :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            case (.advertSendingData,       .notReady) :
                print("Stop Advertiser")
                self._disconnectSession()
                self._handleStopAdvertising()
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
            case (.advertReady,         .advertSelectingData) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            case (.advertInvitationPending, .advertRunning)   : fallthrough
            case (.advertConnecting, .advertRunning) : fallthrough
            case (.advertSendingData, .advertRunning) :
                self._disconnectSession()
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
                print("Stop Advertiser")
                self._disconnectSession()
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
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            case (.browseRunning, .browseInvitationPending) :
                if let nearbyDevice = userInfo as? NearbyDevice {
                    if nearbyDevice.type == .multipeerConnectivity {
                        if let peer = self.foundNearbyDevices.first(where: {$0.hash == nearbyDevice.hash}) {
                            print("Inviting: \(peer.displayName)")
                            self.browser.invitePeer(peer.mcId!, to: MatchTransfer.session, withContext: nil, timeout: 10.0)
                        } else {
                            print("WARN: No found peer matches nearby device \(nearbyDevice.displayName), going back to running")
                            self.goBackWithBrowsing()
                        }
                    } else if nearbyDevice.type == .coreBluetooth {
                        if let device = self.foundNearbyDevices.first(where: {$0.hash == nearbyDevice.hash}) {
                            self.centralManager.stopScan()
                            print("Connecting to \(device.displayName)")
                            self.centralManager.connect(device.cbPeripheral!, options: nil)
                        } else {
                            print("WARN: No found peer matches nearby device \(nearbyDevice.displayName), going back to running")
                            self.goBackWithBrowsing()
                        }
                    }
                } else {
                    print("WARN: No nearby device was selected, going back to running")
                    self.goBackWithBrowsing()
                }
                fallthrough
            case (.browseInvitationPending, .browseConnecting) : fallthrough
            case (.browseConnecting, .browseReceivingData) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            case (.browseReceivingData, .notReady) :
                self._disconnectSession()
                print("Stop Browser")
                self._handleStopBrowser()
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
            case (.browseInvitationPending, .browseRunning) : fallthrough
            case (.browseConnecting, .browseRunning) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            case (.browseReceivingData, .browseRunning) :
                self._disconnectSession()
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
            case (.browseInvitationPending, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._disconnectSession()
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
                self._disconnectSession()
                self._handleStopAdvertising()
                fallthrough
            case (.advertSelectingData, .notReady) : fallthrough
            case (.advertReady, .notReady) :
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Advertise State Reset")
                break
                
            // Browse Reset Transitions
            case (.browseRunning, .notReady) : fallthrough
            case (.browseInvitationPending, .notReady) : fallthrough
            case (.browseConnecting, .notReady) : fallthrough
            case (.browseReceivingData, .notReady) :
                print("Stop Browser")
                self._disconnectSession()
                self._handleStopBrowser()
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                print("Browse State Reset")
                break
                
            // Default Reset Transition
            case (.notReady, .notReady) :
                self._disconnectSession()
                print("Stop Advertiser")
                self._handleStopAdvertising()
                print("Stop Browser")
                self._handleStopBrowser()
                self._handleDelegateCall(fromState: fromState, toState: toState, forEvent: event!, withUserInfo: userInfo)
                break
            default:
                print("Invalid case for this event!")
                break
            }
            
            print("completed handler for \(ServiceEvent.reset): \(fromState) => \(toState)")
        }
    }
    
    private func _createServiceStateMachine() -> StateMachine<ServiceState, ServiceEvent> {
        return StateMachine<ServiceState, ServiceEvent>(state: .notReady, initClosure: { [unowned self] machine in
            // MARK: Default Transisions
        
            /// Not Ready => Not Ready
            /// Triggered by: User
            /// Handlers: Self - Disconnect Session, Stop Advertiser and Browser, Reset State
            machine.addRoute(.notReady => .notReady)
            
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
            
            /// Running => Invitation Pending
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.browseRunning => .browseInvitationPending)
            
            /// Running => Not Ready
            /// Triggered by: GoBack, ErrorOut, Reset
            /// Handlers:     GoBack   - Allow Delegate to update UI, stop browser
            ///               ErrorOut - Allow Delegate to update UI, stop browser
            ///               Reset    - Allow Delegate to update UI, stop browser
            machine.addRoute(.browseRunning => .notReady)
            
            /// Invitation Pending => Connecting
            /// Triggered by: Proceed
            /// Handlers:     Proceed - Allow Delegate to update UI
            machine.addRoute(.browseInvitationPending => .browseConnecting)
            
            /// Invitation Pending => Running
            /// Triggered by: GoBack
            /// Handlers:     GoBack - Allow Delegate to update UI
            machine.addRoute(.browseInvitationPending => .browseRunning)
            
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
                case (.browseProceed, .browseRunning)           : return .browseInvitationPending
                case (.browseProceed, .browseInvitationPending) : return .browseConnecting
                case (.browseProceed, .browseConnecting)        : return .browseReceivingData
                case (.browseProceed, .browseReceivingData)     : return .notReady
                    
                // Browse GoBack Events
                case (.browseGoBack, .browseRunning)            : return .notReady
                case (.browseGoBack, .browseInvitationPending)  : return .browseRunning
                case (.browseGoBack, .browseConnecting)         : return .browseRunning
                case (.browseGoBack, .browseReceivingData)      : return .browseRunning
                    
                // Browse ErrorOut Events
                case (.browseErrorOut, .browseRunning)          : return .notReady
                case (.browseErrorOut, .browseInvitationPending): return .notReady
                case (.browseErrorOut, .browseConnecting)       : return .notReady
                case (.browseErrorOut, .browseReceivingData)    : return .notReady
                    
                // Reset Events
                case (.reset, .notReady)                        : return .notReady
                case (.reset, .advertSelectingData)             : return .notReady
                case (.reset, .advertReady)                     : return .notReady
                case (.reset, .advertRunning)                   : return .notReady
                case (.reset, .advertInvitationPending)         : return .notReady
                case (.reset, .advertConnecting)                : return .notReady
                case (.reset, .advertSendingData)               : return .notReady
                case (.reset, .browseRunning)                   : return .notReady
                case (.reset, .browseInvitationPending)         : return .notReady
                case (.reset, .browseConnecting)                : return .notReady
                case (.reset, .browseReceivingData)             : return .notReady
                    
                default:
                    return nil
                }
            }
            
            self._setupStateMachineHandlers(machine)
        })
    }
    
    fileprivate func _triggerEvent(_ event:ServiceEvent, withUserInfo userInfo:Any? = nil) {
        print("event: \(event), browsing: \(browsing), advertising: \(advertising)")
        if([.advertProceed, .advertGoBack, .advertErrorOut].contains(event) && browsing) {
            print("WARN: Cannot send advertise event while browsing -- reset state machine first!")
            return
        } else if([.browseProceed, .browseGoBack, .browseErrorOut].contains(event) && advertising) {
            print("WARN: Cannot send browse event while advertising -- reset state machine first!")
            return
        }
        
        if userInfo != nil {
            stateMachine <-! (event, userInfo)
        } else {
            stateMachine <-! event
        }
    }
}
