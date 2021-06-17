//
//  ViewController.swift
//  qckMSG
//
//  Created by Mateusz on 15/04/2021.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

struct Chat {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMsg
}

struct LatestMsg {
    let date: String
    let text: String
    let isRead: Bool
}

class ConversationsViewController: UIViewController {
    
    private let progressBar = JGProgressHUD(style: .dark)
    
    private var chats = [Chat]()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.translatesAutoresizingMaskIntoConstraints = false
        table.isHidden = true
        table.register(ConversationTableViewCell.self,
                       forCellReuseIdentifier: ConversationTableViewCell.cellIdentifier)
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
    
    private var obserwatorLogowania: NSObjectProtocol?
        
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(composeActivated))
        title = "Wiadomości"
        navigationController?.navigationBar.prefersLargeTitles = true
        view.addSubview(emptyConversationsPrompt)
        view.addSubview(tableView)
        configureTable()
        getConversations()
        startListeningForChats()
        
        obserwatorLogowania = NotificationCenter.default.addObserver(forName: .zalogowanoPowiadomienie,
                                               object: nil,
                                               queue: .main) { [weak self] _ in
            guard let strongSelf = self else {
                print("error zalogowano powiadomienie")
                return
            }
            
            strongSelf.startListeningForChats()
        }
    }
    
    private func startListeningForChats() {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        
        if let observer = obserwatorLogowania {
            NotificationCenter.default.removeObserver(observer)
        }
        
        let safeEmail = DatabaseService.safeID(email: email)
        DatabaseService.shared.fetchAllConversations(for: safeEmail) { [weak self] (result) in
            switch result {
            case .success(let convs):
                guard !convs.isEmpty else {
                    return
                }
                
                self?.chats = convs 
                
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            case .failure(let error):
                print("Failed to fetch chats \(error)")
            }
        }
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
    
    private func createNewChat(choosenUser: WynikWyszukiwania) {
        
        let nameOfPersonToStartChatWith = choosenUser.name
        let email = choosenUser.email
            
        let safeEmail = DatabaseService.safeID(email: email)
        
        let chatVC = ChatViewController(with: safeEmail, id: nil)
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
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let model = chats[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: ConversationTableViewCell.cellIdentifier, for: indexPath) as! ConversationTableViewCell
        cell.configureCell(with: model)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let model = chats[indexPath.row]
        
        let chatVC = ChatViewController(with: model.otherUserEmail, id: model.id)
        chatVC.navigationItem.largeTitleDisplayMode = .never
        chatVC.title = model.name
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .delete
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            //usuwanie konwersacji
            let chatId = chats[indexPath.row].id
            tableView.beginUpdates()
            
            DatabaseService.shared.usunChat(conversaitonId: chatId) { [weak self] (success) in
                if success {
                    self?.chats.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .left)
                }
            }
            tableView.endUpdates()
        }
    }
    
    
}

