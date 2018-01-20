//
//  ScheduleViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 1/30/16.
//  Copyright © 2016 dhanwada. All rights reserved.
//

import UIKit

class ScheduleViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setToolbarHidden(true, animated: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ScheduleStore.sharedStore.currentSchedule
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ScheduleStore.sharedStore.schedule.count
    }
    
    @IBAction func unwindToSchedule(_ sender:UIStoryboardSegue) {
        self.tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ScheduleCell", for: indexPath) as! ScheduleCell
        let scheduleItem = ScheduleStore.sharedStore.schedule[indexPath.row]
        
        let formatter = DateFormatter()
        formatter.dateFormat = "M'/'d h:mm a"
        cell.title.text = scheduleItem.desc
        cell.teamBlue1.text = "\(scheduleItem.teams[0].teamNumber)"
        cell.teamBlue2.text = "\(scheduleItem.teams[1].teamNumber)"
        cell.teamBlue3.text = "\(scheduleItem.teams[2].teamNumber)"
        cell.teamRed1.text = "\(scheduleItem.teams[3].teamNumber)"
        cell.teamRed2.text = "\(scheduleItem.teams[4].teamNumber)"
        cell.teamRed3.text = "\(scheduleItem.teams[5].teamNumber)"
        cell.time.text = formatter.string(from: scheduleItem.startTime! as Date)
        return cell
    }
    

    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }
    

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */


    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return false
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        // TODO: Remove this
//        if segue.identifier == "segueToEventSelection" {
//            let nav = segue.destination as! UINavigationController
//            let estvc = nav.topViewController as! EventSelectionTableViewController
//            estvc.delegate = self
//        }
    }
}

