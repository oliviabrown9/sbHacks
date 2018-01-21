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
import CoreLocation

class HomeViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {
    
    var days:[String] = []
    var stepsTaken:[Int] = []
    
    var databaseRef: DatabaseReference!
    let motionManager = CMMotionManager()
    let pedoMeter = CMPedometer()
    let locationManager = CLLocationManager()
    
    var keyName: String?
    
    // Button IBOutlets
    @IBOutlet weak var buttonA: UIButton!
    @IBOutlet weak var buttonB: UIButton!
    @IBOutlet weak var buttonC: UIButton!
    @IBOutlet weak var buttonD: UIButton!
    @IBOutlet weak var buttonE: UIButton!
    @IBOutlet weak var buttonF: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    
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
            self.databaseRef.child("Users").updateChildValues(["gyroX": gyroX, "gyroY": gyroY, "gyroZ": gyroZ])
        }
    }
    
    @IBAction func accelButtonPressed(_ sender: Any) {
        if let accelData = motionManager.accelerometerData {
            let accelX = accelData.acceleration.x
            let accelY = accelData.acceleration.y
            let accelZ = accelData.acceleration.z
            self.databaseRef.child("Users").updateChildValues(["accelX": accelX, "accelY": accelY, "accelZ": accelZ])
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
    
    private func roundButtons() {
        buttonA.layer.cornerRadius = 12
        buttonB.layer.cornerRadius = 12
        buttonC.layer.cornerRadius = 12
        buttonD.layer.cornerRadius = 12
        buttonE.layer.cornerRadius = 12
        buttonF.layer.cornerRadius = 12
    }
    
    private func setupListener() {
        
        databaseRef.child("State").observe(.childChanged, with: { (snapshot) in
            if snapshot.key == "done" {
                if snapshot.value as! Bool == true {
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
    
    @IBAction func unwindToHome(segue:UIStoryboardSegue) { }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        roundButtons()
        
        motionManager.gyroUpdateInterval = 1.0/60.0
        motionManager.startGyroUpdates()
        motionManager.accelerometerUpdateInterval = 1.0/60.0
        motionManager.startAccelerometerUpdates()
        
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
    
    @IBAction func locationPressed(_ sender: Any) {
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        let currentLat = locationManager.location?.coordinate.latitude
        let currentLong = locationManager.location?.coordinate.longitude
        self.databaseRef.child("Users").updateChildValues(["lat": currentLat as Any, "long": currentLong as Any])
    }
    
    private func locationManager(manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    }
    
    @IBAction func pedometerPressed(_ sender: Any) {
        var cal = Calendar.current
        var comps = cal.dateComponents([.year, .month, .day, .hour, .minute, .second], from: Date())
        comps.hour = 0
        comps.minute = 0
        comps.second = 0
        let timeZone = TimeZone.ReferenceType.system
        cal.timeZone = timeZone
        
        let midnightOfToday = cal.date(from: comps)!
        
        if(CMPedometer.isStepCountingAvailable()){
            
            self.pedoMeter.startUpdates(from: midnightOfToday) { (data: CMPedometerData?, error) -> Void in
                DispatchQueue.main.async(execute: { () -> Void in
                    if(error == nil){
                        self.databaseRef.child("Users").updateChildValues(["numSteps": data!.numberOfSteps])
                    }
                })
            }
        }
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
