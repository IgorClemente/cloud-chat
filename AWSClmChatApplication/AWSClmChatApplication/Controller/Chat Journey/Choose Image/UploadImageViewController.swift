//
//  UploadImageViewController.swift
//  AWSChat
//
//  Created by Igor Clemente on 13/04/2019.
//  Copyright © 2019 MACBOOKAIR All rights reserved.
//

import UIKit

class UploadImageViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView?
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView?
    
    var currentChat:Chat?
    
    fileprivate var selectedImage:UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Carregar imagem"
        
        guard let activityIndicator = self.activityIndicator else { return }
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func cancel(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectImage(_ sender: Any) {
        let imagePicker = UIImagePickerController()
        
        imagePicker.delegate = self
        imagePicker.sourceType = UIImagePickerController.SourceType.photoLibrary
        imagePicker.allowsEditing = false
        
        self.present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func sendImage(_ sender: Any) {
        guard let chat = currentChat,
              let image = self.selectedImage else {
            return
        }
        
        activityIndicator?.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        let chatManager = ChatManager.sharedInstance
        chatManager.sendImage(chat: chat, message: image) { (error) in
            if let error = error {
                self.displayError(error: error as NSError)
                return
            }
            
            DispatchQueue.main.async {
                self.activityIndicator?.stopAnimating()
                UIApplication.shared.endIgnoringInteractionEvents()
                self.navigationController?.popViewController(animated: true)
            }
            return
        }
    }
    
    private func displayError(error: NSError) {
        let alertController = UIAlertController(title: error.userInfo["__type"] as? String,
                                                message: error.userInfo["message"] as? String,
                                                preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
        alertController.addAction(okAction)
        
        DispatchQueue.main.async {
            self.activityIndicator?.stopAnimating()
            UIApplication.shared.endIgnoringInteractionEvents()
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
}

extension UploadImageViewController : UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            selectedImage = image
            self.imageView?.image = selectedImage
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
