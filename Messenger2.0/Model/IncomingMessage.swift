//
//  IncomingMessage.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 13.02.2024.
//

import Foundation


import Foundation
import MessageKit
import CoreLocation

class IncomingMessage {
    
    var messageCollectionView: MessagesViewController
    
    init(_collectionView: MessagesViewController) {
        messageCollectionView = _collectionView
    }
    
    //MARK: - CreateMessage
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {
        
        let mkMessage = MKMessage(message: localMessage)
        
        return mkMessage
    
    }
    
    
}
