//
//  AppDelegate.swift
//  Messenger2.0
//
//  Created by Dan Hozan on 03.02.2024.
//

import UIKit
import Firebase

@main
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstRun: Bool?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        FirebaseApp.configure()
        firstRunCheck()
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //MARK: - FirstRun
        private func firstRunCheck() {
            firstRun = UserDefaults.standard.bool(forKey: kFIRSTRUN)
            
            if !firstRun! {
                let status = Status.allCases.map { $0.rawValue }
                
                UserDefaults.standard.set(status, forKey: kSTATUS)
                UserDefaults.standard.set(true, forKey: kFIRSTRUN)
                
                UserDefaults.standard.synchronize()
            }
        }

}

