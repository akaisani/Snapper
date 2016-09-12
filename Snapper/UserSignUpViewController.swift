//
//  UserSignUpViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/5/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase
import JWAnimatedImage

class UserSignUpViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var viewBackground: UIImageView!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var continueButton: UIButton!
    var didPickImage = false
    let databaseRef = FIRDatabase.database().reference().child("users")
    let storageRef = FIRStorage.storage().referenceForURL("gs://snapper-6d1fe.appspot.com")
    let uid: String = (FIRAuth.auth()?.currentUser?.uid)!
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userNameTextField.delegate = self
        let tapRecognizer = UITapGestureRecognizer(target: self, action: Selector("showImagePickingOptions"))
        userImage.addGestureRecognizer(tapRecognizer)
        userImage.userInteractionEnabled = true

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let url = NSBundle.mainBundle().URLForResource("bgForSignup", withExtension: "gif")
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage()
        image.AddGifFromData(imageData!)
        let gifManager = JWAnimationManager(memoryLimit: 8)
        viewBackground.SetGifImage(image, manager: gifManager)
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func doneWithSignUP(sender: AnyObject) {
        if (!didPickImage) {
            displayAlert("Error", message: "Please pick an image for your profile")
        } else if (userNameTextField.text?.characters.count == 0) {
            displayAlert("Error", message: "Please enter your name in the text field provided to you")
        } else {
            let userImageFile = UIImagePNGRepresentation(userImage.image!)
            let currUserBucket = storageRef.child("userImages/\(uid)")
            let metadata = FIRStorageMetadata()
            metadata.contentType = "image/png"
            currUserBucket.putData(userImageFile!, metadata: metadata, completion: { (metaData, error) in
                if (error != nil) {
                    self.displayAlert("Error", message: (error?.localizedDescription)!)
                } else {
                    let imageName = metadata.name!
                    let userName = self.userNameTextField.text!
                    let userData = [
                        "name": userName,
                        "userPicture": imageName,
                    ]
                    self.databaseRef.child(self.uid).updateChildValues(userData)
                    self.performSegueWithIdentifier("userSignUpDone", sender: self)
                }
            })

        }
    }

    func showImagePickingOptions() {
        let options = UIAlertController(title: "Image Picker", message: "Please select an option from the ones presented below.", preferredStyle: .ActionSheet)
        options.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (action) in
            self.getImageFromCamera()
            }))
        options.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (action) in
            self.getImageFromLibrary()
            }))
        options.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(options, animated: true, completion: nil)
    }

    func getImageFromCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    func getImageFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = UIImagePickerControllerSourceType.PhotoLibrary
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        userImage.image = UIImage(named: "placeholder.png")
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage, editingInfo: [String: AnyObject]?) {
        self.dismissViewControllerAnimated(true, completion: nil)
        didPickImage = true
        userImage.image = image
    }

    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }
    /*
     // MARK: - Navigation

     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */

}
