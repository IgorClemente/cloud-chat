//
//  SocialIdentityManager.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 2/26/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSCognitoIdentityProvider

class SocialIdentityManager: NSObject {
    
    fileprivate var loginDictionary: [String:String]
    static let sharedInstance: SocialIdentityManager = SocialIdentityManager()
    
    private override init() {
        self.loginDictionary = [String:String]()
        super.init()
    }
    
    func registerFacebookToken(_ token: String) {
        self.loginDictionary[AWSIdentityProviderFacebook] = token
    }
    
    func registerGoogleToken(_ token: String) {
        self.loginDictionary[AWSIdentityProviderGoogle] = token
    }
    
    func registerCognitoToken(key: String, token: String) {
        self.loginDictionary[key] = token
    }
}

extension SocialIdentityManager : AWSIdentityProviderManager {
    
    func logins() -> AWSTask<NSDictionary> {
        return AWSTask(result: self.loginDictionary as NSDictionary)
    }
    
}
