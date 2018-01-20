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
    
    var ref: DatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ref = Database.database().reference()
        
        // take photo
        
        let image: UIImage?
        
        
        
        Auth.auth().signInAnonymously() { (user, error) in
            var data = Data()
            data = UIImageJPEGRepresentation(image!, 0.8)!
            // set upload path
            let filePath = "\(user!.uid)/\("userPhoto")"
            let metaData = FIRStorageMetadata()
            metaData.contentType = "image/jpg"
            self.storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                else {
                    //store downloadURL
                    let downloadURL = metaData!.downloadURL()!.absoluteString
                    //store downloadURL at database
                    self.databaseRef.child("Users").child(user!.uid).updateChildValues(["photo": downloadURL])
                }
            }
        }
    }
}

