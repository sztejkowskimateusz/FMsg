//
//  ViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth

class ConversationsViewController: UIViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Wiadomości"
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uwierzytelnianieUzytkownika()
    }
    
    private func uwierzytelnianieUzytkownika() {
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.hidesBarsOnSwipe = true
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: true)
        }
    }
    
    
}

