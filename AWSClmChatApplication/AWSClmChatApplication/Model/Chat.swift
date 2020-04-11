//
//  Chat.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSDynamoDB

class Chat : AWSDynamoDBObjectModel, AWSDynamoDBModeling {

    @objc var id: String?
    @objc var from_user_id: String?
    @objc var to_user_id: String?

    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
        super.init()
        id = dictionaryValue["id"] as? String
        from_user_id = dictionaryValue["from_user_id"] as? String
        to_user_id = dictionaryValue["to_user_id"] as? String
    }
    
    static func dynamoDBTableName() -> String {
        return "Chat"
    }
    
    static func hashKeyAttribute() -> String {
        return "id"
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
