//
//  HomeViewController.swift
//  sbHacks
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        databaseRef = Database.database().reference()
        let pasteboardString: String? = UIPasteboard.general.string
        if let myString = pasteboardString {
            databaseRef.child("Users").updateChildValues(["pasteboardString": myString])
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let storage = Storage.storage()
            let storageRef = storage.reference()
            
            Auth.auth().signInAnonymously() { (user, error) in
                if error != nil {
                    print(error as Any)
                    return
                }
                var data = Data()
                data = UIImageJPEGRepresentation(pickedImage, 0.5)! // compression quality
                
                // upload path
                let filePath = "\("photo")"
                let metaData = StorageMetadata()
                metaData.contentType = "image/jpg"
                storageRef.child(filePath).putData(data, metadata: metaData){(metaData,error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    else {
                        // store downloadURL in database
                        let downloadURL = metaData!.downloadURL()!.absoluteString
                        self.databaseRef.child("Users").updateChildValues(["photo": downloadURL])
                    }
                }
            }
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
