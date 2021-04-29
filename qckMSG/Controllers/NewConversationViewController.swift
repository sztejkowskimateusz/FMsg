//
//  NewConversationViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import JGProgressHUD

class NewConversationViewController: UIViewController {
    
    private let progressBar = JGProgressHUD(style: .dark)

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
    }
    
    @objc private func dismissView() {
        dismiss(animated: true, completion: nil)
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
    }
    
}
