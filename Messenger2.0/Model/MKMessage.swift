//
//  MKMessage.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 12.02.2024.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mkSender: MKSender
    var sender: SenderType { return mkSender }
    var senderInitials: String
    
    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    
    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {
        
        self.messageId = message.id
        
        self.mkSender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status
        self.kind = MessageKind.text(message.message)
        
        
        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
            
        case kPHOTO:
            let photoItem = PhotoMessage(path: message.pictureUrl)
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
            let videoItem = VideoMessage(url: nil)
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        default:
            self.kind = MessageKind.text(message.message)
            print("unknown message type")
        }
        
        self.senderInitials = message.senderinitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId != mkSender.senderId
    }
    
    
    
}
