//
//  ChatViewController.swift
//  AWSClmChatApplication
//
//  Created by MACBOOK AIR on 3/25/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, SentImageDelegate {
    
    @IBOutlet weak var tableView: UITableView?
    @IBOutlet weak var messageTextField: UITextField?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    @IBOutlet weak var sendTextButton: UIButton?
    
    var from_userId: String?
    var to_userId: String?
    
    fileprivate var originalScrollViewYOffset: CGFloat = 0.0
    fileprivate var currentChat: Chat?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Chat"
        
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh(_:)), for: .valueChanged)
        
        tableView?.refreshControl = refreshControl
        
        self.activityIndicator?.hidesWhenStopped = true
        self.activityIndicator?.stopAnimating()
        
        let field = messageTextField as! GenericWithImage
        field.sendImageController = self
        
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if (currentChat == nil) {
            prepareForChat(between: from_userId, and: to_userId)
        } else {
            disableUI()
            self.refreshMessages {
                self.messageTextField?.isEnabled = true
                self.enableUI()
            }
        }
    }
    
    private func prepareForChat(between sourceUserID: String?,and destinationUserID: String?) {
        self.activityIndicator?.startAnimating()
        self.messageTextField?.isEnabled = false
        self.sendTextButton?.isEnabled = false
        
        guard let sourceUserID = sourceUserID, let destinationUserID = destinationUserID else {
            let error = NSError(domain: "com.igorclemente.AWSClmChatApplication",code: 100,
                                userInfo: ["__type":"Error", "message":"Could not load chat."])
            
            self.displayError(error: error)
            return
        }
        
        let chatManager = ChatManager.sharedInstance
        chatManager.loadChat(fromUserID: sourceUserID, toUserID: destinationUserID) { (error, chat) in
            if let error = error {
                self.displayError(error: error as NSError)
                return
            }
            
            self.currentChat = chat
            
            chatManager.refreshAllMessages(chat: chat!, completion: { (error) in
                if let error = error {
                    self.displayError(error: error as NSError)
                    return
                }
                
                DispatchQueue.main.async {
                    self.activityIndicator?.stopAnimating()
                    self.messageTextField?.isEnabled = true
                    self.sendTextButton?.isEnabled = true
                }
            })
        }
    }
    
    private func disableUI() {
        DispatchQueue.main.async {
            self.messageTextField?.isEnabled = false
            self.sendTextButton?.isEnabled = false
            self.activityIndicator?.startAnimating()
            UIApplication.shared.beginIgnoringInteractionEvents()
        }
    }
    
    private func enableUI() {
        DispatchQueue.main.async {
            self.messageTextField?.isEnabled = true
            self.sendTextButton?.isEnabled = true
            self.activityIndicator?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    private func displayError(error: NSError) {
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func refreshMessages(refreshActions: @escaping ()->Void) {
        guard let currentChat = self.currentChat else { return }
        
        let chatManager = ChatManager.sharedInstance
        chatManager.refreshAllMessages(chat: currentChat) { (error) in
            DispatchQueue.main.async {
                refreshActions()
            }
            
            if let error = error {
                self.displayError(error: error as NSError)
                return
            }
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    @objc private func refresh(_ refreshControl: UIRefreshControl) {
        self.messageTextField?.isEnabled = false
        self.sendTextButton?.isEnabled = false
        
        self.refreshMessages {
            self.messageTextField?.isEnabled = true
            self.sendTextButton?.isEnabled = true
            refreshControl.endRefreshing()
        }
    }
    
    @IBAction func sendText(_ sender: Any) {
        self.messageTextField?.resignFirstResponder()
        
        guard let sendText = self.messageTextField?.text,
              let currentChat = self.currentChat else {
            return
        }
        
        self.disableUI()
        
        let chatManager = ChatManager.sharedInstance
        chatManager.sendTextMessage(chat: currentChat, messageText: sendText) { (error) in
            if let error = error {
                self.enableUI()
                self.displayError(error: error as NSError)
                return
            }
            
            self.enableUI()
            
            DispatchQueue.main.async {
                self.tableView?.reloadData()
            }
        }
    }
    
    func uploadImage() {
        self.performSegue(withIdentifier: "uploadImage", sender: nil)
    }
    
    @IBAction func didEndOnExit(_ sender: Any) {
        self.messageTextField?.resignFirstResponder()
    }
}

extension ChatViewController {
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier?.compare("uploadImage") != .orderedSame {
            return
        }
        
        if let destination = segue.destination as? UploadImageViewController {
            destination.currentChat = self.currentChat
        }
    }
}

extension ChatViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100.0
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let chatManager = ChatManager.sharedInstance
        
        if let chat = self.currentChat,
           let messages = chatManager.conversations?[chat] {
            return messages!.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let chatManager = ChatManager.sharedInstance
        
        guard let chat = self.currentChat,
              let messages = chatManager.conversations?[chat],
              let message = messages?[indexPath.row],
              let messageText = message.message_text,
              let messageImagePreview = message.message_image_preview,
              let senderID = message.sender_id else {
            return UITableViewCell()
        }
        
        let cognitoIdentityPoolController = CognitoIdentityPoolController.sharedInstance
        guard let currentIdentityID = cognitoIdentityPoolController.currentIdentityID else {
            return UITableViewCell()
        }
        
        if messageText.compare("NA") != .orderedSame {
            if senderID.compare(currentIdentityID) == .orderedSame {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SentTextTableViewCell",
                                                         for: indexPath) as? SentTextTableViewCell
                
                cell?.messageTextLabel.text = messageText
                cell?.messageBalloon?.leftArrow = false
                cell?.messageBalloon?.color = UIColor.gray
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedTextTableViewCell",
                                                         for: indexPath) as? ReceivedTextTableViewCell
                
                cell?.messageTextLabel.text = messageText
                cell?.messageBalloon?.leftArrow = true
                cell?.messageBalloon?.changeColor(withSeed: indexPath.first ?? 0)
                return cell!
            }
        } else {
            if senderID.compare(currentIdentityID) == .orderedSame {
                let cell = tableView.dequeueReusableCell(withIdentifier: "SentImageTableViewCell",
                                                         for: indexPath) as? SentImageTableViewCell
                
                cell?.loadImage(imageFile: messageImagePreview)
                cell?.messageBalloon?.leftArrow = false
                cell?.messageBalloon?.color = UIColor.gray
                return cell!
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "ReceivedImageTableViewCell",
                                                         for: indexPath) as? ReceivedImageTableViewCell
                
                cell?.loadImage(imageFile: messageImagePreview)
                cell?.messageBalloon?.leftArrow = true
                cell?.messageBalloon?.changeColor(withSeed: indexPath.first ?? 0)
                return cell!
            }
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
