//
//  ServiceStore+ProtocolHandlers.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 8/23/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import CoreBluetooth
import MultipeerConnectivity

extension ServiceStore: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("advertiser \(advertiser) did receive invitation from peer \(peerID.displayName) with context \(String(describing: context))")
        proceedWithAdvertising()
        // TEMPORARY -- Should ask user instead
        invitationHandler(true, MatchTransfer.session)
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        print("advertiser \(advertiser) did not start advertising due to error \(error.localizedDescription)")
    }
}

extension ServiceStore: MCNearbyServiceBrowserDelegate {
    
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        guard let _info = info else {
            print("Discovery Info is null! Bypassing...");
            return
        }
        
        if let version = _info[MatchTransferDiscoveryInfo.VersionKey] {
            print("Found Peer with protocol version: \(version)")
            if let mtVersion = MatchTransferVersion(rawValue: version) {
                switch mtVersion {
                case .v0_1_0:
                    print("Adding peer \(peerID.displayName) (\(String(describing: _info[MatchTransferDiscoveryInfo.DeviceName]))) with type \(String(describing: _info[MatchTransferDiscoveryInfo.MatchTypeKey]))")
                    if !foundNearbyDevices.contains(where: { peerID.hash == $0.hash}) {
                        let newDevice = NearbyDevice(displayName: _info[MatchTransferDiscoveryInfo.DeviceName] ?? "Unknown", type: .multipeerConnectivity, hash: peerID.hash, mcInfo: _info, mcId: peerID, cbPeripheral: nil)
                        foundNearbyDevices.append(newDevice)
                        self.delegate?.serviceStore(self, foundNearbyDevice: newDevice)
                    }
                default:
                    print("Found Peer with invalid version: \(version)! Bypassing...")
                }
            }
        } else {
            print("Found Peer with invalid version key! Bypassing...")
        }
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        print("Did not start browsing for peers: \(error.localizedDescription)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        guard let ndIndex = foundNearbyDevices.index(where: {$0.hash == peerID.hash && $0.type == .multipeerConnectivity}) else {
            print("Lost Peer that was not found or was not a MC device! Bypassing...")
            return
        }
        let _info = foundNearbyDevices[ndIndex].mcInfo
        if let version = _info[MatchTransferDiscoveryInfo.VersionKey] {
            print("Lost Peer with protocol version: \(version)")
            if let mtVersion = MatchTransferVersion(rawValue: version) {
                switch mtVersion {
                case .v0_1_0:
                    print("Removing peer \(peerID.displayName) (\(String(describing: _info[MatchTransferDiscoveryInfo.DeviceName]))) with type (\(String(describing: _info[MatchTransferDiscoveryInfo.MatchTypeKey])))")
                    let oldDevice = foundNearbyDevices.remove(at: ndIndex)
                    self.delegate?.serviceStore(self, lostNearbyDevice: oldDevice)
                default:
                    print("Lost Peer with invalid version: \(version)! Bypassing...")
                }
            }
        } else {
            print("Lost Peer with invalid version key! Bypassing...")
        }
    }
}

