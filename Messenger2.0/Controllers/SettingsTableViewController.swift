//
//  SettingsTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 06.02.2024.
//

import UIKit

class SettingsTableViewController: UITableViewController {

    //MARK: - IBLabels
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var avatarImageView: UIImageView!
    
    @IBOutlet weak var appVersionLabel: UILabel!
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        showUserInfo()
    }
    
    
    //MARK: - TableView Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 && indexPath.row == 0 {
            performSegue(withIdentifier: "settingsToEditProfileSegue", sender: self)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    //MARK: - IBActions
    @IBAction func logOutButtonPressed(_ sender: Any) {
        FirebaseUserListener.shared.logOutCurrentUser { (error) in
            
            if error == nil {
                let loginView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "LoginView")
                
                DispatchQueue.main.async {
                    loginView.modalPresentationStyle = .fullScreen
                    self.present(loginView, animated: true, completion: nil)
                }
            }
        }
    }
    
    @IBAction func termsAndConditionsButtonPressed(_ sender: Any) {
    }

    @IBAction func tellAFriendButtonPressed(_ sender: Any) {
    }
    
    //MARK: - UpdateUI
        private func showUserInfo() {
            
            if let user = User.currentUser {
                usernameLabel.text = user.username
                statusLabel.text = user.status
                appVersionLabel.text = "App version \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")"
                
                
                if user.avatarLink != "" {
                   // download image
                }
            }
        }
    

}
