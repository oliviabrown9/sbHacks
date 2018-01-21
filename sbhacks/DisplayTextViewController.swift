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
    var keyName: String?
    var textToDisplay: String?
    

    @IBOutlet weak var displayTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        displayTextView.isUserInteractionEnabled = false
        
        databaseRef = Database.database().reference()
        databaseRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    if child.key == self.keyName! {
                        self.textToDisplay = child.value as! String;
                        self.displayTextView.text = self.textToDisplay
                    }
                }
            }
        })
    }
}
