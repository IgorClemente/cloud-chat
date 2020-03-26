//
//  HomeViewController.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 07/03/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit

class HomeViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView?
    
    private var selectedUserId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Lista de amigos"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        tableView?.refreshControl = refreshControl
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else {
            return
        }
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.refreshFriendList(userId: currentIdentityID) { (error) in
            if let error = error {
                self.displayError(error: error as NSError)
                return
            }
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }

    @objc func refresh(_ refreshControl: UIRefreshControl) {
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else {
            return
        }
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.refreshFriendList(userId: currentIdentityID) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    refreshControl.endRefreshing()
                    self.displayError(error: error as NSError)
                    return
                }
            }
            DispatchQueue.main.async {
                refreshControl.endRefreshing()
                self.tableView?.reloadData()
            }
        }
    }
    
    private func displayError(error: NSError) {
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let chatManager = ChatManager.sharedInstance
        
        if let friendList = chatManager.friendList {
            return friendList.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell
        
        let chatManager = ChatManager.sharedInstance
        
        if let cell = cell,
           let friendList = chatManager.friendList {
           let user = friendList[indexPath.row]
            cell.nameLabel.text = user.username
            cell.emailAddressLabel.text = user.email_address
        }
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let chatManager = ChatManager.sharedInstance
        
        if let friendList = chatManager.friendList {
            let user = friendList[indexPath.row]
            self.selectedUserId = user.id
        }
        self.performSegue(withIdentifier: "chatSegue", sender: nil)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier?.compare("chatSegue") != .orderedSame {
            return
        }
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        
        if let destinationViewController = segue.destination as? ChatViewController {
            destinationViewController.from_userId = cognitoIdentityPoolController.currentIdentityID
            destinationViewController.to_userId = self.selectedUserId
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}


