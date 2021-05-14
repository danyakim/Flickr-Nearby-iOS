//
//  TabBarController.swift
//  Flickr
//
//  Created by Daniil Kim on 14.05.2021.
//

import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UITabBar.appearance().isTranslucent = false
        
        let nearbyCollectionVC = createNavController(for: GalleryCollectionVC(collectionViewLayout: UICollectionViewFlowLayout()),
                                                     title: "Nearby",
                                                     image: UIImage(systemName: "mappin.and.ellipse"))
        
        let searchCollectionVC = createNavController(for: GalleryCollectionVC(collectionViewLayout: UICollectionViewFlowLayout()),
                                                     title: "Search",
                                                     image: UIImage(systemName: "magnifyingglass"),
                                                     tag: 1)
        
        viewControllers = [nearbyCollectionVC, searchCollectionVC]
    }
    
    func createNavController(for rootViewController: UIViewController,
                             title: String,
                             image: UIImage?,
                             tag: Int = 0) -> UIViewController {
        let navController = UINavigationController(rootViewController: rootViewController)
        navController.tabBarItem.title = title
        navController.tabBarItem.image = image
        navController.tabBarItem.tag = tag
        return navController
    }
    
}
