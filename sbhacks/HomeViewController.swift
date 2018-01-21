//
//  HomeViewController.swift
//  sbHacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//

import UIKit
import Firebase
import CoreMotion

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef: DatabaseReference!
    let motionManager = CMMotionManager()
    var keyName: String?
    
    @IBAction func testButton(_ sender: Any) {
        performSegue(withIdentifier: "toDisplayText", sender: self)
    }
    // Button IBOutlets
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    @IBOutlet weak var buttonG: UIButton!
    
    
    @IBAction func clipboardButtonPressed(_ sender: Any) {
        let pasteboardString: String? = UIPasteboard.general.string
        if let myString = pasteboardString {
            databaseRef.child("Users").updateChildValues(["clipboardText": myString])
        }
    }
    
    @IBAction func gyroButtonPressed(_ sender: Any) {
        if let gyroData = motionManager.gyroData {
            let gyroX = gyroData.rotationRate.x
            let gyroY = gyroData.rotationRate.y
            let gyroZ = gyroData.rotationRate.z
            self.databaseRef.child("Users").updateChildValues(["GyroX": gyroX, "GyroY": gyroY, "GyroZ": gyroZ])
        }
    }
    
    @IBAction func takePhoto(_ sender: AnyObject) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    private func styleButtons() {
        buttonA.applyGradient(colors: [UIColor(red:0.54, green:1.00, blue:0.67, alpha:1.0), UIColor(red:0.2, green:1.00, blue:0.67, alpha:0.3)])
        
        buttonA.layer.cornerRadius = 12
        buttonB.layer.cornerRadius = 12
        buttonC.layer.cornerRadius = 12
        buttonD.layer.cornerRadius = 12
        buttonE.layer.cornerRadius = 12
        buttonF.layer.cornerRadius = 12
        buttonG.layer.cornerRadius = 12
        
    }
    
    private func setupListener() {
        
        databaseRef.child("State").observe(.childChanged, with: { (snapshot) in
            if snapshot.key == "done" {
                if snapshot.value as! String == "true" {
                    self.databaseRef.child("State").observeSingleEvent(of: .value, with: { (snapshot) in
                        if let result = snapshot.children.allObjects as? [DataSnapshot] {
                            for child in result {
                                let key = child.key;
                                if (key.contains("keyName")) {
                                    self.keyName = (child.value as! String)
                                    if self.keyName == "clipboardText" {
                                        self.performSegue(withIdentifier: "toDisplayText", sender: self)
                                    }
                                    else if self.keyName == "photo" {
                                        self.performSegue(withIdentifier: "toDisplayImage", sender: self)
                                    }
                                }
                            }
                        }
                    })
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleButtons()
        motionManager.gyroUpdateInterval = 1.0/60.0
        motionManager.startGyroUpdates()
        databaseRef = Database.database().reference()
        setupListener()
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
                data = UIImageJPEGRepresentation(pickedImage, 0.3)! // compression quality might need to be greater
                
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toDisplayText" {
            let destination = segue.destination as! DisplayTextViewController
            destination.keyName = keyName
        }
        else if segue.identifier == "toDisplayImage" {
            let destination = segue.destination as! DisplayImageViewController
            destination.keyName = keyName
        }
    }
}

extension UIView {
    func applyGradient(colors: [UIColor]) -> Void {
        self.applyGradient(colors: colors, locations: nil)
    }
    
    func applyGradient(colors: [UIColor], locations: [NSNumber]?) -> Void {
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.bounds
        gradient.colors = colors.map { $0.cgColor }
        gradient.locations = locations
        
        self.layer.insertSublayer(gradient, at: 0)
        self.layer.masksToBounds = true
        gradient.cornerRadius = 12
    }
}
