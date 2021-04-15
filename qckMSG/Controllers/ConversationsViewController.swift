//
//  ViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit

class ConversationsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let isLoggedIn = UserDefaults.standard.bool(forKey: "logged_in")
        
        if !isLoggedIn {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.hidesBarsOnSwipe = true
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }


}

