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
        
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else { return }
        
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
        
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.refresh(nil)
    }

    @objc func refresh(_ refreshControl: UIRefreshControl?) {
        self.disableUI()
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else { return }
        
        let dynamoDBController = DynamoDBController.sharedInstance
        dynamoDBController.refreshFriendList(userId: currentIdentityID) { (error) in
            if let error = error {
                DispatchQueue.main.async {
                    refreshControl?.endRefreshing()
                    self.enableUI()
                    self.displayError(error: error as NSError)
                    return
                }
            }
            
            DispatchQueue.main.async {
                refreshControl?.endRefreshing()
                self.enableUI()
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
    
    private func disableUI() {
        DispatchQueue.main.async {
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    private func enableUI() {
        DispatchQueue.main.async {
            UIApplication.shared.endIgnoringInteractionEvents()
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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "FriendTableViewCell", for: indexPath) as? FriendTableViewCell else {
            return UITableViewCell()
        }
        
        let chatManager = ChatManager.sharedInstance
        
        if let friendList = chatManager.friendList {
           let user = friendList[indexPath.row]
            cell.nameLabel?.text = user.username
            cell.emailAddressLabel?.text = user.email_address
        }
        
        return cell
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


