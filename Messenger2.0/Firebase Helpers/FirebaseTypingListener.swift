//
//  FirebaseTypingListener.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 13.02.2024.
//

import Foundation
import Firebase
import FirebaseFirestore


class FirebaseTypingListener {
    
    static let shared = FirebaseTypingListener()
    
    var typingListener: ListenerRegistration!
    
    private init() { }
    
    func createTypingObserver(chatRoomId: String, completion: @escaping (_ isTyping: Bool) -> Void) {
        
        typingListener = FirebaseReference(collectionReferance: .Typing).document(chatRoomId).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if snapshot.exists {
                for data in snapshot.data()! {
                    if data.key != User.currentId {
                        completion(data.value as! Bool)
                    }
                }
            } else {
                completion(false)
                FirebaseReference(collectionReferance: .Typing).document(chatRoomId).setData([User.currentId : false])
            }
        })
    }
    
    class func saveTypingCounter(typing: Bool, chatRoomId: String) {
        
        FirebaseReference(collectionReferance: .Typing).document(chatRoomId).updateData([User.currentId : typing])
        
    }
    
    func removeTypingListener() {
        self.typingListener.remove()
    }
    
}
