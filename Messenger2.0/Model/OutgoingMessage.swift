//
//  OutgoingMessage.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 12.02.2024.
//

import Foundation
import UIKit
import FirebaseFirestoreSwift
import YPImagePicker


class OutgoingMessage {
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: String?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
        let currentUser = User.currentUser!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        message.senderinitials = String(currentUser.username.first!)
        message.date = Date()
        message.status = kSENT
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        //TODO: Send push notification
        //TODO: Update recent
        
        //FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }
    
    class func sendMessage(message: LocalMessage, memberIds: [String]) {
        
        RealmManager.shared.saveToRealm(message)
        
        for memberId in memberIds {
            FirebaseMessageListener.shared.addMessage(message, memberId: memberId)
        }
    }
    
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    
    message.message = text
    message.type = kTEXT
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
    
    
}