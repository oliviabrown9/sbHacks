//
//  DisplayImageViewController.swift
//  sbhacks
//
//  Created by Olivia Brown on 1/20/18.
//  Copyright © 2018 Olivia Brown. All rights reserved.
//

import UIKit
import Firebase

class DisplayImageViewController: UIViewController {
    
    var databaseRef: DatabaseReference!
    var keyName: String?
    
    @IBOutlet weak var displayImageView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        databaseRef = Database.database().reference()
        databaseRef.child("Users").observeSingleEvent(of: .value, with: { (snapshot) in
            if let result = snapshot.children.allObjects as? [DataSnapshot] {
                for child in result {
                    if child.key == self.keyName! {
                        if let url = URL.init(string: child.value as! String) {
                            self.displayImageView.downloadedFrom(url: url)
                        }
                    }
                }
            }
        })
    }
}

extension UIImageView {
    func downloadedFrom(url: URL, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        contentMode = mode
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { () -> Void in
                self.image = image
            }
            }.resume()
    }
    func downloadedFrom(link: String, contentMode mode: UIViewContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloadedFrom(url: url, contentMode: mode)
    }
}

