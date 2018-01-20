//
//  ViewController.swift
//  sbhacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let databaseRef: DatabaseReference! = Database.database().reference()
        
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        // take photo
        
        let image: UIImage?
        
        
        
        Auth.auth().signInAnonymously() { (user, error) in
            var data = Data()
            data = UIImageJPEGRepresentation(image!, 0.8)!
            // set upload path
            let filePath = "\(user!.uid)/\("userPhoto")"
            let metaData = StorageMetadata()
            metaData.contentType = "image/jpg"
            storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else {
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    //store downloadURL at database
                    databaseRef.child("Users").child(user!.uid).updateChildValues(["photo": downloadURL])
                }
            }
        }
    }
}

