//
//  DatabaseService.swift
//  qckMSG
//
//  Created by Mateusz on 16/04/2021.
//

import Foundation
import FirebaseDatabase

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
            guard snapshot.value as? String  != nil else {
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


// MARK: - wysyłanie wiadomości oraz konwersacje

extension DatabaseService {
    
    /// Tworzy owy czat z wybraną osobą z wysłaniem wiadomości
    public func createNewChat(with emailOfUserToChatWith: String, msg: Message, completion: @escaping (Bool) -> ()) {
        guard let currentUserEmail = UserDefaults.standard.value(forKey: "email") as? String else { return }
        let currentUserSafeEmail = DatabaseService.safeID(email: currentUserEmail)
        
        let reference = database.child("\(currentUserSafeEmail)")
        reference.observeSingleEvent(of: .value) { snapshot in
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
                "latest_message": [
                    "date": dateToString,
                    "message": msgToBeSent,
                    "is_read": false
                ]
            ]
            
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
                    self?.finishCreationOfChat(chatIdentifier: chatId,
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
                    self?.finishCreationOfChat(chatIdentifier: chatId,
                                              firstMsg: msg,
                                              completion: completion)
                }
            }
        }
    }
    
    private func finishCreationOfChat(chatIdentifier: String, firstMsg: Message, completion: @escaping (Bool) -> ()) {
        
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
            "is_read": false
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
    public func fetchAllConversations(for email: String, completion: @escaping (Result<String, Error>) -> ()) {
        
    }
    
    /// Pobiera wszystkie wiadomości dla wybranego czatu
    public func fetchAllMsgsForSpecificChat(with id: String, completion: @escaping (Result<String, Error>) -> ()) {
        
    }
    
    /// Wysyła wiadomość w wybranym czacie
    public func sendNewMsg(to chat: String, message: Message) {
        
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
