//
//  ChatViewController.swift
//  qckMSG
//
//  Created by Mateusz on 29/04/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView

struct Message: MessageType {
  public var sender: SenderType
  public var messageId: String
  public var sentDate: Date
  public var kind: MessageKind
}

extension MessageKind {
    var msgKindString: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributed_text"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "link_preview"
        case .custom(_):
            return "custom"
        }
    }
}

struct Sender: SenderType {
  public var senderId: String
  public var displayName: String
  public var profilePictureURL: String
}

class ChatViewController: MessagesViewController {
    
    public let emailOfPersonToChatWith: String
    public var isEmptyConversation = false
    
    public static let dateFormat: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    
    private var msgs: [Message] = []
    
    private var senderSelf: Sender? {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            print("brak uzytkownika")
            return nil
        }
        print("gosciu: \(email)")
        return Sender(senderId: "",
               displayName: email,
               profilePictureURL: "Mateusz Sztejkowski")
    }
    
    init(with email: String) {
        self.emailOfPersonToChatWith = email
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
//              let selfSender = self.senderSelf,
               let msgId = creationOfParticularMsgId() else {
                print("????")
                return
        }
        
        print("wiadomosc: \(text)")
        
        if isEmptyConversation {
            //create nowy rekord w bazie
            let msg = Message(sender: senderSelf!,
                              messageId: msgId,
                              sentDate: Date(),
                              kind: .text(text))
            DatabaseService.shared.createNewChat(with: emailOfPersonToChatWith, msg: msg) { (success) in
                if success {
                    print("msg wysłano")
                }
                else {
                    print("nie wysłano")
                }
            }
        }
        else {
            //dodaj rekord w bazie
            print("AHAH")
        }
    }
    
    private func creationOfParticularMsgId() -> String? {
        
        let usrrr = UserDefaults.standard.value(forKey: "email")
        print(usrrr)
        
        guard let emailOfCurrentUser = UserDefaults.standard.value(forKey: "email") as? String else {
            print("xd")
            return nil
        }
        
        let safeEmailOfCurrentUser = DatabaseService.safeID(email: emailOfCurrentUser)
        
        let currDateToString = Self.dateFormat.string(from: Date())
        let newId = "\(emailOfPersonToChatWith)_\(safeEmailOfCurrentUser)_\(currDateToString)"
        print("msg id: \(newId)")
        
        return newId
    }
    
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = senderSelf {
            return sender
        }
        fatalError("ID nadawcy nie może być null")
        return Sender(senderId: "999", displayName: "", profilePictureURL: "")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return msgs[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return msgs.count
    }
    
    
}
