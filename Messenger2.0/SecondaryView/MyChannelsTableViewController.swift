//
//  MyChannelsTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 15.02.2024.
//

import UIKit

class MyChannelsTableViewController: UITableViewController {
    
    //MARK: - Vars
    var myChannels: [Channel] = []
    
    
    //MARK: - Views Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        downloadUserChannels()
        
    }
    //MARK: - IBActions
    @IBAction func addBarButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "myChannelToAddSeg", sender: self)
    }
    
    
    //MARK: - Download Channels
    private func downloadUserChannels() {
        FirebaseChannelListener.shared.downloadUserChannelsFromFirebase { (allChannels) in
            self.myChannels = allChannels
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myChannels.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
        
        cell.configure(channel: myChannels[indexPath.row])
        
        return cell
    }
    
    //MARK: - TableView Delegates
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "myChannelToAddSeg", sender: myChannels[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let channelToDelete = myChannels[indexPath.row]
            myChannels.remove(at: indexPath.row)
            FirebaseChannelListener.shared.deleteChannel(channelToDelete)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "myChannelToAddSeg" {
            let editChannelView = segue.destination as! AddChannelTableViewController
            editChannelView.channelToEdit = sender as? Channel
        }
    }
    
    
    
    
}
