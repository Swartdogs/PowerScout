//
//  DataSelectionViewController.swift
//  SteamScout
//
//  Created by Srinivas Dhanwada on 9/5/17.
//  Copyright © 2017 dhanwada. All rights reserved.
//

import UIKit

class DataSelectionViewController: UIViewController {
    
    @IBOutlet weak var availableTable:UITableView!
    @IBOutlet weak var selectedTable:UITableView!
    
    var matchStore:MatchStore!
    var availableMatches:[Match] = []
    var selectedMatches:[Match] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        for var m in matchStore.allMatches {
            if(m.shouldExport || m.selectedForDataTransfer) {
                m.selectedForDataTransfer = true
                selectedMatches.append(m)
            } else {
                availableMatches.append(m)
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        availableMatches.removeAll()
        selectedMatches.removeAll()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        availableTable.dataSource = self
        availableTable.delegate = self
        
        selectedTable.dataSource = self
        selectedTable.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: UITableViewDataSource
extension DataSelectionViewController : UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(tableView == availableTable) {
            return availableMatches.count
        } else if(tableView == selectedTable) {
            return selectedMatches.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MatchCell") as! MatchCell
        
        if tableView == availableTable {
            var match = availableMatches[indexPath.row]
            
            cell.matchNumber.text = "\(match.matchNumber)"
            cell.teamNumber.text = "\(match.teamNumber)"
        } else if tableView == selectedTable {
            var match = selectedMatches[indexPath.row]
            
            cell.matchNumber.text = "\(match.matchNumber)"
            cell.teamNumber.text = "\(match.teamNumber)"
        }
        
        return cell
    }
}

// MARK: UITableViewDelegate
extension DataSelectionViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == availableTable {
            var match = availableMatches.remove(at: indexPath.row)
            match.selectedForDataTransfer = true
            selectedMatches.append(match)
            
            availableTable.beginUpdates()
            availableTable.deleteRows(at: [indexPath], with: .right)
            availableTable.endUpdates()
            
            selectedTable.beginUpdates()
            let newIndexPath = IndexPath(row: selectedMatches.count - 1, section: 0)
            selectedTable.insertRows(at: [newIndexPath], with: .left)
            selectedTable.endUpdates()
        } else if tableView == selectedTable {
            var match = selectedMatches.remove(at: indexPath.row)
            match.selectedForDataTransfer = false
            availableMatches.append(match)
            
            selectedTable.beginUpdates()
            selectedTable.deleteRows(at: [indexPath], with: .left)
            selectedTable.endUpdates()
            
            availableTable.beginUpdates()
            let newIndexPath = IndexPath(row: availableMatches.count - 1, section: 0)
            availableTable.insertRows(at: [newIndexPath], with: .right)
            availableTable.endUpdates()
        }
    }
}
