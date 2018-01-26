//
//  ServiceStore+ProtocolHandlers.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 8/23/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import Foundation
import MultipeerConnectivity

extension ServiceStore: MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        print("advertiser \(advertiser) did receive invitation from peer \(peerID.displayName) with context \(String(describing: context))")
        proceedWithAdvertising()
        // TEMPORARY -- Should ask user instead
//        invitationHandler(true, MatchTransfer.session)
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
                    // TEMPORARY
//                    browser.invitePeer(peerID, to: MatchTransfer.session, withContext: nil, timeout: 10.0)
                    
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
            }
            // TODO: Detect if this is due to error or not
//            else if prevState == .connected && state == .notConnected {
//                proceedWithAdvertising()
//            }
        } else if browsing {
            if prevState == .notConnected && state == .connecting {
                proceedWithBrowsing()
            } else if prevState == .connecting && state == .connected {
                proceedWithBrowsing()
            } else if prevState == .connected && state == .connecting {
                goBackWithBrowsing()
            } else if prevState == .connecting && state == .notConnected {
                goBackWithBrowsing()
            }
        }
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        print("MCSession \(session.myPeerID.displayName) did receive data from peer \(peerID): \(data)")
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