extension ServiceStore: MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        let prevState = sessionState
        self.sessionState = state
        self.delegate?.serviceStore(self, withSession: session, didChangeState: state)
        print("MCSession \(session.myPeerID.displayName) with did change state to \(String(describing: state.rawValue))")
        
        if advertising {
            if prevState == .notConnected && state == .connecting {
                proceedWithAdvertising()
            } else if prevState == .connecting && state == .connected {
                proceedWithAdvertising()
            } else if prevState == .connected && state == .connecting {
                goBackWithAdvertising()
            } else if prevState == .connecting && state == .notConnected {
                goBackWithAdvertising()
            } else if prevState == .connected && state == .notConnected {
                proceedWithAdvertising()
            }
        } else if browsing {
            if prevState == .notConnected && state == .connecting {
                proceedWithBrowsing()
            } else if prevState == .connecting && state == .connected {
                proceedWithBrowsing()
            } else if prevState == .connected && state == .connecting {
                goBackWithBrowsing()
            } else if prevState == .connecting && state == .notConnected {
                goBackWithBrowsing()
            } else if prevState == .connected && state == .notConnected {
                proceedWithBrowsing()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        if let device = self.foundNearbyDevices.first(where: {$0.hash == peerID.hash}) {
            print("MCSession \(session.myPeerID.displayName) did receive data from peer \(peerID): \(data)")
            if let string = String(data: data, encoding: .utf8) {
                if string.elementsEqual("EOD") {
                    if advertising {
                        proceedWithAdvertising()
                    } else if browsing {
                        proceedWithBrowsing()
                    }
                }
            }
            self.delegate?.serviceStore(self, didReceiveData: data, fromDevice: device)
        }
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        print("MCSession \(session.myPeerID.displayName) did receive stream \(streamName) from peer \(peerID.displayName)")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        print("MCSession \(session.myPeerID.displayName) did start receiving resource with name \(resourceName) from peer \(peerID.displayName) with progress \(progress)")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        print("MCSession \(session.myPeerID.displayName) did finish receiving resource with name \(resourceName) from peer \(peerID.displayName) at \(String(describing: localURL)) with error \(String(describing: error?.localizedDescription))")
    }
    
    func session(_ session: MCSession, didReceiveCertificate certificate: [Any]?, fromPeer peerID: MCPeerID, certificateHandler: @escaping (Bool) -> Void) {
        print("MCSession \(session.myPeerID.displayName) did receive certificate \(String(describing: certificate?.debugDescription)) from peer \(peerID.displayName)")
        certificateHandler(true)
    }
}

