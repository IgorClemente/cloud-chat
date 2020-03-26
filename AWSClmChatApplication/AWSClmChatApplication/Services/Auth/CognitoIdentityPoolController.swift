//
//  CognitoIdentityPoolController.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 2/26/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSCognito
import AWSCognitoIdentityProvider

class CognitoIdentityPoolController {
    
    let identityPoolRegion: AWSRegionType = .USEast1
    let identityPoolID: String = "us-east-1:8623fee6-66b0-46e4-9d31-73ba204a7775"
    
    private var credentialsProvider: AWSCognitoCredentialsProvider?
    private var configuration: AWSServiceConfiguration?
    
    public var currentIdentityID: String? 
    
    static let sharedInstance: CognitoIdentityPoolController = CognitoIdentityPoolController()
    
    private init() {
        let identityProvider = SocialIdentityManager.sharedInstance
        
        credentialsProvider = AWSCognitoCredentialsProvider(regionType: identityPoolRegion,
                                                            identityPoolId: identityPoolID, identityProviderManager: identityProvider)
        
        configuration = AWSServiceConfiguration(region: identityPoolRegion, credentialsProvider: credentialsProvider)
        AWSServiceManager.default()?.defaultServiceConfiguration = configuration
    }
    
    func getFederatedIdentityForFacebook(idToken: String, username: String, emailAddress: String?, completion: @escaping (Error?)->Void) {
        
        let identityProviderManager = SocialIdentityManager.sharedInstance
        identityProviderManager.registerFacebookToken(idToken)
        
        let task = self.credentialsProvider!.getIdentityId()
        task.continueWith { (task) -> Any? in
            if task.error != nil {
                completion(task.error)
                return nil
            }
            
            self.currentIdentityID = task.result as String?
            
            let syncClient = AWSCognito.default()
            
            let dataSet = syncClient.openOrCreateDataset("facebookUserData")
            dataSet.setString(username, forKey: "name")
            
            if let emailAddress = emailAddress {
                dataSet.setString(emailAddress, forKey: "email")
            }
            
            dataSet.synchronize()?.continueWith(block: { (task) -> Any? in
                if task.error != nil {
                    completion(task.error)
                    return nil
                }
                completion(nil)
                return nil
            })
            return nil
        }
    }
    
    func getFederatedIdentityForGoogle(idToken: String, username: String, emailAddress: String?, completion: @escaping (Error?)->Void) {
        
        let identityProviderManager = SocialIdentityManager.sharedInstance
        identityProviderManager.registerGoogleToken(idToken)
        
        let task = self.credentialsProvider!.getIdentityId()
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            
            self.currentIdentityID = task.result as String?
            
            let syncClient = AWSCognito.default()
            let dataSet = syncClient.openOrCreateDataset("googleUserData")
            
            dataSet.setString(username, forKey: "name")
            
            if let emailAddress = emailAddress {
                dataSet.setString(emailAddress, forKey: "email")
            }
            
            dataSet.synchronize()?.continueWith(block: { (task) -> Any? in
                if let error = task.error {
                    completion(error)
                    return nil
                }
                completion(nil)
                return nil
            })
            return nil
        }
    }
    
    func getFederatedIdentityForAmazon(idToken: String, username: String, emailAddress: String?,
                                       userPoolID: String, userPoolRegion: String, completion: @escaping (Error?)->Void) {
        
        let identityProviderManager = SocialIdentityManager.sharedInstance
        let key: String = "cognito-idp.\(userPoolRegion).amazonaws.com/\(userPoolID)"
        
        identityProviderManager.registerCognitoToken(key: key, token: idToken)
        
        let task = self.credentialsProvider!.getIdentityId()
        task.continueWith { (task) -> Any? in
            if task.error != nil {
                completion(task.error)
                return nil
            }
            
            self.currentIdentityID = task.result as String?
            
            let syncClient = AWSCognito.default()
            let dataSet = syncClient.openOrCreateDataset("amazonUserData")
            dataSet.setString(username, forKey: "name")
            
            if let emailAddress = emailAddress {
                dataSet.setString(emailAddress, forKey: "email")
            }
            
            dataSet.synchronize().continueWith { (task) -> Any? in
                if task.error != nil {
                    completion(task.error)
                    return nil
                }
                completion(nil)
                return nil
            }
            return nil
        }
    }
}
