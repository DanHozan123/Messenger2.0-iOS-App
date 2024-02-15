//
//  ChannelsTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 15.02.2024.
//

import UIKit

class ChannelsTableViewController: UITableViewController {
    
    // MARK: - IBOutlets
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    //MARK: - Vars
    var allChannels: [Channel] = []
    var subscribedChannels: [Channel] = []
    
    // MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .always
        self.title = "Channels"
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell
        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]
        
        cell.configure(channel: channel)
        
        return cell
        
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    //MARK: - IBActions
    @IBAction func channelSegmentValueChanged(_ sender: Any) {
    }
    
}
