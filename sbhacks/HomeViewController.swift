//
//  ViewController.swift
//  sbhacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//

import UIKit
import Firebase

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef: DatabaseReference!
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            databaseRef = Database.database().reference()
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil { print(error); return }
                var data = Data()
                data = UIImageJPEGRepresentation(pickedImage, 0.8)!
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
                        self.databaseRef.child("Users").child(user!.uid).updateChildValues(["photo": downloadURL])
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}
