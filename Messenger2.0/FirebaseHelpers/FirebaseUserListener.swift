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
    
    func loginUserWithEmail(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {
        
        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in
            
            if error == nil && authDataResult!.user.isEmailVerified {
                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)
                completion(error, true)
            } else {
                print("email is not verified")
                completion(error, false)
            }
        }
    }
    
    //MARK: - Register
    func registerUserWith(email: String, password: String, complition: @escaping(_ error: Error?) -> Void){
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
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there I'm using Messegenr")
                    saveUserLocally(user: user)
                    self.saveUserToFireStore(user: user)
                }
            }
            
        }
    }
    
    //MARK: - Resend link methods
        func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void) {
            
            Auth.auth().currentUser?.reload(completion: { (error) in
                
                Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                    completion(error)
                })
            })
        }
    
    
    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
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
    
    //MARK: - Download
    
    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(collectionReferance: .User).document(userId).getDocument { (querySnapshot, error) in
            
            guard let document = querySnapshot else {
                print("no document for user")
                return
            }
            
            let result = Result {
                try? document.data(as: User.self)
            }
            
            switch result {
            case .success(let userObject):
                if let user = userObject {
                    saveUserLocally(user: user)
                } else {
                    print(" Document does not exist")
                }
            case .failure(let error):
                print("Error decoding user ", error)
            }
        }
    }
    
    
    
}
