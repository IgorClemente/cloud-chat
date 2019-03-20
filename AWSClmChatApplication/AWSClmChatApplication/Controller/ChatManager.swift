//
//  ChatManager.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation

class ChatManager {
    
    var chat: Chat?
    var message: Message?
    var friendList: [User]?
    var potentialFriendList: [User]?
    
    static let sharedInstance: ChatManager = ChatManager()
    
    private init() {
        friendList = [User]()
        potentialFriendList = [User]()
    }
    
    func clearFriendList() {
        friendList?.removeAll()
    }
    
    func addFriend(user: User) {
        friendList?.append(user)
    }
    
    func addChat(chat: Chat) {
        self.chat = chat
    }
    
    func addMessage(message: Message) {
        self.message = message
    }
    
    func clearPotentialFriendList() {
        potentialFriendList?.removeAll()
    }
    
    func addPotentialFriend(user: User) {
        potentialFriendList?.append(user)
    }
}

