//
//  ViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

class ConversationsViewController: UIViewController {
    
    private let progressBar = JGProgressHUD(style: .dark)
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        table.register(UITableViewCell.self,
                       forCellReuseIdentifier: "cell")
        return table
    }()
    
    private let emptyConversationsPrompt: UILabel = {
        let prompt = UILabel()
        prompt.text = "Brak aktywnych konwersacji"
        prompt.textAlignment = .center
        prompt.textColor = .gray
        prompt.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        prompt.isHidden = true
        return prompt
    }()
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeActivated))
        title = "Wiadomości"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(emptyConversationsPrompt)
        view.addSubview(tableView)
        configureTable()
        getConversations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupConstraints()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        uwierzytelnianieUzytkownika()
    }
    
    @objc func composeActivated() {
        
        let newChatVC = NewConversationViewController()
        newChatVC.choosenChatCompletion = { [weak self] result in
            self?.createNewChat(choosenUser: result)
        }
        
        let navVC = UINavigationController(rootViewController: newChatVC)
        present(navVC, animated: true, completion: nil)
    }
    
    private func createNewChat(choosenUser: [String: String]) {
        
        guard let nameOfPersonToStartChatWith = choosenUser["name"],
              let email = choosenUser["email"] else {
            return
        }
        
        let chatVC = ChatViewController(with: email)
        chatVC.isEmptyConversation = true
        chatVC.navigationItem.largeTitleDisplayMode = .never
        chatVC.title = nameOfPersonToStartChatWith
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    private func configureTable() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func getConversations() {
        tableView.isHidden = false
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

extension ConversationsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.accessoryType = .disclosureIndicator 
        cell.textLabel?.text = "Test"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatVC = ChatViewController(with: "szteja@gmail.com")
        chatVC.navigationItem.largeTitleDisplayMode = .never
        chatVC.title = "Nikos Pietrzak"
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
}

