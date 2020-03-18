//
//  SignupViewController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 07/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit
import AWSCognitoIdentityProvider

class SignupViewController: UIViewController {

    @IBOutlet weak var usernameField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var createAccountButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.createAccountButton.isEnabled = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func onCreateAccount(_ sender: Any) {
        guard let username = self.usernameField.text,
              let password = self.passwordField.text,
              let emailAddress = self.emailField.text else {
            return
        }
        
        let poolController = CognitoUserPoolController.sharedInstance
        poolController.signup(username: username, password: password, emailAddress: emailAddress) { (error, user) in

            if let error = error {
                DispatchQueue.main.async {
                    self.displaySignupError(error: error as NSError,completion: nil)
                }
                return
            }
            
            guard let user = user else {
                let userInfo: [String:Any] = ["__type":"Unknowm Error","message":"Cognito User Pool Error"]
                let error: NSError = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 1021, userInfo: userInfo)
                
                DispatchQueue.main.async {
                    self.displaySignupError(error: error,completion: nil)
                }
                return
            }
            
            if user.confirmedStatus != AWSCognitoIdentityUserStatus.confirmed {
                DispatchQueue.main.async {
                    self.requestConfirmationCode(user, completion: nil)
                }
            } else {
                self.getFederatedIdentity(user)
            }
        }
    }

    @IBAction func usernameDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func passwordDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
    
    @IBAction func emailDidEndOnExit(_ sender: Any) {
        dismissKeyboard()
    }
}


extension SignupViewController : UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if let username = self.usernameField.text,
           let password = self.passwordField.text,
           let emailAddress = self.emailField.text {
            if (username.count > 0) && (password.count > 0) && (emailAddress.count > 0) {
                self.createAccountButton.isEnabled = true
            }
        }
        return true
    }
}

extension SignupViewController {
    
    fileprivate func dismissKeyboard() {
        usernameField.resignFirstResponder()
        passwordField.resignFirstResponder()
        emailField.resignFirstResponder()
    }
    
    fileprivate func displaySignupError(error: NSError, completion: (()->Void)?) {
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String, message: error.userInfo["message"] as? String, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            if let completion = completion {
                completion()
            }
        }
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController,animated: true)
        }
    }
    
    fileprivate func displaySuccessMessage() {
        let alertController = UIAlertController(title: "Success.", message: "Login successful!", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            let storyboard = UIStoryboard(name: "ChatJourney", bundle: Bundle.main)
            if let homeViewController = storyboard.instantiateInitialViewController() {
                DispatchQueue.main.async {
                    self.present(homeViewController, animated: true, completion: nil)
                }
            }
        }
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func requestConfirmationCode(_ user: AWSCognitoIdentityUser, completion: (()->Void)?) {
        let alertController = UIAlertController(title: "Confirmation Code", message: "Please type the 6-digit confirmation code that has been sent to your email address.", preferredStyle: .alert)
        
        alertController.addTextField { (textField) in
            textField.placeholder = "######"
        }
        
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            if let textField = alertController.textFields?.first {
                if let confirmationCode = textField.text {
                    
                    let poolController = CognitoUserPoolController.sharedInstance
                    poolController.confirmSignup(user: user, confirmationCode: confirmationCode, completion: { (error) in
                        
                        if let error = error {
                            DispatchQueue.main.async {
                                self.displaySignupError(error: error as NSError, completion: {
                                    self.requestConfirmationCode(user, completion: nil)
                                })
                            }
                            return
                        }
                        
                        self.getFederatedIdentity(user)
                    })
                }
            }
        }
        
        let resendAction = UIAlertAction(title: "Resend code", style: .default) { (action) in
            
            let poolController = CognitoUserPoolController.sharedInstance
            poolController.resendConfirmationCode(user: user, completion: { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.displaySignupError(error: error as NSError, completion: {
                            self.requestConfirmationCode(user, completion: nil)
                        })
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    self.displayCodeResentMessage(user)
                }
            })
        }
        
        alertController.addAction(okAction)
        alertController.addAction(resendAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func displayCodeResentMessage(_ user: AWSCognitoIdentityUser) {
        let alertController = UIAlertController(title: "Resent.", message: "A 6-digit confirmation code has been sent to your email address.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "Ok", style: .default) { (action) in
            self.requestConfirmationCode(user, completion: nil)
        }
        
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    fileprivate func getFederatedIdentity(_ user: AWSCognitoIdentityUser) {
        let username = self.usernameField.text!
        let emailAddress = self.emailField.text!
        let password = self.passwordField.text!
        
        let task = user.getSession(username, password: password, validationData: nil)
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                DispatchQueue.main.async {
                    self.displaySignupError(error: error as NSError, completion: nil)
                }
                return nil
            }
            
            let userSession = task.result!
            let idToken = userSession.idToken!
            
            let userPoolController = CognitoUserPoolController.sharedInstance
            let identityPoolController = CognitoIdentityPoolController.sharedInstance
            
            identityPoolController.getFederatedIdentityForAmazon(idToken: idToken.tokenString, username: username, emailAddress: emailAddress,
                                                                 userPoolID: userPoolController.userPoolID,
                                                                 userPoolRegion: userPoolController.userPoolRegionString,
                                                                 completion: { (error) in
                if let error = error {
                    DispatchQueue.main.async {
                        self.displaySignupError(error: error as NSError, completion: nil)
                    }
                    return
                }
                                                                    
                DispatchQueue.main.async {
                    self.displaySuccessMessage()
                }
                return
            })
            return nil
        }
    }
}

