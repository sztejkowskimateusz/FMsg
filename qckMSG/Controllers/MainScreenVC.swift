//
//  MainScreenVC.swift
//  qckMSG
//
//  Created by Mateusz on 16/04/2021.
//

import UIKit

class MainScreenVC: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let conversationsItem = UINavigationController(rootViewController: ConversationsViewController())
        conversationsItem.tabBarItem = UITabBarItem(title: "Wiadomości", image: UIImage(systemName: "message.circle.fill"), tag: 0)
        let optionsItem = UINavigationController(rootViewController: ProfileViewController())
        optionsItem.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person.crop.circle.fill"), tag: 1)

        setViewControllers([conversationsItem, optionsItem], animated: true)
        
    }
    


}
