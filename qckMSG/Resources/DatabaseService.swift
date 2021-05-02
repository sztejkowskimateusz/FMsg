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
