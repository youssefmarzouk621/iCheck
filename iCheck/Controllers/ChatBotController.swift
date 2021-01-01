//
//  ChatBotController.swift
//  iCheck
//
//  Created by Youssef Marzouk on 12/12/2020.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import CoreData

struct Sender:SenderType {
    var senderId: String
    var displayName: String
}

struct Message:MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}



class ChatBotController: MessagesViewController,MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate {
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    


    let connected = Sender(senderId: "connected", displayName: "Youssef Marzouk")
    let iCheckBot = Sender(senderId: "iCheckBot", displayName: "iCheckBot")
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    
    var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var messages:[MessageType] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getConnectedUser()
        setupMessages()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.keyboardDismissMode = .interactive
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
    }
    
    

    func getConnectedUser() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Connected")
        do {
            let result = try managedContext.fetch(fetchRequest)
            for obj in result {
                self.connectedUser._id=(obj.value(forKey: "id") as! String)
                self.connectedUser.firstName=(obj.value(forKey: "firstName") as! String)
                self.connectedUser.lastName=(obj.value(forKey: "lastName") as! String)
                self.connectedUser.email=(obj.value(forKey: "email") as! String)
                self.connectedUser.password=(obj.value(forKey: "password") as! String)
                self.connectedUser.phone=(obj.value(forKey: "phone") as! String)
                self.connectedUser.sexe=(obj.value(forKey: "sexe") as! String)
                self.connectedUser.avatar=(obj.value(forKey: "avatar") as! String)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func setupMessages() {
        messages.append(Message(sender: iCheckBot, messageId: "1", sentDate: Date().addingTimeInterval(-86400), kind: .text("Bonjour")))
        messages.append(Message(sender: connected, messageId: "2", sentDate: Date().addingTimeInterval(-76400), kind: .text("wakteh validation ?")))
    }
    
    func currentSender() -> SenderType {
        return connected
    }
    

    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == "iCheckBot" {
            let avatarUrl = baseURL + "uploads/users/" + self.connectedUser.avatar
            avatarView.sd_setImage(with: URL(string: avatarUrl), placeholderImage: UIImage(systemName: "person"), options: [.continueInBackground, .progressiveLoad])
        }
    }
    
    func insertMessage(_ message: Message) {
            messages.append(message)
            messagesCollectionView.performBatchUpdates({
                messagesCollectionView.insertSections([messages.count - 1])
                if messages.count >= 2 {
                    messagesCollectionView.reloadSections([messages.count - 2])
                }
            }, completion: { [weak self] _ in
                if self?.isLastSectionVisible() == true {
                    self?.messagesCollectionView.scrollToLastItem(animated: true)
                }
            })
        }
    func isLastSectionVisible() -> Bool {
            
            guard !messages.isEmpty else { return false }
            
            let lastIndexPath = IndexPath(item: 0, section: messages.count - 1)
            
            return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
        }

}



extension ChatBotController: InputBarAccessoryViewDelegate {

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    func processInputBar(_ inputBar: InputBarAccessoryView) {
        // Here we can parse for which substrings were autocompleted
        let attributedText = inputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in

            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            
        }

        let components = inputBar.inputTextView.components
        inputBar.inputTextView.text = String()
        inputBar.invalidatePlugins()
        // Send button activity animation
        inputBar.sendButton.startAnimating()
        inputBar.inputTextView.placeholder = "Sending..."
        //inputBar.inputTextView.resignFirstResponder()
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                inputBar.sendButton.stopAnimating()
                inputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToLastItem(animated: true)
            }
        }
    }

    func insertMessages(_ data: [Any]) {
        for component in data {
            let user = currentSender()
            if let str = component as? String {
                let message = Message(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(str))
                insertMessage(message)
            }
        }
    }
}
