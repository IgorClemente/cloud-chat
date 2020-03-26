//
//  S3Controller.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 3/21/19.
//  Copyright © 2019 Igor Clemente. All rights reserved.
//

import Foundation
import AWSS3

class S3Controller {
    
    private let imagesBucketName: String = "com.igorclemente.awschat.images"
    private let thumbnailsBucketName: String = "com.igorclemente.awschat.thumbnails"
    static let sharedInstance: S3Controller = S3Controller()
    
    private init() { }
    
    func uploadImage(localFilePath: String, remoteFileName: String, completion: @escaping (Error?)->Void) {
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = { (task, progress) in print ("Uploaded Progress: \(progress.fractionCompleted)") }
        
        let fileURL: URL = URL(fileURLWithPath: localFilePath)
        
        let transferUtility = AWSS3TransferUtility.default()
        let task = transferUtility.uploadFile(fileURL, bucket: imagesBucketName, key: "\(remoteFileName).png",
                                              contentType: "image/png", expression: expression) { (task, error) in
            if let error = error {
                completion(error)
                return
            }
            completion(nil)
        }
        
        task.continueWith { (task) -> Any? in
            if let error = task.error {
                completion(error)
                return nil
            }
            completion(nil)
            return nil
        }
    }
    
    func downloadThumbnail(localFilePath: String, remoteFileName: String, completion: @escaping (Error?)->Void) {
        let s3Key = "\(remoteFileName).png"
        let fileURL = URL(fileURLWithPath: localFilePath)
        
        let expression = AWSS3TransferUtilityDownloadExpression()
        expression.progressBlock = { (task, progress) in print("Downloaded: \(progress.fractionCompleted)%") }
        
        let transferUtility = AWSS3TransferUtility.default()
        let task = transferUtility.download(to: fileURL, bucket: thumbnailsBucketName, key: s3Key, expression: expression) { (task, url, data, error) in
            let fileManager = FileManager.default
            
            if error != nil {
                if fileManager.fileExists(atPath: localFilePath) == true {
                    try? fileManager.removeItem(atPath: localFilePath)
                }
                completion(error)
                return
            }
            
            if fileManager.fileExists(atPath: localFilePath) == false {
                let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 600, userInfo: nil)
                completion(error)
                return
            }
            
            let data = NSData(contentsOf: fileURL)
            if data?.length == 0 {
                try? fileManager.removeItem(atPath: localFilePath)
                
                let error = NSError(domain: "com.igorclemente.AWSClmChatApplication", code: 600, userInfo: nil)
                completion(error)
                return
            }
            completion(nil)
        }
        
        task.continueWith { (task) -> Any? in
            if let error = task.error as NSError? {
                completion(error)
                return nil
            }
            return nil
        }
    }
}
