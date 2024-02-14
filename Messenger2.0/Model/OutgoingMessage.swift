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
    
    class func send(chatId: String, text: String?, photo: UIImage?, video: YPMediaVideo?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {
        
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
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            //sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
        }
        
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
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

func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {
    message.message = "Picture Message"
    message.type = kPHOTO
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    
    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in
        
        if imageURL != nil {
            message.pictureUrl = imageURL!
            OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
            
        }
    }
}

func sendVideoMessage(message: LocalMessage, video: YPMediaVideo, memberIds: [String]) {
    
    message.message = "Video Message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_\(fileName)" + ".mov"
    
    
    let tempPath = video.url
    
    let thubnail = video.thumbnail
    
    FileStorage.saveFileLocally(fileData: thubnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
    
    FileStorage.uploadImage(thubnail, directory: thumbnailDirectory) { (imageLink) in
        
        if imageLink != nil {
            
            let videoData = NSData(contentsOfFile: tempPath.path)
            
            FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
            
            FileStorage.uploadVideo(videoData!, directory: videoDirectory) { (videoLink) in
                
                message.pictureUrl = imageLink ?? ""
                message.videoUrl = videoLink ?? ""
                
                
                OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
                
            }
        }
    }
    
}

func sendLocationMessage(message: LocalMessage, memberIds: [String]) {

    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    OutgoingMessage.sendMessage(message: message, memberIds: memberIds)
    
}

