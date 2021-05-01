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
            completion(true)
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
