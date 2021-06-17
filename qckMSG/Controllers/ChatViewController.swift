//
//  ChatViewController.swift
//  qckMSG
//
//  Created by Mateusz on 29/04/2021.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage
import AVFoundation
import AVKit


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

struct Media: MediaItem {
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

class ChatViewController: MessagesViewController {
    
    public let emailOfPersonToChatWith: String
    public var isEmptyConversation = false
    private var conversationId: String?
    
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
        let safeEmail = DatabaseService.safeID(email: email)
        
        return Sender(senderId: safeEmail,
                      displayName: "JA",
                      profilePictureURL: "")
    }
    
    init(with email: String, id: String?) {
        self.conversationId = id
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
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        setupInputBtn()
    }
    
    private func setupInputBtn() {
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.onTouchUpInside { [weak self] (_) in
            self?.showInputSheet()
        }
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    private func showInputSheet() {
        let actionSheet = UIAlertController(title: "Wybierz załącznik", message: "Co chciałbyś przesłać?", preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Zdjęcie",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.showPhotoChooserSheet()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Wideo",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                self?.showVideoChooserSheet()
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Audio",
                                            style: .default,
                                            handler: { [weak self] _ in
                                                
                                            }))
        actionSheet.addAction(UIAlertAction(title: "Anuluj",
                                            style: .destructive))
        present(actionSheet, animated: true)
    }
    
    private func showPhotoChooserSheet() {
        let photoChooserSheet = UIAlertController(title: "Załącz zdjęcie", message: "Wybierz źródło zdjęcia", preferredStyle: .actionSheet)
        photoChooserSheet.addAction(UIAlertAction(title: "Wybierz zdjęcie", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        photoChooserSheet.addAction(UIAlertAction(title: "Zrób zdjęcie", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        photoChooserSheet.addAction(UIAlertAction(title: "Anuluj", style: .destructive))
        present(photoChooserSheet, animated: true, completion: nil)
    }
    
    private func showVideoChooserSheet() {
        let videoChooserSheet = UIAlertController(title: "Załącz wideo", message: "Wybierz źródło filmu", preferredStyle: .actionSheet)
        videoChooserSheet.addAction(UIAlertAction(title: "Wybierz z galerii", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        videoChooserSheet.addAction(UIAlertAction(title: "Nagraj film", style: .default, handler: { [weak self] (_) in
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.mediaTypes = ["public.movie"]
            picker.videoQuality = .typeMedium
            picker.delegate = self
            picker.allowsEditing = true
            self?.present(picker, animated: true)
        }))
        videoChooserSheet.addAction(UIAlertAction(title: "Anuluj", style: .destructive))
        present(videoChooserSheet, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMsgs(id: conversationId, shouldScrollToBottom: true)
        }
    }
    
    private func listenForMsgs(id: String, shouldScrollToBottom: Bool) {
        DatabaseService.shared.fetchAllMsgsForSpecificChat(with: id) { [weak self] (result) in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.msgs = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToBottom()
                    }
                }
                
            case .failure(let error):
                print("error \(error)")
            }
        }
    }
    
}

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let photoMsgId = creationOfParticularMsgId(),
              let conversationId = conversationId,
              let name = self.title,
              let selfSender = self.senderSelf else {
            return
        }
        
        if let image = info[.editedImage] as? UIImage,
           let imageData = image.pngData() {
            let photoFileName = "photo_message_" + photoMsgId.replacingOccurrences(of: " ", with: "-") + ".png"
            
            //Upload zdjęcie
            //Wyslij wiadomosc
            StorageService.instance.uploadMsgPhoto(data: imageData, fileName: photoFileName) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let urlString):
                    print("Uploaded zdjęcie wiadomości")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else { return }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    let msg = Message(sender: selfSender,
                                      messageId: photoMsgId,
                                      sentDate: Date(),
                                      kind: .photo(media))
                    DatabaseService.shared.sendNewMsg(to: conversationId, otherUserEmail: self.emailOfPersonToChatWith, name: name, message: msg) { (success) in
                        if success {
                            print("wyslano wiadomosc ze zdjeciem")
                        } else {
                            print("error nie wyslano wiadomosci ze zdj")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
        } else if let videoUrl = info[.mediaURL] as? URL {
            let photoFileName = "photo_message_" + photoMsgId.replacingOccurrences(of: " ", with: "-") + ".mov"
            
            //przeslij wideo
            StorageService.instance.uploadMsgWideo(with: videoUrl, fileName: photoFileName) { [weak self] (result) in
                guard let self = self else { return }
                switch result {
                case .success(let urlString):
                    print("Uploaded wideo w  wiadomości")
                    
                    guard let url = URL(string: urlString),
                          let placeholder = UIImage(systemName: "plus") else { return }
                    
                    let media = Media(url: url,
                                      image: nil,
                                      placeholderImage: placeholder,
                                      size: .zero)
                    let msg = Message(sender: selfSender,
                                      messageId: photoMsgId,
                                      sentDate: Date(),
                                      kind: .video(media))
                    DatabaseService.shared.sendNewMsg(to: conversationId, otherUserEmail: self.emailOfPersonToChatWith, name: name, message: msg) { (success) in
                        if success {
                            print("wyslano wiadomosc ze zdjeciem")
                        } else {
                            print("error nie wyslano wiadomosci ze zdj")
                        }
                    }
                case .failure(let error):
                    print(error)
                }
            }
            
        }
        
        
    }
    
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.senderSelf,
              let msgId = creationOfParticularMsgId() else {
            print("??CHW??")
            return
        }
        
        print("wiadomosc: \(text)")
        
        let msg = Message(sender: selfSender,
                          messageId: msgId,
                          sentDate: Date(),
                          kind: .text(text))
        
        if isEmptyConversation {
            //create nowy rekord w bazie
            
            DatabaseService.shared.createNewChat(with: emailOfPersonToChatWith, name: self.title ?? "User",  msg: msg) { [weak self] (success) in
                if success {
                    print("message sent")
                    self?.isEmptyConversation = false
                    let newConversationId = "conversation_\(msg.messageId)"
                    self?.conversationId = newConversationId
                    self?.listenForMsgs(id: newConversationId, shouldScrollToBottom: true)
                    self?.messageInputBar.inputTextView.text = nil
                }
                else {
                    print("nie wysłano")
                }
            }
        }
        else {
            //dodaj rekord w bazie
            guard let conversationId = conversationId, let name = self.title else {
                return
            }
            
            DatabaseService.shared.sendNewMsg(to: conversationId, otherUserEmail: emailOfPersonToChatWith, name: name, message: msg, completion: { success in
                if success {
                    print("msg send")
                } else {
                    print("failed to send msg")
                }
            })
            print("AHAH")
        }
    }
    
    private func creationOfParticularMsgId() -> String? {
        
        //        let usrrr = UserDefaults.standard.value(forKey: "email")
        //        print(usrrr)
        
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
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return msgs[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return msgs.count
    }
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else { return }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
        }
    }
    
}

extension ChatViewController: MessageCellDelegate {
    func didTapImage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = msgs[indexPath.section]
        
        switch message.kind {
        case .photo(let media):
            guard let imageURL = media.url else { return }
            let vc = PhotoViewerViewController(with: imageURL)
            self.navigationController?.pushViewController(vc, animated: true)
        case .video(let media):
            guard let videoURL = media.url else { return }
            let vc = AVPlayerViewController()
            vc.player = AVPlayer(url: videoURL)
            present(vc, animated: true)
        default:
            break
        }
    }
}
