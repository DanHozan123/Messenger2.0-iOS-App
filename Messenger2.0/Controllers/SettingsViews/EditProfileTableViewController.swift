//
//  EditProfileTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 07.02.2024.
//

import UIKit
import YPImagePicker

class EditProfileTableViewController: UITableViewController {
    
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var usernameTextField: UITextField!
    
    //MARK - Vars
    var picker: YPImagePicker?
    
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTextField()
        setupPicker()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        showUserInfo()
    }
    
    
    // MARK: - Table view delegate
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // to do  show status view
        if indexPath.section == 1 && indexPath.row == 0 {
            performSegue(withIdentifier: "editProfileToStatusSegue", sender: self)
        }
        
    }
    
    //MARK: - IBActions
    
    @IBAction func editButtonPressed(_ sender: Any) {
        showPicker()
    }
    
    
    //MARK: - UpdateUI
    
    private func showUserInfo() {
        
        if let user = User.currentUser {
            usernameTextField.text = user.username
            statusLabel.text = user.status
            
            if user.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }
    
    //MARK: - Configure
    private func configureTextField() {
        usernameTextField.delegate = self
        usernameTextField.clearButtonMode = .whileEditing
    }
    
    func setupPicker() {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.screens = [.library]
        
        config.library.maxNumberOfItems = 3
        
        picker = YPImagePicker(configuration: config)
    }
    
    func showPicker() {
        
        guard let picker = picker else { return }
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    //this is just an example to show in imageView
                    
                    DispatchQueue.main.async {
                        self.uploadAvatarImage(photo.image)
                        self.avatarImageView.image = photo.image
                    }
                case .video(let video):
                    //if you need to access videos as well
                    print(video)
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - UploadImages
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(User.currentId)" + ".jpg"
        
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            
            if var user = User.currentUser {
                user.avatarLink = avatarLink ?? ""
                saveUserLocally(user: user)
                FirebaseUserListener.shared.saveUserToFireStore(user: user)
            }
            
            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName: User.currentId)
        }
    }
       
}


extension EditProfileTableViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == usernameTextField {
            
            if textField.text != "" {
                
                if var user = User.currentUser {
                    user.username = textField.text!
                    saveUserLocally(user: user)
                    FirebaseUserListener.shared.saveUserToFireStore(user: user)
                }
            }
            textField.resignFirstResponder()
            return false
        }
        
        return true
    }
    
    
}

