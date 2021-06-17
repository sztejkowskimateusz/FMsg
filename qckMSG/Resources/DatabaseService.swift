//
//  DatabaseService.swift
//  qckMSG
//
//  Created by Mateusz on 16/04/2021.
//

import Foundation
import FirebaseDatabase
import MessageKit

final class DatabaseService {
    
    static let shared = DatabaseService()
    private let database = Database.database().reference()
    
    static func safeID(email: String) -> String {
        var id = email.replacingOccurrences(of: ".", with: "-")
        id = id.replacingOccurrences(of: "@", with: "-")
        return id
    }
}

//MARK: - Zarządzanie kontem w bazie danych
extension DatabaseService {
    
    public func czyUzytkownikIstnieje(with email: String, completion: @escaping ((Bool) -> Void)) {
        
        var idUzytkownika = email.replacingOccurrences(of: ".", with: "-")
        idUzytkownika = idUzytkownika.replacingOccurrences(of: "@", with: "-")
        
        database.child(idUzytkownika).observeSingleEvent(of: .value) { (snapshot) in
//            guard snapshot.value as? String != nil else {
//                completion(false)
//                return
//            }
//            completion(true)
            guard snapshot.exists() else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Tworzy obiekt nowego uzytkownika w bazie danych
    public func utworzUzytkownika(with uzytkownik: ObiektUzytkownika, completion: @escaping (Bool) -> () ) {
        database.child(uzytkownik.idUzytkownika).setValue([
            "imie": uzytkownik.imie,
            "nazwisko": uzytkownik.nazwisko
        ]) { (error, databaseReference) in
            guard error == nil else {
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value) { (snapshot) in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newUser = [
                        "name": uzytkownik.imie + " " + uzytkownik.nazwisko,
                        "email": uzytkownik.idUzytkownika
                    ]
                    usersCollection.append(newUser)
                    
                    self.database.child("users").setValue(usersCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                    
                } else {
                    let newUsersCollection: [[String: String]] = [
                        [
                            "name": uzytkownik.imie + " " + uzytkownik.nazwisko,
                            "email": uzytkownik.idUzytkownika
                        ]
                    ]
                    self.database.child("users").setValue(newUsersCollection) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func fetchAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseServiceError.failedToFetch))
                return
            }
            
            completion(.success(value))
        }
    }
}

public enum DatabaseServiceError: Error {
    case failedToFetch
}

extension DatabaseService {
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void) {
        self.database.child("\(path)").observeSingleEvent(of: .value) { (snapshot) in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseServiceError.failedToFetch))
                return
            }
            completion(.success(value))
        }
    }
}


// MARK: - wysyłanie wiadomości oraz konwersacje

extension DatabaseService {
    
    /// Tworzy owy czat z wybraną osobą z wysłaniem wiadomości
    public func createNewChat(with emailOfUserToChatWith: String, name: String, msg: Message, completion: @escaping (Bool) -> ()) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String,
              let currentName = UserDefaults.standard.value(forKey: "name") as? String else { return }
        let currentUserSafeEmail = DatabaseService.safeID(email: currentUserEmail)
        
        let reference = database.child("\(currentUserSafeEmail)")
        reference.observeSingleEvent(of: .value) { [weak self] snapshot in
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("err no user")
                return
            }
            
            var msgToBeSent = ""
            
            switch msg.kind {
            case .text(let msgContent):
                msgToBeSent = msgContent
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let msgDate = msg.sentDate
            let dateToString = ChatViewController.dateFormat.string(from: msgDate)
            
            let chatId = "conversation_\(msg.messageId)"
            
            let newChatData: [String: Any] = [
                "id": chatId,
                "other_user_email": emailOfUserToChatWith,
                "name": name,
                "latest_message": [
                    "date": dateToString,
                    "message": msgToBeSent,
                    "is_read": false
                ]
            ]
            
            let odbiorcaNewChatData: [String: Any] = [
                "id": chatId,
                "other_user_email": currentUserSafeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateToString,
                    "message": msgToBeSent,
                    "is_read": false
                ]
            ]
            
            //Aktualizacja czatu dla odbiorcy
            self?.database.child("\(emailOfUserToChatWith)/conversations").observeSingleEvent(of: .value) { [weak self] (snapshot) in
                if var conversations = snapshot.value as? [[String: Any]] {
                    conversations.append(odbiorcaNewChatData)
                    self?.database.child("\(emailOfUserToChatWith)/conversations").setValue(chatId)
                } else {
                    //utworz czat
                    self?.database.child("\(emailOfUserToChatWith)/conversations").setValue([odbiorcaNewChatData])
                }
            }

