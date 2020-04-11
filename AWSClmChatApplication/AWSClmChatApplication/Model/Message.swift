//
//  Message.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSDynamoDB

class Message : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var message_id: String?
    @objc var chat_id: String?
    @objc var message_text: String?
    @objc var message_image: String?
    @objc var message_image_preview: String?
    @objc var sender_id: String?
    @objc var date_sent: NSNumber?
    
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
        super.init()
        message_id = dictionaryValue["message_id"] as? String
        chat_id = dictionaryValue["chat_id"] as? String
        message_text = dictionaryValue["message_text"] as? String
        message_image = dictionaryValue["message_image"] as? String
        message_image_preview = dictionaryValue["message_image_preview"] as? String
        sender_id = dictionaryValue["sender_id"] as? String
        date_sent = dictionaryValue["date_sent"] as? NSNumber
    }
    
    static func dynamoDBTableName() -> String {
        return "Message"
    }
    
    static func hashKeyAttribute() -> String {
        return "chat_id"
    }
    
    static func rangeKeyAttribute() -> String {
        return "date_sent"
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
