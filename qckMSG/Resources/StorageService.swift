//
//  StorageService.swift
//  qckMSG
//
//  Created by Mateusz on 30/04/2021.
//

import Foundation
import FirebaseStorage

final class StorageService {
    
    static let instance = StorageService()
    
    private let storage = Storage.storage().reference()
    
    
    public typealias uploadAvatarCompletion = (Result<String, Error>) -> ()
    public func uploadAvatar(data: Data, fileName: String, completion: @escaping uploadAvatarCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { (storageMetaData, error) in
            guard error == nil else {
                completion(.failure(StorageServiceErrors.uploadError))
                return
            }
        }
        self.storage.child("images/\(fileName)").downloadURL { (url, error) in
            guard let url = url else {
                completion(.failure(StorageServiceErrors.downloadUrlError))
                return
            }
            
            let urlString = url.absoluteString
            completion(.success(urlString))
        }
    }
    
    public enum StorageServiceErrors: Error {
        case uploadError
        case downloadUrlError
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let reference = storage.child(path)

        reference.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageServiceErrors.downloadUrlError))
                return
            }

            completion(.success(url))
        })}
}
