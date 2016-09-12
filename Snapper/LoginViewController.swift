//
//  ViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/3/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import JWAnimatedImage
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController, FBSDKLoginButtonDelegate, UITextFieldDelegate {

    @IBOutlet weak var viewBackground: UIImageView!
    @IBOutlet weak var userName: UITextField!
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var loginWithSnapperButton: UIButton!
    @IBOutlet weak var SignUpWIthSnapperButton: UIButton!
    @IBOutlet weak var orLabel: UILabel!
    @IBOutlet weak var fbLoginPlaceHolder: UILabel!
    @IBOutlet weak var switchToLoginLabel: UILabel!
    @IBOutlet weak var toLoginButton: UIButton!
    @IBOutlet weak var toSignUpButton: UIButton!
    @IBOutlet weak var toSignUpLabel: UILabel!
    var isNewUser = false
    var doLogin = false
    let databaseRef = FIRDatabase.database().reference().child("users")
    var activityIndicator: UIActivityIndicatorView!
    let fbLoginButton = FBSDKLoginButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.userName.delegate = self
        self.password.delegate = self


        fbLoginButton.readPermissions = ["public_profile", "email", "user_friends"]
        fbLoginButton.frame.size.width = loginWithSnapperButton.bounds.width
        fbLoginButton.frame.size.height = loginWithSnapperButton.bounds.height
        fbLoginButton.center = fbLoginPlaceHolder.center
        fbLoginButton.layer.cornerRadius = 20
        self.view.addSubview(fbLoginButton)
        fbLoginButton.delegate = self
        fbLoginButton.layer.cornerRadius = 20
        loginWithSnapperButton.layer.borderColor = UIColor.whiteColor().CGColor
        loginWithSnapperButton.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        SignUpWIthSnapperButton.layer.borderColor = UIColor.whiteColor().CGColor
        SignUpWIthSnapperButton.layer.backgroundColor = UIColor.lightGrayColor().CGColor
        // Do any additional setup after loading the view.

    }

    func textFieldShouldReturn(textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }

    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(true)
        let url = NSBundle.mainBundle().URLForResource("bg", withExtension: "gif")
        let imageData = NSData(contentsOfURL: url!)
        let image = UIImage()
        image.AddGifFromData(imageData!)
        let gifManager = JWAnimationManager(memoryLimit: 10)
        viewBackground.SetGifImage(image, manager: gifManager)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(animated: Bool) {
        if (FIRAuth.auth()?.currentUser != nil) {
            self.performSegueWithIdentifier("userDidLogin", sender: self)
        }
        
//        do {
//            try FIRAuth.auth()?.signOut()
//        } catch {}
    }

    func loginButton(loginButton: FBSDKLoginButton!, didCompleteWithResult result: FBSDKLoginManagerLoginResult!, error: NSError!) {
        if (error != nil) {
            displayAlert("Error", message: error.localizedDescription)
        } else if (result.isCancelled) {
            displayAlert("Error", message: "Sorry, we were unable to connect to Facebook right now. Please try again later.")
        } else {
            let credentials = FIRFacebookAuthProvider.credentialWithAccessToken(FBSDKAccessToken.currentAccessToken().tokenString)
            FIRAuth.auth()?.signInWithCredential(credentials, completion: { (user, error) in
                if (error != nil) {
                    self.displayAlert("Error", message: (error?.localizedDescription)!)
                } else {
                    // setup user and shift to next view
                    let graphRequest = FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "id"])
                    graphRequest.startWithCompletionHandler({ (connection, result, error) in
                        if (error != nil) {
                            self.displayAlert("Error", message: error.localizedDescription)
                        } else {
                            if let FBID = result.valueForKey("id") as? String {
                                let userData = [
                                    "name": (user?.displayName)!,
                                    "email": (user?.email)!,
                                    "uid": (user?.uid)!,
                                    "FBID": FBID,
                                    "userPicture": "https://graph.facebook.com/\(FBID)/picture?type=large"
                                ]
                                self.databaseRef.child("\((user?.uid)!)").updateChildValues(userData)
                                self.performSegueWithIdentifier("userDidLogin", sender: self)
                            }

                        }
                    })
                }
            })
        }

    }

    func loginButtonDidLogOut(loginButton: FBSDKLoginButton!) {

    }
    @IBAction func loginWithSnapper(sender: AnyObject) {
        if (doLogin) {
            if (hasValidCredentials(userName.text!, password: password.text!)) {
                FIRAuth.auth()?.signInWithEmail(userName.text!, password: password.text!, completion: { (user, error) in
                    if (error != nil) {
                        self.displayAlert("Error", message: (error?.localizedDescription)!)
                    } else {
                        // to next view
                        print("user logged in")
                        if (self.isNewUser) {
                            self.performSegueWithIdentifier("toUserSignUp", sender: self)
                        } else {
                            self.performSegueWithIdentifier("userDidLogin", sender: self)
                        }
                    }
                })
            }
        }
        UIView.animateWithDuration(0.8, animations: {
            self.fbLoginButton.alpha = 0
            self.fbLoginButton.userInteractionEnabled = false
            self.userName.alpha = 1
            self.password.alpha = 1
            self.toSignUpButton.alpha = 1
            self.toSignUpLabel.alpha = 1
            self.orLabel.alpha = 0
            self.doLogin = true
        })
    }

    @IBAction func signUpWithSnapper(sender: AnyObject) {
        if (hasValidCredentials(userName.text!, password: password.text!)) {
            FIRAuth.auth()?.createUserWithEmail(userName.text!, password: password.text!, completion: { (user, error) in
                if (error != nil) {
                    self.displayAlert("Error", message: (error?.localizedDescription)!)
                } else {
                    let userData = [
                        "uid": (user?.uid)!,
                        "email": (user?.email)!,
                        "FBID": (user?.uid)!
                    ]
                    self.databaseRef.child("\((user?.uid)!)").updateChildValues(userData)
                    self.isNewUser = true
                    self.loginWithSnapper(self)
                }
            })
        }
    }

    @IBAction func toSignUp(sender: AnyObject) {
        UIView.animateWithDuration(0.8, animations: {
            self.loginWithSnapperButton.alpha = 0
            self.loginWithSnapperButton.userInteractionEnabled = false
            self.SignUpWIthSnapperButton.alpha = 1
            self.SignUpWIthSnapperButton.userInteractionEnabled = true
            self.SignUpWIthSnapperButton.center = self.loginWithSnapperButton.center
            self.toSignUpButton.alpha = 0
            self.toSignUpLabel.alpha = 0
            self.toLoginButton.userInteractionEnabled = true
            self.switchToLoginLabel.alpha = 1
            self.toLoginButton.alpha = 1
            self.toLoginButton.userInteractionEnabled = true
        })
    }
    @IBAction func toLogin(sender: AnyObject) {
        UIView.animateWithDuration(0.8, animations: {
            self.loginWithSnapperButton.alpha = 1
            self.loginWithSnapperButton.userInteractionEnabled = true
            self.SignUpWIthSnapperButton.alpha = 0
            self.SignUpWIthSnapperButton.userInteractionEnabled = false
            self.toSignUpButton.alpha = 1
            self.toSignUpButton.userInteractionEnabled = true
            self.toSignUpLabel.alpha = 1
            self.toLoginButton.userInteractionEnabled = false
            self.switchToLoginLabel.alpha = 0
            self.toLoginButton.alpha = 0
            self.toLoginButton.userInteractionEnabled = false
        })
    }

    func hasValidCredentials(userName: String, password: String) -> Bool {
        if (userName.characters.count == 0 && password.characters.count == 0) {
            // display alert for invlaid credentials
            displayAlert("Error", message: "Please enter a valid email address and password.")
            return false
        } else if (userName.characters.count == 0) {
            // display alert for invalid username
            displayAlert("Error", message: "Please enter a valid email address")
            return false
        } else if (password.characters.count == 0) {
            // display alert for invalid password
            displayAlert("Error", message: "Please enter a valid password")
            return false
        }
        return true
    }

    func startSpinner() {
        activityIndicator = UIActivityIndicatorView(frame: CGRectMake(0, 0, 50, 50))
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.White
        activityIndicator.transform = CGAffineTransformMakeScale(1.5, 1.5)
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        self.view.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        UIApplication.sharedApplication().beginIgnoringInteractionEvents()
    }

    func stopSpinner() {
        activityIndicator.stopAnimating()
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
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
