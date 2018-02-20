//
//  NearbyDevicesTableViewController.swift
//  PowerScout
//
//  Created by Srinivas Dhanwada on 1/25/18.
//  Copyright © 2018 FRC Team 525. All rights reserved.
//

import UIKit
import MultipeerConnectivity

class NearbyDevicesTableViewController: UITableViewController {

    var nearbyDevices: [NearbyDevice] = [NearbyDevice]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nearbyDevices.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "nearbyDeviceCell", for: indexPath)
        let nearbyDevice = nearbyDevices[indexPath.row]
        // Configure the cell...
        
        cell.textLabel!.text = nearbyDevice.displayName
        cell.detailTextLabel?.text = nearbyDevice.type.toString()
        cell.selectionStyle = .blue

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let nearbyDevice = self.nearbyDevices[indexPath.row]
        self.performSegue(withIdentifier: "UnwindSegueDoneFromBrowser", sender: nearbyDevice)
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let id = segue.identifier {
            if id.elementsEqual("UnwindSegueDoneFromBrowser") {
                let selectedDevice = sender as! NearbyDevice
                print("User selected: \(String(describing: selectedDevice))")
                if let vc = segue.destination as? DataTransferViewController {
                    vc.selectedDevice = selectedDevice
                }
            }
        }
    }
}

extension NearbyDevicesTableViewController: DataTransferViewControllerDelegate {
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, foundNearbyDevice nearbyDevice: NearbyDevice) {
        if !nearbyDevices.contains(where: { $0.displayName == nearbyDevice.displayName && $0.type == nearbyDevice.type }) {
            self.nearbyDevices.append(nearbyDevice)
            self.tableView.reloadData()
        }
    }
    
    func dataTransferViewController(_ dataTransferViewController: DataTransferViewController, lostNearbyDevice nearbyDevice: NearbyDevice) {
        if let index = nearbyDevices.index(where: { $0.displayName == nearbyDevice.displayName && $0.type == nearbyDevice.type }) {
            self.nearbyDevices.remove(at: index)
            self.tableView.reloadData()
        }
    }
}