            //Aktualizacja czatu dla aktualnego uzytkownika/nadawcy
            if var chats = userNode["conversations"] as? [[String: Any]] {
                // obiekt czat juz istnieje dla zadanego uzytkownika
                
                chats.append(newChatData)
                userNode["conversations"] = chats
                
                reference.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        print("ta")
                        return
                    }
                    print("no")
                    self?.finishCreationOfChat(name: name,
                                               chatIdentifier: chatId,
                                               firstMsg: msg,
                                               completion: completion)
                }
            }
            else {
                // obiekt czatu nie istnieje utworz
                userNode["conversations"] = [
                    newChatData
                ]
                
                reference.setValue(userNode) { [weak self] (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreationOfChat(name: name,
                                               chatIdentifier: chatId,
                                               firstMsg: msg,
                                               completion: completion)
                }
            }
        }
    }
    
    private func finishCreationOfChat(name: String, chatIdentifier: String, firstMsg: Message, completion: @escaping (Bool) -> ()) {
        
        var msgToBeSent = ""
        
        switch firstMsg.kind {
        case .text(let msgContent):
            msgToBeSent = msgContent
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let msgDate = firstMsg.sentDate
        let dateToString = ChatViewController.dateFormat.string(from: msgDate)
        
        guard let currUsrEmail = UserDefaults.standard.value(forKey: "email") as? String else {
            print("brrrr")
            completion(false)
            return
        }
        
        let currUsrSafeEmail = DatabaseService.safeID(email: currUsrEmail)
        
        let messagesCollection: [String: Any] = [
            "id": firstMsg.messageId,
            "type": firstMsg.kind.msgKindString,
            "content": msgToBeSent,
            "date": dateToString,
            "sender_email": currUsrSafeEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "messages": [
                messagesCollection
            ]
        ]
        
        database.child("\(chatIdentifier)").setValue(value) { (error, _) in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        }
    }
    
    /// Pobiera wszysztkie konwersacje dla wybranego użytkownika
    public func fetchAllConversations(for email: String, completion: @escaping (Result<[Chat], Error>) -> ()) {
        database.child("\(email)/conversations").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseServiceError.failedToFetch))
                return
            }
            
            let chats: [Chat] = value.compactMap({dictionary in
                guard let chatID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMsgObject = LatestMsg(date: date, text: message, isRead: isRead)
                
                return Chat(id: chatID, name: name, otherUserEmail: otherUserEmail, latestMessage: latestMsgObject)
            })
            
            completion(.success(chats))
        }
    }
    
    /// Pobiera wszystkie wiadomości dla wybranego czatu
    public func fetchAllMsgsForSpecificChat(with id: String, completion: @escaping (Result<[Message], Error>) -> ()) {
        database.child("\(id)/messages").observe(.value) { (snapshot) in
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseServiceError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let type = dictionary["type"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let date = ChatViewController.dateFormat.date(from: dateString) else {
                    return nil
                }
                
                var kind: MessageKind?
                
                if type == "photo" {
                    //zdjecie
                    guard let imageURL = URL(string: content),
                         let placeHolder = UIImage(systemName: "plus") else { return nil }
                    let media = Media(url: imageURL,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .photo(media)
                }
                else if type == "video" {
                    //wideo
                    guard let wideoURL = URL(string: content),
                         let placeHolder = UIImage(named: "video-placeholder") else { return nil }
                    let media = Media(url: wideoURL,
                                      image: nil,
                                      placeholderImage: placeHolder,
                                      size: CGSize(width: 300, height: 300))
                    kind = .video(media)
                }
                else {
                    //text
                    kind = .text(content)
                }
                
                guard let finalKind = kind else { return nil}
                
                let sender = Sender(senderId: senderEmail, displayName: name, profilePictureURL: "")
                return Message(sender: sender, messageId: messageID, sentDate: date, kind: finalKind)
            })
            
            completion(.success(messages))
        }
    }
    
    /// Wysyła wiadomość w wybranym czacie
    public func sendNewMsg(to chat: String, otherUserEmail: String, name: String, message: Message, completion: @escaping (Bool)-> ()) {
        
        database.child("\(chat)/messages").observeSingleEvent(of: .value) { [weak self] (snapshot) in
            guard let strongSelf = self else {
                return
            }
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            var msgToBeSent = ""
            
            switch message.kind {
            case .text(let msgContent):
                msgToBeSent = msgContent
            case .attributedText(_):
                break
            case .photo(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    msgToBeSent = targetUrlString
                }
                break
            case .video(let mediaItem):
                if let targetUrlString = mediaItem.url?.absoluteString {
                    msgToBeSent = targetUrlString
                }
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let msgDate = message.sentDate
            let dateToString = ChatViewController.dateFormat.string(from: msgDate)
            
            guard let currUsrEmail = UserDefaults.standard.value(forKey: "email") as? String else {
                print("brrrr")
                completion(false)
                return
            }
            
            let currUsrSafeEmail = DatabaseService.safeID(email: currUsrEmail)
            
            let newMsgEntry: [String: Any] = [
                "id": message.messageId,
                "type": message.kind.msgKindString,
                "content": msgToBeSent,
                "date": dateToString,
                "sender_email": currUsrSafeEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMsgEntry)
            strongSelf.database.child("\(chat)/messages").setValue(currentMessages) { (error, _) in
                guard error == nil else {
                    completion(false)
                    return
                }
                
                strongSelf.database.child("\(currUsrSafeEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                    guard var currentUserConversations = snapshot.value as? [[String: Any]] else {
                        completion(false)
                        return
                    }
                    
                    let updatedValue: [String: Any] = [
                        "date": dateToString,
                        "is_read": false,
                        "message": msgToBeSent,
                    ]
                    
                    var targetConversation: [String: Any]?
                    var position = 0
                    
                    for conversationDictionary in currentUserConversations {
                        if let currentId = conversationDictionary["id"] as? String, currentId == chat {
                            targetConversation = conversationDictionary
                            break
                        }
                        position += 1
                    }
                    targetConversation?["latest_message"] = updatedValue
                    guard let finalConverasation = targetConversation else {
                        completion(false)
                        return
                    }
                    currentUserConversations[position] = finalConverasation
                    strongSelf.database.child("\(currUsrSafeEmail)/conversations").setValue(currentUserConversations) { (error, _) in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        //Aktualizacja ostatniej wiadomosci dla odbiorcy
                        
                        strongSelf.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value) { (snapshot) in
                            guard var otherUserConversations = snapshot.value as? [[String: Any]] else {
                                completion(false)
                                return
                            }
                            
                            let updatedValue: [String: Any] = [
                                "date": dateToString,
                                "is_read": false,
                                "message": msgToBeSent,
                            ]
                            
                            var targetConversation: [String: Any]?
                            var position = 0
                            
                            for conversationDictionary in otherUserConversations {
                                if let currentId = conversationDictionary["id"] as? String, currentId == chat {
                                    targetConversation = conversationDictionary
                                    break
                                }
                                position += 1
                            }
                            targetConversation?["latest_message"] = updatedValue
                            guard let finalConverasation = targetConversation else {
                                completion(false)
                                return
                            }
                            otherUserConversations[position] = finalConverasation
                            strongSelf.database.child("\(otherUserEmail)/conversations").setValue(otherUserConversations) { (error, _) in
                                guard error == nil else {
                                    completion(false)
                                    return
                                }
                                completion(true)
                            }
                        }
                        
                        completion(true)
                    }
                }
            }
        }
    }
    
    public func usunChat(conversaitonId: String, completion: @escaping (Bool) -> Void) {
        guard let email = UserDefaults.standard.value(forKey: "email") as? String else {
            return
        }
        let safeEmail = DatabaseService.safeID(email: email)
        
        let reference = database.child("\(safeEmail)/converations")
        reference.observeSingleEvent(of: .value) { (snapshot) in
            if var conversations = snapshot.value as? [[String: Any]] {
                var positionToBeRemoved = 0
                for conv in conversations {
                    if let id = conv["id"] as? String,
                       id == conversaitonId {
                        break
                    }
                    positionToBeRemoved += 1
                }
                conversations.remove(at: positionToBeRemoved)
                reference.setValue(conversations) { (error, _) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    print("usunięto czat")
                    completion(true)
                }
            }
        }
    }
    
}

struct ObiektUzytkownika {
    let imie: String
    let nazwisko: String
    let adresEmail: String
    
    var idUzytkownika: String {
        var id = adresEmail.replacingOccurrences(of: ".", with: "-")
        id = id.replacingOccurrences(of: "@", with: "-")
        return id
    }
    
    var zdjProfiloweFile: String {
        return "\(idUzytkownika)_profile_picture.png"
    }
    
}
