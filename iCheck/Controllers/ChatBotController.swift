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
import Starscream

// MARK: - Structs
struct chatResponse :Decodable{
    var _id:String
    var sender:String
    var receiver:String
    var type:String
    var message:String
    var createdAt:String
}

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

struct SocketMessage:Decodable {
    var senderId:String
    var receiverId:String
    var message:String
    var type:String
}



class ChatBotController: MessagesViewController,MessagesDataSource,MessagesLayoutDelegate,MessagesDisplayDelegate,WebSocketDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
            
                return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { suggestedActions in
                    
                    let forward = UIAction(title: "Forward", image: UIImage(systemName: "arrowshape.turn.up.right")) { action in
                        // Show share sheet
                    }

                    let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"),attributes: .destructive) { action in
                        
                    }


                    // Create a UIMenu with all the actions as children
                    return UIMenu(title: "", children: [forward, delete])
                }
            
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    
    

    
    // MARK: - Chat Variables
    var connected = Sender(senderId: "connected", displayName: "")
    var iCheckBot = Sender(senderId: "iCheckBot", displayName: "")
    var backResponse:backendResponse = backendResponse(message: "")
    fileprivate let baseURL = "https://polar-peak-71928.herokuapp.com/"
    var connectedUser:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var friend:Customer = Customer(_id: "", firstName: "", lastName: "", email: "", password: "", phone: "", sexe: "", avatar: "", favorites: [])
    var messages:[MessageType] = []
    var chatList:[chatResponse] = []
    
    
    
    
    
    
    
    // MARK: - Socket Variables
    var socket: WebSocket!
    var isConnected = false
    let server = WebSocketServer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getConnectedUser()
        //setupCachedMessages()
        setupMessages()
        
        title=friend.firstName+" "+friend.lastName
        var request = URLRequest(url: URL(string: "https://tranquil-journey-23890.herokuapp.com")!)
        request.timeoutInterval = 5
        socket = WebSocket(request: request)
        socket.delegate = self
        socket.connect()
        
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        messagesCollectionView.keyboardDismissMode = .interactive
        
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
        layout.textMessageSizeCalculator.outgoingAvatarSize = .zero
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        print("close connection with socket")
        socket.disconnect()
    }
    
    
    
    // MARK: - WebSocketDelegate
    func didReceive(event: WebSocketEvent, client: WebSocket) {
        switch event {
        case .connected(let headers):
            isConnected = true
            print("websocket is connected: \(headers)")
        case .disconnected(let reason, let code):
            isConnected = false
            print("websocket is disconnected: \(reason) with code: \(code)")
        case .text(let string):
            print("----------------")
            let data = Data(string.utf8)
            do {
                let receivedMessage = try JSONDecoder().decode(SocketMessage.self, from: data)
                self.insertReceivedMessages(receivedMessage)
            } catch {
                print("parse socket message error :")
                print(error.localizedDescription)
            }

            
        case .binary(let data):
            print("Received data: \(data.count)")
        case .ping(_):
            break
        case .pong(_):
            break
        case .viabilityChanged(_):
            break
        case .reconnectSuggested(_):
            break
        case .cancelled:
            isConnected = false
        case .error(let error):
            isConnected = false
            handleError(error)
        }
    }
    
    func handleError(_ error: Error?) {
        if let e = error as? WSError {
            print("websocket encountered an error: \(e.message)")
        } else if let e = error {
            print("websocket encountered an error: \(e.localizedDescription)")
        } else {
            print("websocket encountered an error")
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
                self.connected.displayName=(obj.value(forKey: "firstName") as! String)+" "+(obj.value(forKey: "lastName") as! String)
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
    
    
    // MARK: - Get Core Data Messages
    func setupCachedMessages() -> Void {
        /*let parameters = ["senderId" : friend._id,"connectedId" : connectedUser._id]
        
        for message in self.chatList {
            let date = Date.getDateFromString(dateString: message.createdAt)
            if self.connectedUser._id==message.sender {//my message
                self.messages.append(Message(sender: self.connected, messageId: message._id, sentDate: date!, kind: .text(message.message)))
            }else{//sender message
                self.messages.append(Message(sender: self.iCheckBot, messageId: message._id, sentDate: date!, kind: .text(message.message)))
            }
        }
        self.messages.sort {
            $0.sentDate < $1.sentDate
        }
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToLastItem(animated: true)*/
    }
    
    
    
    // MARK: - CollectionView DataSource
    func setupMessages() {

        let parameters = ["senderId" : friend._id,"connectedId" : connectedUser._id]
        guard let url = URL(string: baseURL+"api/chat/getMessages") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
        request.httpBody = httpBody
        URLSession.shared.dataTask(with: request) { (data,response,error) in
            if error == nil{
                do {
                    let decoder = JSONDecoder()
                    self.chatList = try decoder.decode([chatResponse].self, from: data!)
                } catch {
                    print("parse chat response :")
                    print(error.localizedDescription)
                }
        
                DispatchQueue.main.async {
                    
                    for message in self.chatList {
                        let date = Date.getDateFromString(dateString: message.createdAt)
                        if self.connectedUser._id==message.sender {//my message
                            self.messages.append(Message(sender: self.connected, messageId: message._id, sentDate: date!, kind: .text(message.message)))
                            
                        }else{//sender message
                            self.messages.append(Message(sender: self.iCheckBot, messageId: message._id, sentDate: date!, kind: .text(message.message)))
                        }
                    }
                    self.messages.sort {
                        $0.sentDate < $1.sentDate
                    }
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToLastItem(animated: true)
                }
            }
        }.resume()
    }
    
    func currentSender() -> SenderType {
        return connected
    }
    

    
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if message.sender.senderId == "iCheckBot" {
            let avatarUrl = baseURL + "uploads/users/" + self.friend.avatar
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
// MARK: - Extension to Parse Date
extension Date {
  static func getStringFromDate(date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "EEEE, MMM d, yyyy"
    let dateString = dateFormatter.string(from: date)
    return dateString
  }
  static func getDateFromString(dateString: String) -> Date? {
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime,
                               .withDashSeparatorInDate,
                               .withFullDate,
                               .withFractionalSeconds,
                               .withColonSeparatorInTimeZone]
    guard let date = formatter.date(from: dateString) else {
      return nil
    }
    return date
  }
  // get an ISO timestamp
  static func getISOTimestamp() -> String {
    let isoDateFormatter = ISO8601DateFormatter()
    let timestamp = isoDateFormatter.string(from: Date())
    return timestamp
  }
}

extension ChatBotController: InputBarAccessoryViewDelegate
{

    @objc
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        processInputBar(messageInputBar)
    }

    // MARK: - Send Messages With InputBar
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
        DispatchQueue.global(qos: .default).async {
            var msg:String=""
            for component in components {
                msg = component as! String
            }

            // MARK: - Socket.Write
            let params  = ["senderId" : self.connectedUser._id,"receiverId" : self.friend._id, "type" : "text", "message" : msg]
            let jsonData = try? JSONSerialization.data(withJSONObject: params, options: [])
            let jsonString = String(data: jsonData!, encoding: .utf8)
            print(jsonString!)
            self.socket.write(string: jsonString!)

            
            
            
            
            
            let parameters = ["sender" : self.connectedUser._id,"receiver" : self.friend._id,"type": "text","message": msg]
            guard let url = URL(string: self.baseURL+"api/chat/addMessage") else { return }
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            guard let httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: []) else { return }
            request.httpBody = httpBody
            URLSession.shared.dataTask(with: request) { (data,response,error) in
                if error == nil{
                    do {
                        let decoder = JSONDecoder()
                        self.backResponse = try decoder.decode(backendResponse.self, from: data!)
                    } catch {
                        print("parse chat response :")
                        print(error.localizedDescription)
                    }
            
                    DispatchQueue.main.async {
                        if self.backResponse.message=="message Added Successfully"{
                            
                            inputBar.sendButton.stopAnimating()
                            inputBar.inputTextView.placeholder = "Aa"
                            self.insertMessages(components)
                            self.messagesCollectionView.scrollToLastItem(animated: true)
                        }
                        
                    }
                }
            }.resume()
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
    
    
    
    // MARK: - Display Received Messages
    func insertReceivedMessages(_ data: SocketMessage) {
        if data.receiverId==connectedUser._id && data.senderId==friend._id{
            switch data.type {
            case "text":
                let user = iCheckBot
                let message = Message(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(data.message))
                insertMessage(message)
            default:
                let user = iCheckBot
                let message = Message(sender: user, messageId: UUID().uuidString, sentDate: Date(), kind: .text(data.message))
                insertMessage(message)
            }
        }

    }
}
