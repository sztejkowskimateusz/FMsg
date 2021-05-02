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
    
    var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(
            UITableViewCell.self,
            forCellReuseIdentifier: "komorka")
        return tableView
    }()
    
    let data = ["Wyloguj się"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        title = "Profil"
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        tableView.tableHeaderView = createHeader()

        
    }
    
    func createHeader() -> UIView? {
        
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return nil
        }
        let safeId = DatabaseService.safeID(email: email)
        let filename = safeId + "_profile_picture.png"
        let path = "images/" + filename
        
        
        let headerView = UIView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 300))
        view.backgroundColor = .link
        
        let imageView = UIImageView(frame: CGRect(x: (view.frame.size.width-150)/2, y: 75, width: 150, height: 150))
        imageView.contentMode = .scaleAspectFill
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.cornerRadius = imageView.width/2
        imageView.layer.borderWidth = 3
        imageView.layer.masksToBounds = true
        
        headerView.addSubview(imageView)

        StorageService.instance.downloadURL(for: path) { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadAvatar(imageView: imageView, url: url)
            case .failure(let error):
                print(error)
            }
        }
        
        return headerView
    }
    
    func downloadAvatar(imageView: UIImageView, url: URL) {
        URLSession.shared.dataTask(with: url) { (data, _, error) in
            guard let data = data, error == nil else {
                return
            }
            
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                imageView.image = image
            }
        }.resume()
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
