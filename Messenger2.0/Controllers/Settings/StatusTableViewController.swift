//
//  StatusTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 08.02.2024.
//

import UIKit

class StatusTableViewController: UITableViewController {
    
    // MARK: - Vars
    
    var allStatuses: [String] = []
    
    // MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserStatus()
        tableView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StatusCell", for: indexPath)
        
        let status = allStatuses[indexPath.row]
        cell.textLabel?.text = status
        cell.accessoryType = User.currentUser?.status == status ? .checkmark : .none
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        updateCellCheck(indexPath)
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableviewBackgroundColor")
        return headerView
    }
    
    //MARK: - LoadingStatus
    private func loadUserStatus() {
        allStatuses = UserDefaults.standard.object(forKey: kSTATUS) as! [String]
    }
    
    private func updateCellCheck(_ indexPath: IndexPath) {
        
        if var user = User.currentUser {
            user.status = allStatuses[indexPath.row]
            saveUserLocally(user: user)
            FirebaseUserListener.shared.saveUserToFireStore(user: user)
        }
        
    }
    
}
