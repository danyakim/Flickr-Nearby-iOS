//
//  SceneDelegate.swift
//  Flickr
//
//  Created by Daniil Kim on 05.05.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene,
               willConnectTo session: UISceneSession,
               options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        
        window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = TabBarController()
        window?.makeKeyAndVisible()
        window?.windowScene = windowScene
    }

}

