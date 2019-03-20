//
//  CognitoUserPoolViewController.swift
//  AWSChatApplication
//
//  Created by Igor Clemente on 2/12/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class CognitoUserPoolController {

    let userPoolRegion: AWSRegionType = .USEast1
    let userPoolID: String = "us-east-1_rUj7hUmQe"
    let appClientID: String = "1kda2nqoi54ee0cc27n9ndrt0m"
    let appClientSecret: String = "1prsk0un2unrsc09j5bhbmnfpaf5597vppe4l88drgprr53t611e"
    
    let userPoolRegionString = "us-east-1"
    
    private var userPool: AWSCognitoIdentityUserPool?
    
    var currentUser: AWSCognitoIdentityUser? {
        get {
            return userPool?.currentUser()
        }
    }
    
    static let sharedInstance: CognitoUserPoolController = CognitoUserPoolController()
    
    private init() {
        let serviceConfiguration = AWSServiceConfiguration(region: userPoolRegion, credentialsProvider: nil)
        
        let poolConfiguration = AWSCognitoIdentityUserPoolConfiguration(clientId: appClientID,
                                                                        clientSecret: appClientSecret,
                                                                        poolId: userPoolID)
        
        AWSCognitoIdentityUserPool.register(with: serviceConfiguration, userPoolConfiguration: poolConfiguration, forKey: "AWSChat")
        
        userPool = AWSCognitoIdentityUserPool(forKey: "AWSChat")
        AWSLogger.default()?.logLevel = .verbose
    }
    
    func login(username: String, password: String, completion: @escaping (Error?)->Void) {
        let user = self.userPool?.getUser(username)
        let task = user?.getSession(username, password: password, validationData: nil)
        
        task?.continueWith(block: { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        })
    }
    
    func signup(username: String, password: String, emailAddress: String, completion: @escaping (Error?, AWSCognitoIdentityUser?)->Void) {
        
        var attributes = [AWSCognitoIdentityUserAttributeType]()
        let emailAttribute = AWSCognitoIdentityUserAttributeType(name: "email", value: emailAddress)
        
        attributes.append(emailAttribute)
        
        let task = self.userPool?.signUp(username,password: password, userAttributes: attributes, validationData: nil)
        task?.continueWith(block: { (task) -> Any? in
            if let error = task.error {
                completion(error,nil)
                return nil
            }
            
            guard let result = task.result else {
                let error: NSError = NSError(domain: "com.clemente.AWSChatApplication",
                                             code: 100, userInfo: ["__type":"Unknown Error","message":"Cognito user pool error."])
                completion(error,nil)
                return nil
            }
            completion(nil,result.user)
            return nil
        })
    }
    
    func confirmSignup(user: AWSCognitoIdentityUser, confirmationCode: String, completion: @escaping (Error?)->Void) {
        let task = user.confirmSignUp(confirmationCode)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    
    func resendConfirmationCode(user: AWSCognitoIdentityUser, completion: @escaping (Error?)->Void) {
        let task = user.resendConfirmationCode()
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    
    func getUserDetails(user: AWSCognitoIdentityUser, completion: @escaping (Error?,AWSCognitoIdentityUserGetDetailsResponse?)->Void) {
        let task = user.getDetails()
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error,nil)
                return nil
            }
            
            guard let result = task.result else {
                let error: NSError = NSError(domain: "com.clemente.AWSChatApplication",
                                             code: 100, userInfo: ["__type":"Unknown Error","message":"Cognito user pool error."])
                completion(error,nil)
                return nil
            }
            completion(nil,result)
            return nil
        }
    }
}
