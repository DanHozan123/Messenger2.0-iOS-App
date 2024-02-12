//
//  StartChat.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 09.02.2024.
//

import Foundation
import Firebase
import FirebaseFirestore



//MARK: - StartChat
func startChat(user1: User, user2: User) -> String {
    
    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}

func restartChat(chatRoomId: String, memberIds: [String]) {
    
    FirebaseUserListener.shared.downloadUsersFromFirebase(withIds: memberIds) { (users) in
        if users.count > 0 {
            createRecentItems(chatRoomId: chatRoomId, users: users)
        }
    }
}

//MARK: - RecentChats

func createRecentItems(chatRoomId: String, users: [User]) {
    
    var memberIdsToCreateRecent = [users.first!.id, users.last!.id]
    
    //does user have recent?
    FirebaseReference(collectionReferance: .Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        for userId in memberIdsToCreateRecent {
            let senderUser = userId == User.currentId ? User.currentUser! : getReceiverFrom(users: users)
            let receiverUser = userId == User.currentId ? getReceiverFrom(users: users) : User.currentUser!
            
            let recentObject = RecentChat(id: UUID().uuidString, chatRoomId: chatRoomId, senderId: senderUser.id, senderName: senderUser.username, receiverId: receiverUser.id, receiverName: receiverUser.username, date: Date(), memberIds: [senderUser.id, receiverUser.id], lastMessage: "", unreadCounter: 0, avatarLink: receiverUser.avatarLink)
            
            FirebaseRecentListener.shared.saveRecent(recentObject)
        }
        
    }
}

func getReceiverFrom(users: [User]) -> User {
    
    var allUsers = users
    
    allUsers.remove(at: allUsers.firstIndex(of: User.currentUser!)!)
    
    return allUsers.first!
}
func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    var memberIdsToCreateRecent = memberIds
    for recentData in snapshot.documents {
        let currentRecent = recentData.data() as Dictionary
        if let currentUserId = currentRecent[kSENDERID] {
            
            if memberIdsToCreateRecent.contains(currentUserId as! String) {
                
                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }
    
    return memberIdsToCreateRecent
}


func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue
    
    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)
    
    return chatRoomId
}
