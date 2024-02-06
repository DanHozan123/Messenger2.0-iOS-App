//
//  User.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 04.02.2024.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var pushId = ""
    var avatarLink = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {
                let decoder = JSONDecoder()
                
                do {
                    let userObject = try decoder.decode(User.self, from: dictionary)
                    return userObject
                } catch {
                    print("Error decoding user form user defaults", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }
    
}

func saveUserLocally(user: User) {
    let encoder = JSONEncoder()
    
    do {
        let data = try encoder.encode(user)
        // local memory
        UserDefaults.standard.set(data, forKey: kCURRENTUSER)
    } catch {
        print("error saving user locally", error.localizedDescription)
    }
}
