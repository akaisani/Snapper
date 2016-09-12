//
//  ViewSwitcherViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/6/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit

class ViewSwitcherViewController: UIViewController {

    @IBOutlet weak var viewSwitcher: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        viewSwitcher.showsHorizontalScrollIndicator = false
        var cameraViewRef = CameraView(nibName: "CameraView", bundle: nil)
        self.addChildViewController(cameraViewRef)
        self.viewSwitcher.addSubview(cameraViewRef.view)
        cameraViewRef.didMoveToParentViewController(self)

        var contactsViewRef = ContactsViewController(nibName: "ContactsViewController", bundle: nil)
        self.addChildViewController(contactsViewRef)
        self.viewSwitcher.addSubview(contactsViewRef.view)
        contactsViewRef.didMoveToParentViewController(self)

        var contactsViewFrame: CGRect = contactsViewRef.view.frame
        contactsViewFrame.origin.x = self.view.bounds.width
        contactsViewRef.view.frame = contactsViewFrame

        self.viewSwitcher.contentSize = CGSizeMake(self.view.frame.width * 2, self.view.frame.height)

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
