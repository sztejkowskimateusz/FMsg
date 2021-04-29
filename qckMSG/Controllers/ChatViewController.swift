//
//  ChatViewController.swift
//  qckMSG
//
//  Created by Mateusz on 29/04/2021.
//

import UIKit
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var profilePictureURL: String
}

class ChatViewController: MessagesViewController {
    
    private var msgs: [Message] = []
    
    private let senderSelf = Sender(senderId: "",
                                    displayName: "1",
                                    profilePictureURL: "Mateusz Sztejkowski")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        msgs.append(Message(sender: senderSelf,
                        messageId: "1",
                        sentDate: Date(),
                        kind: .text("Co jest gościu?")))
        
        msgs.append(Message(sender: senderSelf,
                        messageId: "1",
                        sentDate: Date(),
                        kind: .text("Co jest gościu? BO U MNIE GITUWA")))
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self

    }

}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        return senderSelf
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return msgs[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return msgs.count
    }
    
    
}
