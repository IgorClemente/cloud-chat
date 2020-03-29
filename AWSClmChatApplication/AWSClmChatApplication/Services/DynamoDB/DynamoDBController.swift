//
//  DynamoDBController.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSDynamoDB

class DynamoDBController {
    
    static let sharedInstance: DynamoDBController = DynamoDBController()
    
    private init() { }
    
    func refreshFriendList(userId: String, completion: @escaping (Error?)->Void) {
        retrieveFriendIds(userId: userId) { (error, friendUserIDArray) in
            if let error = error as NSError? {
                completion(error)
                return
            }
            
            let chatManager = ChatManager.sharedInstance
            chatManager.clearFriendList()
            
            if friendUserIDArray == nil {
                completion(nil)
                return
            }
            
            let scanExpression = AWSDynamoDBScanExpression()
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let task = dynamoDBObjectMapper.scan(User.self, expression: scanExpression)
            
            task.continueWith(block: { (task) -> Any? in
                if let error = task.error as NSError? {
                    completion(error)
                    return nil
                }
                
                guard let paginatedOutput = task.result else {
                    let error = NSError(domain: "com.clemente.AWSClmChatApplication", code: 200,
                                        userInfo: ["__type":"Unknown Error","message":"DynamoDB error."])
                    completion(error)
                    return nil
                }
                
                if paginatedOutput.items.isEmpty {
                    completion(nil)
                    return nil
                }
                
                for index in 0...(paginatedOutput.items.count - 1) {
                    guard let user = paginatedOutput.items[index] as? User,
                          let userId = user.id else {
                        continue
                    }
                    
                    if friendUserIDArray!.contains(userId) {
                        chatManager.addFriend(user: user)
                    }
                }
                completion(nil)
                return nil
            })
        }
    }
    
    private func retrieveFriendIds(userId: String, completion: @escaping (Error?, [String]?)->Void) {
        let scanExpression = AWSDynamoDBScanExpression()
        scanExpression.filterExpression = "user_id = :val"
        scanExpression.expressionAttributeValues = [":val" : userId]
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.scan(Friend.self, expression: scanExpression)
        
        var friendUserIDArray = [String]()
        
        task.continueWith { (task) -> Any? in
            if let error = task.error as NSError? {
                completion(error,nil)
                return nil
            }
            
            guard let paginatedOutput = task.result else {
                completion(nil,nil)
                return nil
            }
            
            if paginatedOutput.items.isEmpty {
                completion(nil,nil)
                return nil
            }
            
            for index in 0...(paginatedOutput.items.count - 1) {
                guard let friend = paginatedOutput.items[index] as? Friend,
                      let friend_user_id = friend.friend_id else {
                    continue
                }
                friendUserIDArray.append(friend_user_id)
            }
            completion(nil,friendUserIDArray)
            return nil
        }
    }

    func retrieveUser(userId: String, completion: @escaping (Error?, User?)->Void) {
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.load(User.self, hashKey: userId, rangeKey: nil)
        
        task.continueWith { (task) -> Any? in
            if let error = task.error as NSError? {
                completion(error,nil)
                return nil
            }
            
            if let result = task.result as? User {
                completion(nil,result)
            } else {
                let error = NSError(domain: "com.clemente.AWSClmChatApplication", code: 200,
                                    userInfo: ["__type":"Unknown Error","message":"DynamoDB error."])
                completion(error,nil)
            }
            return nil
        }
    }
    
