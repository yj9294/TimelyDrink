//
//  SceneDelegate.swift
//  TimelyDrink
//
//  Created by yangjian on 2023/5/15.
//

import UIKit
import Firebase

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
        
        launching()
        FirebaseApp.configure()
        NotificationUtil.shared.register()
        FirebaseUtil.log(event: .open)
        FirebaseUtil.log(event: .openCold)
    }

    func sceneDidDisconnect(_ scene: UIScene) {
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        if !(window?.rootViewController is LaunchVC) {
            FirebaseUtil.log(event: .openHot)
        }
        launching()
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

extension SceneDelegate {
    
    func launching() {
        window?.rootViewController = LaunchVC {
            self.window?.rootViewController = HomeVC()
        }
    }
}

