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
                    foundPeers[peerID] = _info
                    self.delegate?.serviceStore(self, withBrowser: browser, foundPeer: peerID)
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
        let _info = foundPeers[peerID]
        
        if let version = _info?[MatchTransferDiscoveryInfo.VersionKey] {
            print("Lost Peer with protocol version: \(version)")
            if let mtVersion = MatchTransferVersion(rawValue: version) {
                switch mtVersion {
                case .v0_1_0:
                    print("Removing peer \(peerID.displayName) (\(String(describing: _info?[MatchTransferDiscoveryInfo.DeviceName]))) with type \(String(describing: _info?[MatchTransferDiscoveryInfo.MatchTypeKey]))")
                    foundPeers.removeValue(forKey: peerID)
                    self.delegate?.serviceStore(self, withBrowser: browser, lostPeer: peerID)
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
        self.delegate?.serviceStore(self, withSession: session, didReceiveData: data, fromPeer: peerID)
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
        print("Peripheral State is \(peripheral.state.rawValue)")
        if peripheral.state == .unsupported {
            transferType = .multipeerConnectivity
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
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, willRestoreState dict: [String : Any]) {
        print("PeripheralManager will restore state: \(dict.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        print("PeripheralManager did add service: \(service.debugDescription) with error \(error.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didReceiveWrite requests: [CBATTRequest]) {
        print("PeripheralManager did receive write requests: \(requests.debugDescription)")
    }
    
    @available(iOS 11.0, *)
    func peripheralManager(_ peripheral: CBPeripheralManager, didOpen channel: CBL2CAPChannel?, error: Error?) {
        print("PeripheralManager did open \(channel.debugDescription) with error \(error.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didSubscribeTo characteristic: CBCharacteristic) {
        print("PeripheralManager central \(central.debugDescription) did subscribe to characteristic \(characteristic.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didPublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("PeripheralManager did publish L2CAPChannel \(PSM.description) with error \(error.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didUnpublishL2CAPChannel PSM: CBL2CAPPSM, error: Error?) {
        print("PeripheralManager did unpublish L2CAPChannel \(PSM.description) with error \(error.debugDescription)")
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, central: CBCentral, didUnsubscribeFrom characteristic: CBCharacteristic) {
        print("PeripheralManager central \(central.debugDescription) did unsubscribe from characteristic \(characteristic.debugDescription)")
    }
}
