//
//  ImagePreviewViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/8/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
var isReceviedImage = false

class ImagePreviewViewController: UIViewController {

    @IBOutlet weak var capturedImageHolder: UIImageView!
    @IBOutlet weak var backDropLayer: UILabel!
    @IBOutlet weak var savebutton: UIButton!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var sendImageButton: UIButton!
    var saveButtonCenter: CGPoint?
    var timer = NSTimer()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(animated: Bool) {
        if (isReceviedImage) {
            print(savebutton.center)
            print(sendImageButton.center)
            saveButtonCenter = savebutton.center
            sendImageButton.alpha = 0
            sendImageButton.userInteractionEnabled = false
            savebutton.center = sendImageButton.center
            userNameLabel.text = selectedUsersName
            userNameLabel.alpha = 1
            backDropLayer.alpha = 1
            print(savebutton.center)
            self.view.layoutIfNeeded()
            timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("dismissRecievedImage"), userInfo: nil, repeats: false)
            

//            self.view.userInteractionEnabled = false

        } else {
            if (saveButtonCenter != nil && saveButtonCenter != savebutton.center) {
                savebutton.center = saveButtonCenter!
            }
            sendImageButton.alpha = 1
            sendImageButton.userInteractionEnabled = true
//            savebutton.center = sendImageButton.center
            userNameLabel.text = selectedUsersName
            userNameLabel.alpha = 0
            backDropLayer.alpha = 0

        }
        print(capturedImage!)
        capturedImageHolder.image = capturedImage!
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func dismissRecievedImage() {
        timer.invalidate()
//        self.view.userInteractionEnabled = true
//        for view in self.view.subviews {
//            if (view.tag == 22) {
//                view.removeFromSuperview()
//            }
//        }
        // perform segue
        self.performSegueWithIdentifier("backToCameraView", sender: self)
    }

    @IBAction func saveImage(sender: AnyObject) {
        let image = UIImage(CGImage: (capturedImage?.CGImage)!, scale: 1.0, orientation: UIImageOrientation.Right)
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
        displayAlert("Success", message: "Your image was saved to your Photo Library")
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
