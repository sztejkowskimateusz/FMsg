//
//  NewConversationViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    public var choosenChatCompletion: (([String: String]) -> (Void))?
                    
    private let progressBar = JGProgressHUD(style: .dark)
    
    private var users = [[String: String]]()
    private var alreadyFetched = false
    private var filterResults = [[String: String]]()
    

    private let search: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Wyszukaj użytkownika"
        return searchBar
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.isHidden = true
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = filterResults[indexPath.row]["name"]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let wybranyCzat = filterResults[indexPath.row]
        
        dismiss(animated: true) { [weak self] in
            self?.choosenChatCompletion?(wybranyCzat)
        }
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
        guard alreadyFetched else {
            return
        }
        
        self.progressBar.dismiss()
        let results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() else {
                return false
            }
            
            return name.hasPrefix(filter.lowercased())
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
