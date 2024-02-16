//
//  ChannelChatViewController.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 16.02.2024.
//

import Foundation
import MessageKit
import InputBarAccessoryView
import RealmSwift
import YPImagePicker

class ChannelChatViewController: MessagesViewController {
    
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""
    
    var channel: Channel!
    
    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)
    
    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    
    let refreshController = UIRefreshControl()
    var gallery: YPImagePicker!
    
    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0
    
    var mkMessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!
    
    let realm = try! Realm()
    
    let micButton = InputBarButtonItem()
    
    //Listeners
    var notificationToken: NotificationToken?
    
    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName = ""
    var audioDuration: Date!
    
    //MARK: - Inits
    init(channel: Channel) {
        
        super.init(nibName: nil, bundle: nil)
        
        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    //MARK: - View LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
                
        configureLeftBarButton()
        configureCustomTitle()

        configureMessageCollectionView()
        configureGestureRecognizer()
        
        configureMessageInputBar()

        loadChats()
        listenForNewChats()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }
    
    //MARK: - Configurations
    private func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        
        scrollsToLastItemOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshController
    }
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true
    }
    
    private func configureMessageInputBar() {
        messageInputBar.isHidden = channel.adminId != User.currentId
        messageInputBar.delegate = self
        
        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        
        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onTouchUpInside {
            item in
            
            self.actionAttachMessage()
        }
        
        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        micButton.addGestureRecognizer(longPressGesture)
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)
        
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        
        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    private func configureCustomTitle() {
        self.title = channel.name
    }
    
    func updateMicButtonStatus(show: Bool) {
        
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    
    
    //MARK: - Load Chats
    private func loadChats() {
        
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)
        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in
            
            //updated message
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
                
            case .update(_, _ , let insertions, _):
                for index in insertions {
                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: false)
                }
                
            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }
    
    private func listenForNewChats() {
        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }
    
    private func checkForOldChats() {
        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }
    
    
    
    
    //MARK: - Insert Messages
    private func insertMessages() {
        
        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }
    
    private func insertMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }
    
    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
        }
    }
    
    
    private func insertOlderMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(_collectionView: self)
        self.mkMessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
        displayingMessagesCount += 1
    }
    
    
    //MARK: - Actions
    
    
    @objc func backButtonPressed() {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }
    
    func messageSend(text: String?, photo: UIImage?, video: YPMediaVideo?, audio: String?, location: String?, audioDuration: Float = 0.0) {
        
        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location)
    }
    
    
    
    private func actionAttachMessage() {
        
        messageInputBar.inputTextView.resignFirstResponder()
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhoto = UIAlertAction(title: "Library Photo", style: .default) { (alert) in
            self.showImageGallery(camera: true)
        }
        
        let takeVideo = UIAlertAction(title: "Library Video", style: .default) { (alert) in
            self.showImageGallery(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: "Share Location", style: .default) { (alert) in
            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            } else {
                print("no access to location")
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        optionMenu.addAction(takePhoto)
        optionMenu.addAction(takeVideo)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    
    
    //MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if refreshController.isRefreshing {
            if displayingMessagesCount < allLocalMessages.count {
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            
            refreshController.endRefreshing()
        }
    }
    
    //MARK: - Helpers
    
    private func removeListeners() {
        FirebaseMessageListener.shared.removeListeners()
    }
    
    private func lastMessageDate() -> Date {
        
        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    
    //MARK: - AudioMessages
    @objc func recordAudio() {
        switch longPressGesture.state {
        case .began:
            
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            AudioRecorder.shared.finishRecording()
            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioD = audioDuration.interval(ofComponent: .second, from: Date())
                
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("no audio file")
            }
            audioFileName = ""
        case .possible:
            print("possible")
        case .changed:
            print("changed")
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("unknown")
        }
        
    }
    
    //MARK: - Gallery
    private func showImageGallery(camera: Bool) {
        
        gallery = YPImagePicker()
        
        var config = YPImagePickerConfiguration()
        config.showsPhotoFilters = false
        config.library.maxNumberOfItems = 1
        
        if camera {
            config.screens = [.library, .photo]
            config.library.mediaType = .photo
        } else {
            config.screens = [.library, .video]
            config.library.mediaType = .video
            
        }
        
        gallery = YPImagePicker(configuration: config)
        gallery.didFinishPicking { [unowned gallery] items, cancelled in
            if cancelled {
                print("Gallery was canceled")
            }
            
            for item in items {
                switch item {
                case .photo(let photo):
                    if items.count > 0 {
                        self.messageSend(text: nil, photo: photo.image, video: nil, audio: nil, location: nil)
                    }
                    
                case .video(let video):
                    if items.count > 0 {
                        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
                    }
                }
                
            }
            gallery!.dismiss(animated: true, completion: nil)
        }
        present(gallery, animated: true, completion: nil)
    }
    
    
}


