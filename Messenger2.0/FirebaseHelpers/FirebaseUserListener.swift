//
//  FirebaseUserListener.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 04.02.2024.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init () {}
    
    //MARK: - Login
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, complition: @escaping( _ error: Error?) -> Void){
        Auth.auth().createUser(withEmail: email, password: password) { ( authDataResult, error) in
            print()
            complition(error)
            if error == nil {
                //send verification mail
                authDataResult!.user.sendEmailVerification {(error) in
                    if error != nil {
                        print("Auth email sent with error: ", error!.localizedDescription)
                    }
                }
                //create user and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, username: email, mail: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messegenr")
                    saveUserLocally(user: user)
                    self.saveUserToFireStore(user: user)
                }
            }
            
        }
    }
    
    //MARK: - Save users
    func saveUserToFireStore(user: User){
        do {
            try FirebaseReference(collectionReferance: .User).document(user.id).setData(from: user)
        } catch {
            print(error.localizedDescription, " adding user")
        }
    }
    
    
}
