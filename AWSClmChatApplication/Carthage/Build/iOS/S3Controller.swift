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
        let task = transferUtility.uploadFile(fileURL, bucket: imagesBucketName,
                                              key: "\(remoteFileName).png",
                                              contentType: "image/png",
                                              expression: expression) { (task, error) in
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
}
