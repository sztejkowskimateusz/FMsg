//
//  NewConversationViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var choosenChatCompletion: ((WynikWyszukiwania) -> (Void))?
                    
    private let progressBar = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var alreadyFetched = false
    private var filterResults = [WynikWyszukiwania]()
    

    private let search: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Wyszukaj użytkownika"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(NewChatCell.self, forCellReuseIdentifier: NewChatCell.cellIdentifier)
        return table
    }()
    
    private let userNotFoundLabel: UILabel = {
        let label = UILabel()
        label.text = "Brak wyników zapytania"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .darkGray
        
        search.delegate = self
        navigationController?.navigationBar.topItem?.titleView = search
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(dismissView))
        search.becomeFirstResponder()
        
        view.addSubview(userNotFoundLabel)
        
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        tableView.frame = view.bounds
        userNotFoundLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            userNotFoundLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            userNotFoundLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userNotFoundLabel.heightAnchor.constraint(equalToConstant: 32)
        ])
        
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filterResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = filterResults[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: NewChatCell.cellIdentifier, for: indexPath) as! NewChatCell
        cell.configureCell(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let wybranyCzat = filterResults[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.choosenChatCompletion?(wybranyCzat)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 90
    }
}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = search.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        
        search.resignFirstResponder()
        filterResults.removeAll()
        progressBar.show(in: view)
        self.queryUsers(query: text)
    }
    
    func queryUsers(query: String) {
        if alreadyFetched {
            filterCollection(filter: query)
        }
        else {
            DatabaseService.shared.fetchAllUsers { [weak self] result in
                switch result {
                case .success(let usersCollection):
                    self?.alreadyFetched = true
                    self?.users = usersCollection
                    self?.filterCollection(filter: query)
                case .failure(let error):
                    print(error)
                }
            }
        }
    }
    
    func filterCollection(filter: String) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              alreadyFetched else {
            return
        }
        
        let currentUserSafeEmail = DatabaseService.safeID(email: currentUserEmail)
        
        self.progressBar.dismiss()
        let results: [WynikWyszukiwania] = self.users.filter({
            guard let email = $0["email"],
                  email != currentUserSafeEmail else {
                return false
            }
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(filter.lowercased())
        }).compactMap({
            
            guard let email = $0["email"],
                  let name = $0["name"] else {
                return nil
            }
            
            return WynikWyszukiwania(name: name, email: email)
        })
        
        self.filterResults = results
        showResults()
    }
    
    func showResults() {
        if filterResults.isEmpty {
            self.userNotFoundLabel.isHidden = false
            self.tableView.isHidden = true
        } else {
            self.userNotFoundLabel.isHidden = true
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }
    }
    
}

struct WynikWyszukiwania {
    let name: String
    let email: String
}
