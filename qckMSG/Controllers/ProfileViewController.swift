//
//  ProfileViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
import GoogleSignIn

class ProfileViewController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "komorka")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        return tableView
    }()
    
    let data = ["Wyloguj się"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profil"
        view.addSubview(tableView)
    }
    
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "komorka", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.textColor = .red
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let alertWindow = UIAlertController(
            title: "",
            message: "",
            preferredStyle: .actionSheet)
        alertWindow.addAction(UIAlertAction(
                                title: "Wyloguj",
                                style: .destructive,
                                handler: { [weak self] _ in
                                    
                                    guard let self = self else {
                                        return
                                    }
                                    
                                    FBSDKLoginKit.LoginManager().logOut()
                                    
                                    GIDSignIn.sharedInstance()?.signOut()
                                    
                                    do {
                                        try FirebaseAuth.Auth.auth().signOut()
                                        
                                        //karta logowania
                                        let vc = LoginViewController()
                                        let nav = UINavigationController(rootViewController: vc)
                                        nav.hidesBarsOnSwipe = true
                                        nav.modalPresentationStyle = .fullScreen
                                        self.present(nav, animated: true)
                                    }
                                    catch {
                                        print("Nie udało się wylogować")
                                    }
                                }))
        alertWindow.addAction(UIAlertAction(title: "Anuluj", style: .cancel, handler: nil))
        present(alertWindow, animated: true)
        
    }
    
    
}
