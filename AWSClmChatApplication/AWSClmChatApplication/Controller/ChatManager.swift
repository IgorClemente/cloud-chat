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
    
    func clearFriendList() {
        friendList?.removeAll()
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
    
    func clearPotentialFriendList() {
        potentialFriendList?.removeAll()
    }
    
    func addPotentialFriend(user: User) {
        potentialFriendList?.append(user)
    }
    
    func clearCurrentChatList() {
        conversations?.removeAll()
    }
}