    func retrieveChat(fromUserID: String, toUserID: String, completion: @escaping (Error?)->Void) {
        let chatID = "\(fromUserID)\(toUserID)"
        let alternateChatID = "\(toUserID)\(fromUserID)"
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.load(Chat.self, hashKey: chatID, rangeKey: nil)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            if let result = task.result as? Chat {
                let chatManager = ChatManager.sharedInstance
                chatManager.addChat(chat: result)
                completion(nil)
            } else {
                let task2 = dynamoDBObjectMapper.load(Chat.self, hashKey: alternateChatID, rangeKey: nil)
                task2.continueWith(block: { (task) -> Any? in
                    if let error = task.error {
                        completion(error)
                        return nil
                    }
                    
                    if let result = task.result as? Chat {
                        let chatManager = ChatManager.sharedInstance
                        chatManager.addChat(chat: result)
                        completion(nil)
                    } else {
                        let error: NSError = NSError(domain: "com.clemente.AWSClmChatApplication", code: 210, userInfo: nil)
                        completion(error)
                    }
                    return nil
                })
            }
            return nil
        }
    }
    
    func refreshPotentialFriendList(currentUserId: String, completion: @escaping (Error?)->Void) {
        retrieveFriendIds(userId: currentUserId) { (error, friendUserIDArray) in
            if let error = error as NSError? {
                completion(error)
                return
            }
            
            let scanExpression = AWSDynamoDBScanExpression()
            
            let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
            let task = dynamoDBObjectMapper.scan(User.self, expression: scanExpression)
            
            task.continueWith(block: { (task) -> Any? in
                if let error = task.error as NSError? {
                    completion(error)
                    return nil
                }
                
                guard let paginatedOutput = task.result else {
                    let error = NSError(domain: "com.clemente.AWSClmChatApplication", code: 200,
                                        userInfo: ["__type":"Unknown Error", "message":"DynamoDB error."])
                    completion(error)
                    return nil
                }
                
                let chatManager = ChatManager.sharedInstance
                chatManager.clearPotentialFriendList()
                
                if paginatedOutput.items.isEmpty {
                    completion(nil)
                    return nil
                }
                
                for index in 0...(paginatedOutput.items.count - 1) {
                    guard let user = paginatedOutput.items[index] as? User, let userId = user.id else {
                        continue
                    }
                    
                    if (friendUserIDArray != nil) && friendUserIDArray!.contains(userId) {
                        continue
                    }
                    
                    if (currentUserId.compare(userId) == .orderedSame) {
                        continue
                    }
                    chatManager.addPotentialFriend(user: user)
                }
                completion(nil)
                return nil
            })
        }
    }
    
    func retrieveAllMessages(chatID: String, fromDate: Date, completion: @escaping (Error?)->Void) {
        let fromDateAsNumber = fromDate.timeIntervalSince1970
        
        let queryExpression = AWSDynamoDBQueryExpression()
        queryExpression.keyConditionExpression = "chat_id = :chatIdentifier AND date_sent > :earliestDate"
        queryExpression.expressionAttributeValues = [":chatIdentifier" : chatID, ":earliestDate" : fromDateAsNumber]
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.query(Message.self, expression: queryExpression)
        
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            guard let paginatedOutput = task.result else {
                completion(nil)
                return nil
            }
            
            if paginatedOutput.items.isEmpty {
                completion(nil)
                return nil
            }
            
            for index in 0...(paginatedOutput.items.count - 1) {
                if let message = paginatedOutput.items[index] as? Message {
                    let chatManager = ChatManager.sharedInstance
                    chatManager.addMessage(chatID: chatID, message: message)
                }
            }
            completion(nil)
            return nil
        }
    }
    
    func sendMessageText(fromUserID: String, chatID: String, messageText: String, completion: @escaping (Error?)->Void) {
        let message = Message()
        message.chat_id = chatID
        message.message_text = messageText
        message.message_id = NSUUID().uuidString
        message.date_sent = Date().timeIntervalSince1970 as NSNumber
        message.message_image = "NA"
        message.message_image_preview = "NA"
        message.sender_id = fromUserID
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.save(message)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            let chatManager = ChatManager.sharedInstance
            chatManager.addMessage(chatID: chatID, message: message)
            
            completion(nil)
            return nil
        }
    }
    
    func sendImage(fromUserID: String, chatID: String, imageFile: String, previewFile: String, completion: @escaping (Error?)->Void) {
        let message = Message()
        message.chat_id = chatID
        message.message_text = "NA"
        message.message_id = NSUUID().uuidString
        message.date_sent = Date().timeIntervalSince1970 as NSNumber
        message.message_image = imageFile
        message.message_image_preview = previewFile
        message.sender_id = fromUserID
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.save(message)
        
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            let chatManager = ChatManager.sharedInstance
            chatManager.addMessage(chatID: chatID, message: message)
            
            completion(nil)
            return nil
        }
    }
    
    func createChat(fromUserID: String, toUserID: String, completion: @escaping (Error?)->Void) {
        let chat = Chat()
        chat.id = "\(fromUserID)\(toUserID)"
        chat.from_user_id = fromUserID
        chat.to_user_id = toUserID
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.save(chat)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            let chatManager = ChatManager.sharedInstance
            chatManager.addChat(chat: chat)
            completion(nil)
            return nil
        }
    }
    
    func addFriend(currentUserId: String, friendUserId: String, completion: @escaping (Error?)->Void) {
        let friendRelationship = Friend()
        friendRelationship.id = NSUUID().uuidString
        friendRelationship.user_id = currentUserId
        friendRelationship.friend_id = friendUserId
        
        let dynamoDBObjectMapper = AWSDynamoDBObjectMapper.default()
        let task = dynamoDBObjectMapper.save(friendRelationship)
        
        task.continueWith { (task) -> Any? in
            if let error = task.error as NSError? {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
}
