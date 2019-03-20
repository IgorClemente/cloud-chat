//
//  User.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/10/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSDynamoDB

class User : AWSDynamoDBObjectModel, AWSDynamoDBModeling {
    
    @objc var id: String?
    @objc var username: String?
    @objc var email_address: String?
    
    override init() {
        super.init()
    }
    
    override init(dictionary dictionaryValue: [AnyHashable : Any]!, error: ()) throws {
        super.init()
        id = dictionaryValue["id"] as? String
        username = dictionaryValue["username"] as? String
        email_address = dictionaryValue["email_address"] as? String
    }
    
    required init!(coder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    static func dynamoDBTableName() -> String {
        return "User"
    }
    
    static func hashKeyAttribute() -> String {
        return "id"
    }
}