extension ServiceStore: CBPeripheralManagerDelegate {
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("PeripheralManager State is \(peripheral.state.rawValue)")
        if peripheral.state == .unsupported {
            transferType = .multipeerConnectivity
        } else if peripheral.state == .poweredOn {
            setupCBAdvertisementServices()
        }
    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        print("PeripheralManagerDidStartAdvertising with error \(error.debugDescription)")
    }
    
    func peripheralManagerIsReady(toUpdateSubscribers peripheral: CBPeripheralManager) {
        print("PeripheralManagerIsReadyToUpdateSubscribers")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveRead request: CBATTRequest) {
        print("PeripheralManager did receive read request \(request.debugDescription)")
        if let data = matchStore.dataTransferMatchesAll(true) {
            if request.characteristic.uuid == MatchTransferUUIDs.dataCharacteristic {
                if request.offset > data.count {
                    peripheral.respond(to: request, withResult: .invalidOffset)
                } else {
                    request.value = data.subdata(in: dataTransferred..<min(dataTransferred + 500, data.count))
                    peripheral.respond(to: request, withResult: .success)
                }
            } else if request.characteristic.uuid == MatchTransferUUIDs.lengthCharacteristic {
                var dataLength = data.count
                let dataLengthData = Data(buffer: UnsafeBufferPointer(start: &dataLength, count: 1))
                if request.offset > dataLengthData.count {
                    peripheral.respond(to: request, withResult: .invalidOffset)
                } else {
                    request.value = dataLengthData
                    peripheral.respond(to: request, withResult: .success)
                }
            } else {
                peripheral.respond(to: request, withResult: .attributeNotFound)
            }
        } else {
            peripheral.respond(to: request, withResult: .insufficientResources)
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("PeripheralManager did add service: \(service.debugDescription) with error \(error.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("PeripheralManager did receive write requests: \(requests.debugDescription)")
        var fail = false
        for request in requests {
            if request.characteristic.uuid == MatchTransferUUIDs.connectCharacteristic ||
                request.characteristic.uuid == MatchTransferUUIDs.doneCharacteristic {
                if request.value == nil {
                    fail = true
                    break
                } else {
                    dataTransferred = 0
                    proceedWithAdvertising()
                    if request.characteristic.uuid == MatchTransferUUIDs.connectCharacteristic {
                        proceedWithAdvertising()
                        proceedWithAdvertising()
                    }
                }
            } else if request.characteristic.uuid == MatchTransferUUIDs.transferCharacteristic {
                if request.value == nil {
                    fail = true
                    break
                } else {
                    dataTransferred = request.value!.withUnsafeBytes { (ptr: UnsafePointer<Int>) -> Int in
                        return ptr.pointee
                    }
                }
            }
        }
        for request in requests {
            if fail {
                peripheral.respond(to: request, withResult: .attributeNotFound)
            } else {
                peripheral.respond(to: request, withResult: .success)
            }
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("PeripheralManager central \(central.debugDescription) did subscribe to characteristic \(characteristic.debugDescription)")
    }

    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("PeripheralManager central \(central.debugDescription) did unsubscribe from characteristic \(characteristic.debugDescription)")
    }
}

extension ServiceStore: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Peripheral \(peripheral.debugDescription) did discover services with error \(error.debugDescription)")
        var foundService = false
        if let services = peripheral.services {
            for service in services {
                if service.uuid == MatchTransferUUIDs.dataService && !foundService {
                    foundService = true
                    peripheral.discoverCharacteristics([MatchTransferUUIDs.dataCharacteristic, MatchTransferUUIDs.connectCharacteristic, MatchTransferUUIDs.doneCharacteristic, MatchTransferUUIDs.lengthCharacteristic, MatchTransferUUIDs.transferCharacteristic], for: service)
                }
            }
        }
        if !foundService {
            print("ERROR: Could not find right service! Erroring out...")
            self.errorOutWithBrowsing()
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Peripheral \(peripheral.debugDescription) did discover characteristics for service \(service.debugDescription) with error \(error.debugDescription)")
        var connect:CBCharacteristic?
        var data:CBCharacteristic?
        var done:CBCharacteristic?
        var length:CBCharacteristic?
        var transfer:CBCharacteristic?
        if let characteristics = service.characteristics {
            for characteristic in characteristics {
                if characteristic.uuid == MatchTransferUUIDs.dataCharacteristic {
                    data = characteristic
                } else if characteristic.uuid == MatchTransferUUIDs.connectCharacteristic {
                    connect = characteristic
                } else if characteristic.uuid == MatchTransferUUIDs.doneCharacteristic {
                    done = characteristic
                } else if characteristic.uuid == MatchTransferUUIDs.lengthCharacteristic {
                    length = characteristic
                } else if characteristic.uuid == MatchTransferUUIDs.transferCharacteristic {
                    transfer = characteristic
                }
            }
        }
        guard let con = connect, let dat = data, let don = done, let len = length, let xfer = transfer else {
            print("ERROR: Could not find right characteristics! Erroring out...")
            self.errorOutWithBrowsing()
            return
        }
        connectCharacteristic = con
        dataCharateristic = dat
        doneCharacteristic = don
        lengthCharacteristic = len
        transferCharacteristic = xfer
        let connected = "connected".data(using: .utf8)
        peripheral.writeValue(connected!, for: con, type: CBCharacteristicWriteType.withResponse)
        self.proceedWithBrowsing()
    }
    
    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        print("Peripheral \(peripheral.debugDescription) did write value for \(characteristic.debugDescription) with error \(error.debugDescription)")
        if characteristic.uuid == MatchTransferUUIDs.connectCharacteristic {
            if let len = lengthCharacteristic {
                peripheral.readValue(for: len)
            } else {
                self.errorOutWithBrowsing()
            }
        } else if characteristic.uuid == MatchTransferUUIDs.doneCharacteristic {
            self.proceedWithBrowsing()
            centralManager.cancelPeripheralConnection(peripheral)
        } else if characteristic.uuid == MatchTransferUUIDs.transferCharacteristic {
            if let dat = dataCharateristic {
                peripheral.readValue(for: dat)
            } else {
                self.errorOutWithBrowsing()
            }
        }
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if characteristic.uuid == MatchTransferUUIDs.dataCharacteristic {
            if let data = characteristic.value, let device = self.foundNearbyDevices.first(where: {$0.hash == peripheral.identifier.hashValue}) {
                dataReceived += data.count
                transferData.append(data)
                if dataReceived < transferLength {
                    if let xfer = transferCharacteristic {
                        let dataReceivedData = Data(buffer: UnsafeBufferPointer(start: &dataReceived, count: 1))
                        peripheral.writeValue(dataReceivedData, for: xfer, type: .withResponse)
                    }
                } else {
                    if let don = doneCharacteristic {
                        let done = "done".data(using: .utf8)
                        peripheral.writeValue(done!, for: don, type: .withResponse)
                        self.delegate?.serviceStore(self, didReceiveData: transferData, fromDevice: device)
                    } else {
                        self.errorOutWithBrowsing()
                    }
                }
            } else {
                print("ERROR: Data was null! Erroring out...")
                self.errorOutWithBrowsing()
            }
        } else if characteristic.uuid == MatchTransferUUIDs.lengthCharacteristic {
            if let data = characteristic.value {
                transferLength = data.withUnsafeBytes { (ptr: UnsafePointer<Int>) -> Int in
                    return ptr.pointee
                }
                dataReceived = 0
                transferData = Data()
                if let xfer = transferCharacteristic {
                    let dataReceivedData = Data(buffer: UnsafeBufferPointer(start: &dataReceived, count: 1))
                    peripheral.writeValue(dataReceivedData, for: xfer, type: .withResponse)
                }
            }
        } else {
            print("WARN: updated value to wrong characteristic! Erroring out...")
            self.errorOutWithBrowsing()
        }
    }
}

