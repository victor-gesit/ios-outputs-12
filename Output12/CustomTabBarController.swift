//
//  CustomTabBarController.swift
//  Output12
//
//  Created by Victor Idongesit on 04/12/2017.
//  Copyright © 2017 Victor Idongesit. All rights reserved.
//

import UIKit
class CustomTabBarController: UITabBarController {
    override func viewDidLoad() {
        viewControllers = []
        super.viewDidLoad()
        let layout = UICollectionViewFlowLayout()
        let friendsViewController = FriendsController(collectionViewLayout: layout)
        let recentMessagesNavController = UINavigationController(rootViewController: friendsViewController)
        recentMessagesNavController.tabBarItem.title = "Recent"
        let buttonImage = UIImage(named: "recent")
        recentMessagesNavController.tabBarItem.image = buttonImage
        
        let callsNavController = createDummyNavControllerWithTitle(title: "Calls", imageName: "calls")
        let groupsNavController = createDummyNavControllerWithTitle(title: "Groups", imageName: "groups")
        let peopleNavController = createDummyNavControllerWithTitle(title: "People", imageName: "people")
        let settingsNavController = createDummyNavControllerWithTitle(title: "Settings", imageName: "settings")
        viewControllers = [recentMessagesNavController, callsNavController, groupsNavController, peopleNavController, settingsNavController]
    }
    private func createDummyNavControllerWithTitle(title: String, imageName: String, rootViewController: UIViewController? = nil) -> UIViewController {
        let dummyController = UIViewController()
        let dummyNavController = UINavigationController(rootViewController: dummyController)
        dummyNavController.tabBarItem.title = title
        dummyNavController.tabBarItem.image = UIImage(named: imageName)
        return dummyNavController
    }
}
