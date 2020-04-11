//
//  Friend.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSDynamoDB

class Friend : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var id: String?
    @objc var user_id: String?
    @objc var friend_id: String?
    
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
        super.init()
        id = dictionaryValue["id"] as? String
        user_id = dictionaryValue["user_id"] as? String
        friend_id = dictionaryValue["friend_id"] as? String
    }
    
    static func dynamoDBTableName() -> String {
        return "Friend"
    }
    
    static func hashKeyAttribute() -> String {
        return "id"
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
}
