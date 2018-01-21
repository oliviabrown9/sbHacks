//
//  DisplayTextViewController.swift
//  sbhacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//

import UIKit
import Firebase

class DisplayTextViewController: UIViewController {
    
    var databaseRef: DatabaseReference!
    var textToDisplay : String?

    @IBOutlet weak var displayTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTextField.isUserInteractionEnabled = false
        
        databaseRef = Database.database().reference()
        databaseRef.child("Users").child("clipboardString").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    let key = child.key ;
                    if (key.contains("clipboardString")) {
                        self.textToDisplay = child.value as! String;
                        self.displayTextField.text = self.textToDisplay
                        
                    }
                }
            }
        })
        
    }
}
