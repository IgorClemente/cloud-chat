//
//  AddFriendViewController.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/17/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import UIKit

class AddFriendViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Escolher amigo..."
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else {
            print("Cognito identity is missing.")
            return
        }
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.refreshPotentialFriendList(currentUserId: currentIdentityID) { (error) in
            if let error = error {
                self.displayAddFriendError(error: error as NSError)
                return
            }
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    private func displayAddFriendError(error: NSError) {
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String, preferredStyle: .alert)
        
        let alertAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(alertAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}

extension AddFriendViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let chatManager = ChatManager.sharedInstance
        if let potentialFriendList = chatManager.potentialFriendList {
            print("Potential Friends \(potentialFriendList.count).")
            return potentialFriendList.count
        }
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let chatManager = ChatManager.sharedInstance
        let dynamoDBController = DynamoDBController.sharedInstance
        
        guard let potentialFriendList = chatManager.potentialFriendList else {
            return
        }
        
        let potentialFriend = potentialFriendList[indexPath.row]
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else {
            print("Missing identity ID.")
            return
        }
        
        dynamoDBController.addFriend(currentUserId: currentIdentityID, friendUserId: potentialFriend.id!) { (error) in
            if let error = error {
                self.displayAddFriendError(error: error as NSError)
                return
            }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell
        let chatManager = ChatManager.sharedInstance
        
        if let cell = cell,
           let potentialFriendList = chatManager.potentialFriendList {
            let user = potentialFriendList[indexPath.row]
            cell.nameLabel.text = user.username
            cell.emailAddressLabel.text = user.email_address
        }
        return cell!
    }
}
