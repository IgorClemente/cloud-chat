//
//  LoginViewController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 07/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit
import GoogleSignIn
import AWSCognitoIdentityProvider

class LoginViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signupButton: UIButton!
    
    @IBOutlet weak var facebookButton: FBLoginButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loginButton.isEnabled = false
        
        let facebookLoginManager = LoginManager()
        facebookLoginManager.logOut()
        
        facebookButton.readPermissions = ["public_profile","email"]
        
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.uiDelegate = self
        GIDSignIn.sharedInstance()?.shouldFetchBasicProfile = true
        GIDSignIn.sharedInstance()?.signOut()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onLogin(_ sender: Any) {
        guard let username = self.usernameField.text,
              let password = self.passwordField.text else { return }
        
        let userpoolController = CognitoUserPoolController.sharedInstance
        userpoolController.login(username: username, password: password) { (error) in
            if let error = error {
                print("Login Error!", error)
                self.displayLoginError(error: error as NSError)
                return
            }
            print("Login Successful!")
            DispatchQueue.main.async {
                self.getFederatedIdentity(userpoolController.currentUser!)
            }
        }
    }
    
    @IBAction func usernameDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
}

extension LoginViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField,
                   shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let username = self.usernameField.text,
           let password = self.passwordField.text {
            if ((username.count > 0) && (password.count > 0)) {
                self.loginButton.isEnabled = true
            }
        }
        return true
    }
}


extension LoginViewController {
    
    fileprivate func dismissKeyboard() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
    }
    
    fileprivate func displayLoginError(error: NSError) {
        var errorTitle: String = String()
        var errorMessage: String = String()
        
        if let title = error.userInfo["__type"] as? String {
            errorTitle = title
            if let message = error.userInfo["message"] as? String {
                errorMessage = message
            } else {
                errorMessage = error.localizedDescription
            }
        } else {
            errorTitle = "Unknown error."
        }
        
        let alertController = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displaySuccessMessage() {
        let alertController = UIAlertController(title: "Success!", message: "Login successful.", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "ChatJourney", bundle: Bundle.main)
            
            guard let successViewController = storyboard.instantiateInitialViewController() else { return }
            
            DispatchQueue.main.async {
                self.present(successViewController, animated: true, completion: nil)
            }
        }
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension LoginViewController: LoginButtonDelegate {
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton!) {
        print("Facebook Signout.")
    }
    
    func loginButton(_ loginButton: FBLoginButton!, didCompleteWith result: LoginManagerLoginResult!, error: Error!) {
        if error != nil {
            self.displayLoginError(error: error as NSError)
            return
        }
        
        if result.isCancelled {
            return
        }
        
        guard let idToken = AccessToken.current else {
            let error: NSError = NSError(domain: "com.clemente.AWSClmChatApplication", code: 100, userInfo: ["__type":"Unknown Error","message":"Facebook JWT token error."])
            self.displayLoginError(error: error)
            return
        }
        
        let graphRequest = GraphRequest(graphPath: "me", parameters: ["fields":"email,name"])
        graphRequest.start { (connection, result, error) in
            if let error = error {
                self.displayLoginError(error: error as NSError)
                return
            }
            
            if let result = result as? [String:AnyObject],
               let emailAddress = result["email"] as? String,
               let username = result["name"] as? String {
                let identityPoolController = CognitoIdentityPoolController.sharedInstance
                identityPoolController.getFederatedIdentityForFacebook(idToken: idToken.tokenString, username: username, emailAddress: emailAddress, completion: { (error) in
                    if let error = error {
                        print("Facebook SDK Login Error: \(error)")
                        self.displayLoginError(error: error as NSError)
                        return
                    }
                    self.displaySuccessMessage()
                    return
                })
            }
        }
    }
}

extension LoginViewController : GIDSignInDelegate, GIDSignInUIDelegate {
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
            self.displayLoginError(error: error as NSError)
            return
        }
        
        let idToken = user.authentication.idToken
        let username = user.profile.name
        let emailAddress = user.profile.email
        
        let identityPoolController = CognitoIdentityPoolController.sharedInstance
        identityPoolController.getFederatedIdentityForGoogle(idToken: idToken!, username: username!, emailAddress: emailAddress!) { (error) in
            if let error = error {
                self.displayLoginError(error: error as NSError)
                return
            }
            self.displaySuccessMessage()
            return
        }
    }
}

extension LoginViewController {
    
    private func getFederatedIdentity(_ user: AWSCognitoIdentityUser) {
        let userPoolController = CognitoUserPoolController.sharedInstance
        userPoolController.getUserDetails(user: user) { (error, details) in
            if let error = error {
                self.displayLoginError(error: error as NSError)
                return
            }
            
            var email: String? = nil
            if let userAttributes = details?.userAttributes {
                for attribute in userAttributes {
                    if attribute.name?.compare("email") == .orderedSame {
                        email = attribute.value
                    }
                }
            }
            
            guard let emailAddress = email else {
                let error: NSError = NSError(domain: "com.clemente.AWSClmChatApplication", code: 100,
                                             userInfo: ["__type":"Cognito error", "message":"Missing email address."])
                self.displayLoginError(error: error)
                return
            }
            
            DispatchQueue.main.async {
                guard let username = self.usernameField.text,
                      let password = self.passwordField.text else { return }
                
                let task = user.getSession(username, password: password, validationData: nil)
                task.continueWith(block: { (task) -> Any? in
                    if let error = task.error {
                        self.displayLoginError(error: error as NSError)
                        return nil
                    }
                    
                    let userSession = task.result!
                    let idToken = userSession.idToken!
                    
                    let userPoolController = CognitoUserPoolController.sharedInstance
                    let identityPoolController = CognitoIdentityPoolController.sharedInstance
                    
                    identityPoolController.getFederatedIdentityForAmazon(idToken: idToken.tokenString,
                                                                         username: username, emailAddress: emailAddress,
                                                                         userPoolID: userPoolController.userPoolID,
                                                                         userPoolRegion: userPoolController.userPoolRegionString,
                                                                         completion: { (error) in
                        if let error = error {
                           let userInfo: [String:Any] = ["__type":"Unknown Error","message": error.localizedDescription]
                           let errorInfo = NSError(domain: "com.clemente.AWSClmChatApplication", code: 100, userInfo: userInfo)
                           self.displayLoginError(error: errorInfo)
                           return
                        }
                        self.displaySuccessMessage()
                        return
                    })
                    return nil
                })
            }
        }
    }
}
