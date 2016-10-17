//
//  SettingsViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 10/10/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
class SettingsViewController: UIViewController {

    @IBOutlet weak var unameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var signOutButton: UIButton!
    let currUser = (FIRAuth.auth()?.currentUser?.uid)!
    let databaseReference = FIRDatabase.database().reference().child("users")
    var userUIImage:UIImage?
    var isFbLogin = false
    override func viewDidLoad() {
        super.viewDidLoad()
        unameLabel.text = (FIRAuth.auth()?.currentUser?.displayName)!
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(animated: Bool) {
        databaseReference.child(currUser).observeSingleEventOfType(.Value, withBlock: {(snapshot) in
            if (snapshot.exists()) {
                if let FBID
            }
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