extension ServiceStore: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CentralManager State is \(central.state.rawValue)")
        if central.state == .unsupported {
            transferType = .multipeerConnectivity
        }
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("CentralManager did connect to peripheral \(peripheral.debugDescription)")
        self.proceedWithBrowsing()
        peripheral.delegate = self
        peripheral.discoverServices([MatchTransferUUIDs.dataService])
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        print("CentralManager did fail to connect to peripheral \(peripheral.debugDescription) with error \(error.debugDescription)")
        if self.browsing {
            self.errorOutWithBrowsing()
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        print("CentralManager did disconnect with peripheral \(peripheral.debugDescription) with error \(error.debugDescription)")
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        if filters[peripheral.identifier] == nil {
            filters[peripheral.identifier] = RollingAverage(withSize: 50)
        }
        filters[peripheral.identifier]!.addValue(RSSI.doubleValue)
        let filter = filters[peripheral.identifier]!
        let deviceIdx = self.foundNearbyDevices.index(where: {peripheral.identifier.hashValue == $0.hash && $0.type == .coreBluetooth})
        if filter.average > -60.0 && deviceIdx == nil {
            print("CentralManager did discover peripheral \(peripheral.debugDescription) with addata \(advertisementData.debugDescription) and rssi \(RSSI)")
            let newDevice = NearbyDevice(displayName: advertisementData[CBAdvertisementDataLocalNameKey] as? String ?? peripheral.name ?? "Unknown", type: .coreBluetooth, hash: peripheral.identifier.hashValue, mcInfo: [:], mcId: nil, cbPeripheral: peripheral)
            self.foundNearbyDevices.append(newDevice)
            self.delegate?.serviceStore(self, foundNearbyDevice: newDevice)
        } else if filter.average < -60.0 && deviceIdx != nil {
            print("CentralManager did undiscover peripheral \(peripheral.debugDescription) with addata \(advertisementData.debugDescription) and rssi \(RSSI)")
            let oldDevice = self.foundNearbyDevices.remove(at: deviceIdx!)
            self.delegate?.serviceStore(self, lostNearbyDevice: oldDevice)
        }
    }
}
