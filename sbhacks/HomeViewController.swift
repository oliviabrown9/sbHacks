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
import Starscream

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var databaseRef: DatabaseReference!
    let motionManager = CMMotionManager()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let socket = WebSocket(url: URL(string: "https://google.com")!)
        socket.delegate = self
        socket.connect()
        
        styleButtons()
        motionManager.gyroUpdateInterval = 1.0/60.0
        motionManager.startGyroUpdates()
        databaseRef = Database.database().reference()
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

extension HomeViewController : WebSocketDelegate {
    func websocketDidConnect(socket: WebSocketClient) {
    }
    
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
    }
    
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        guard let data = text.data(using: .utf16),
            let jsonData = try? JSONSerialization.jsonObject(with: data),
            let jsonDict = jsonData as? [String: Any],
            let dataType = jsonDict["type"] as? String else {
                return
        }
        if dataType == "string" {
            performSegue(withIdentifier: "toStringScreen", sender: self)
        }
        else if dataType == "image" {
            performSegue(withIdentifier: "toImageScreen", sender: self)
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        return
    }
}

