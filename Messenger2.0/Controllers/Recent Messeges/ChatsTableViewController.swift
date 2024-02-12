//
//  ChatsTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 12.02.2024.
//

import UIKit

class ChatsTableViewController: UITableViewController {
    
    //MARK: - Vars
    var allRecents:[RecentChat] = []
    var filteredRecents:[RecentChat] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    //MARK: - IBActions
    
    @IBAction func composeBarButtonPressed(_ sender: Any) {
        
        let userView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "usersView") as! UsersTableViewController
        
        navigationController?.pushViewController(userView, animated: true)
        
    }
    
    //MARK: - ViewLifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        downloadRecentChats()
        setupSearchController()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchController.isActive ? filteredRecents.count : allRecents.count
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
        cell.configure(recent: recent)
        
        return cell
    }
    
    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            var recentToDelete: RecentChat
            
            if searchController.isActive {
                recentToDelete = filteredRecents.remove(at: indexPath.row)
            } else {
                recentToDelete = allRecents.remove(at: indexPath.row)
            }
            
            FirebaseRecentListener.shared.deleteRecent(recentToDelete)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    
    //MARK: - Download Chats
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { (allChats) in
            self.allRecents = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - Search controller
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search user"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }
    
    private func filteredContentForSearchText(searchText: String) {
        filteredRecents = allRecents.filter({ (recent) -> Bool in
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    
    //MARK: - Navigation
    
    private func goToChat(recent: RecentChat) {
        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)
        
        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
        
        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }
    
    
}

extension ChatsTableViewController: UISearchResultsUpdating {
    
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
