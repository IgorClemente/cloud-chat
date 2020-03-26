//
//  ChatManager.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation

class ChatManager {
    
    var conversations: [Chat:[Message]?]?
    var friendList: [User]?
    var potentialFriendList: [User]?
    
    static let sharedInstance: ChatManager = ChatManager()
    
    private init() {
        friendList = [User]()
        potentialFriendList = [User]()
        conversations = [Chat:[Message]?]()
    }
    
    func refreshAllMessages(chat: Chat, completion: @escaping (Error?)->Void) {
        let earliestDate = Date(timeIntervalSince1970: 0)
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.retrieveAllMessages(chatID: chat.id!, fromDate: earliestDate) { (error) in
            if let error = error {
                completion(error)
            } else {
                completion(nil)
            }
        }
    }
    
    func addFriend(user: User) {
        friendList?.append(user)
    }
    
    func addChat(chat: Chat) {
        if let _ = findChat(chatID: chat.id!) {
            return
        }
        conversations?[chat] = [Message]()
    }
    
    func addMessage(chatID: String, message: Message) {
        guard let chat = findChat(chatID: chatID) else { return }
        
        for existingMessage in conversations![chat]!! {
            if existingMessage.message_id!.compare(message.message_id!) == .orderedSame {
                return
            }
        }
        conversations![chat]!!.append(message)
    }
    
    func findChat(fromUserID: String, toUserID: String) -> Chat? {
        guard let conversations = conversations else { return nil }
        
        for key in conversations.keys {
            if (key.from_user_id?.compare(fromUserID) == .orderedSame &&
                key.to_user_id?.compare(toUserID) == .orderedSame) || (key.to_user_id?.compare(fromUserID) == .orderedSame && key.from_user_id?.compare(toUserID) == .orderedSame) {
                return key
            }
        }
        return nil
    }
    
    func findChat(chatID: String) -> Chat? {
        guard let conversations = conversations else { return nil }
        
        for key in conversations.keys {
            if key.id?.compare(chatID) == .orderedSame {
                return key
            }
        }
        return nil
    }
    
    func loadChat(fromUserID: String, toUserID: String, completion: @escaping (Error?,Chat?)->Void) {
        if let chat = findChat(fromUserID: fromUserID, toUserID: toUserID) {
            completion(nil,chat)
            return
        }
    
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.retrieveChat(fromUserID: fromUserID, toUserID: toUserID) { (error) in
            if let error = error as NSError? {
                if error.code != 210 {
                    completion(error,nil)
                    return
                }
                
                dynamoDBController.createChat(fromUserID: fromUserID, toUserID: toUserID, completion: { (error) in
                    if let error = error {
                        completion(error,nil)
                        return
                    }
                    
                    if let chat = self.findChat(fromUserID: fromUserID, toUserID: toUserID) {
                        completion(nil,chat)
                        return
                    }
                    
                    let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 400,
                                        userInfo: ["__type":"Unknown Error","message":"DynamoDB error."])
                    completion(error,nil)
                    return
                })
                return
            }
            
            if let chat = self.findChat(fromUserID: fromUserID, toUserID: toUserID) {
                completion(nil,chat)
                return
            }
            
            let error = NSError(domain: "com.igorclemente", code: 400, userInfo: ["__type":"Unknown Error",
                                                                                  "message":"DynamoDB error."])
            completion(error,nil)
            return
        }
    }
    
    func sendTextMessage(chat: Chat, messageText: String, completion: @escaping (Error?)->Void) {
        let timeSent = Date()
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let senderID = cognitoIdentityPoolController.currentIdentityID else {
            let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 402,
                                userInfo: ["__type":"Unauthenticated","message":"Sender is no longer authenticated."])
            completion(error)
            return
        }
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.sendMessageText(fromUserID: senderID, chatID: chat.id!, messageText: messageText) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            dynamoDBController.retrieveAllMessages(chatID: chat.id!, fromDate: timeSent, completion: { (error) in
                if let error = error {
                    completion(error)
                } else {
                    completion(nil)
                }
            })
        }
    }
    
    func sendImage(chat: Chat, message: UIImage, completion: @escaping (Error?)->Void) {
        let timeSent = Date()
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let senderID = cognitoIdentityPoolController.currentIdentityID else {
            let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 402,
                                userInfo: ["__type":"Unauthenticated","message":"Sender is no longer authenticated."])
            completion(error)
            return
        }
        
        let imageData = message.pngData()
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let fileName = NSUUID().uuidString
        let previewFileName = "thumbnail-\(fileName)"
        let localFilePath = documentsDirectory.appending("\(fileName).png")
        
        do {
            try imageData?.write(to: URL(fileURLWithPath: localFilePath), options: .atomicWrite)
        } catch {
            let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 406,
                                userInfo: ["__type":"Error","message":"Could not save image to documents directory."])
            completion(error)
        }
        
        let s3Controller = S3Controller.sharedInstance
        s3Controller.uploadImage(localFilePath: localFilePath, remoteFileName: fileName) { (error) in
            if let error = error {
                completion(error)
                return
            }
            
            let dynamoDBController = DynamoDBController.sharedInstance
            dynamoDBController.sendImage(fromUserID: senderID, chatID: chat.id!, imageFile: fileName, previewFile: previewFileName, completion: { (error) in
                if let error = error {
                    completion(error)
                    return
                }
                
                dynamoDBController.retrieveAllMessages(chatID: chat.id!, fromDate: timeSent, completion: { (error) in
                    if let error = error {
                        completion(error)
                    } else {
                        completion(nil)
                    }
                })
            })
        }
    }
    
    func clearPotentialFriendList() {
        potentialFriendList?.removeAll()
    }
    
    func clearFriendList() {
        friendList?.removeAll()
    }
    
    func addPotentialFriend(user: User) {
        potentialFriendList?.append(user)
    }
    
    func clearCurrentChatList() {
        conversations?.removeAll()
    }
}

