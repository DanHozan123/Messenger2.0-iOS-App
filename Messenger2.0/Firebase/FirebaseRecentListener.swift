//
//  FirebaseRecentListener.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 09.02.2024.
//

import Foundation
import Firebase


class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init() {}
    
    func saveRecent(_ recent: RecentChat) {
        
        do {
            try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print("Error saving recent chat ", error.localizedDescription)
        }
    }
    
    
}
