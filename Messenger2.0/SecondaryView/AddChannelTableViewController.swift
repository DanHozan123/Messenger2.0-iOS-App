//
//  AddChannelTableViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 15.02.2024.
//

import UIKit
import ProgressHUD
import YPImagePicker

class AddChannelTableViewController: UITableViewController {
    
    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!
    
    
    //MARK: - Vars
    var picker: YPImagePicker?
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    var channelId = UUID().uuidString
    
    var channelToEdit: Channel?
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        configureGestures()
        configureLeftBarButton()
        configureYPImagePicker()
        
        if channelToEdit != nil {
            configureEditingView()
        }
    }
    
    //MARK: - IBActions
    @IBAction func saveButtonPressed(_ sender: Any) {
        if nameTextField.text != "" {
            
            channelToEdit != nil ? editChannel() : saveChannel()
        } else {
            ProgressHUD.error("Channel name is empty!")
        }
    }
    
    @objc func avatarImageTap() {
        showGallery()
    }
    
    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK: - Configuration
    private func configureGestures() {
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(backButtonPressed))
    }
    
    func configureYPImagePicker() {
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.screens = [.library]
        config.library.maxNumberOfItems = 1
        picker = YPImagePicker(configuration: config)
    }
    
    private func configureEditingView() {
        self.nameTextField.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutTextView.text = channelToEdit!.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        self.title = "Editing Channel"
        
        setAvatar(avatarLink: channelToEdit!.avatarLink)
    }
    
    //MARK: - Save Channel
    private func saveChannel() {
        let channel = Channel(id: channelId, name: nameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)
        FirebaseChannelListener.shared.saveCannel(channel)
        self.navigationController?.popViewController(animated: true)
    }
    
    private func editChannel() {
        
        channelToEdit!.name = nameTextField.text!
        channelToEdit!.aboutChannel = aboutTextView.text
        channelToEdit!.avatarLink = avatarLink
        
        FirebaseChannelListener.shared.saveCannel(channelToEdit!)
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: - Gallery
    func showGallery() {
        guard let picker = picker else { return }
        picker.didFinishPicking { [unowned picker] items, _ in
            if let photo = items.singlePhoto {
                DispatchQueue.main.async {
                    self.uploadAvatarImage(photo.image)
                    self.avatarImageView.image = photo.image.circleMasked
                }
            }
            picker.dismiss(animated: true, completion: nil)
        }
        present(picker, animated: true, completion: nil)
    }
    
    //MARK: - Avatars
    private func uploadAvatarImage(_ image: UIImage) {
        
        let fileDirectory = "Avatars/" + "_\(channelId)" + ".jpg"
        
        FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 0.7)! as NSData, fileName: self.channelId)
        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in
            self.avatarLink = avatarLink ?? ""
        }
    }
    
    private func setAvatar(avatarLink: String) {
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                DispatchQueue.main.async {
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }
    
    
}
