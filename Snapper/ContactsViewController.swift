//
//  ContactsViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/6/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

// TODO: fix bug where other view doesnt update when image sent and add pull to refresh and spinners
// done with cmaera image sent bug
// restrict images to one or anble more iamges
// add pull to refresh
// add functionality to send multiple images to a user instead of just one untill user opens the image
import UIKit
import Firebase

var selectedUsersName = ""
class ContactsViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationItem!
    @IBOutlet weak var contactsTable: UITableView!
    let databaseRef = FIRDatabase.database().reference().child("sentImages")
    let storageRef = FIRStorage.storage().referenceForURL("gs://snapper-6d1fe.appspot.com")
    let currUID = "\((FIRAuth.auth()?.currentUser?.uid)!)"
    var userNames = [String]()
    var userUIDS = [String]()
    var userImageFiles = [UserImageFile]()
    var userHasFBLogin = [Bool]()
    var timer = NSTimer()
    var selectedIndex = -1
    var refresher = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("getDataFromFirebase"), name: "imageSent", object: nil)
//        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull To Refresh Conversations")
        refresher.addTarget(self, action: "getDataFromFirebase", forControlEvents: UIControlEvents.ValueChanged)
        refresher.tintColor = UIColor.clearColor()
        refresher.backgroundColor = UIColor.clearColor()
        self.contactsTable.addSubview(refresher)
        setUpUIRefresher()

//        contactsTable.delegate = self
//        contactsTable.dataSource = self as? UITableViewDataSource
//        imageSent = true
        print(2)
        // make an object for images recieved
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        print("adbajkdbasdbkabakjsdbjs")
        getDataFromFirebase()
    }

    func setUpUIRefresher() {
        let refreshViewBundle = NSBundle.mainBundle().loadNibNamed("refreshView", owner: self, options: nil)
        var refreshView = refreshViewBundle?.first as! UIView
        refreshView.frame = refresher.bounds
        refreshView.backgroundColor = UIColor.clearColor()

        UIView.animateWithDuration(1, delay: 0, options: [.Autoreverse, .CurveLinear, .Repeat], animations: {

            refreshView.backgroundColor = UIColor.cyanColor()
            }, completion: { (finished) in
            UIView.animateWithDuration(0.6, delay: 0, options: [.Autoreverse, .CurveLinear, .Repeat], animations: {
                refreshView.backgroundColor = UIColor.yellowColor()
                }, completion: nil)
        })
        self.refresher.addSubview(refreshView)
    }

    func getDataFromFirebase() {
        userNames = []
        userUIDS = []
        userImageFiles = []
        userHasFBLogin = []

        // search sent images for user uids
        // if uid is in sent
        // create image and add to array
        // else dont
        // maintain an array of recent contacts if you'd like to
        databaseRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                // print(snapshot)
                for conversation in snapshot.children {
                    if (conversation.key!.containsString(self.currUID)) {
                        if (conversation.hasChildren()) {
                            for sentImage in conversation.children {
                                print(sentImage)
                                if let imageViewed = sentImage.value?.objectForKey("imageViewed") as? Bool {
                                    print(imageViewed)
//                                    if (!imageViewed) {
                                    if let name = sentImage.value?.objectForKey("imageName") as? String {
                                        if let date = sentImage.value?.objectForKey("date") as? String {
                                            if let sender = sentImage.value?.objectForKey("senderID") as? String {
                                                if let reciever = sentImage.value?.objectForKey("receiverID") as? String {
                                                    if let senderName = sentImage.value?.objectForKey("senderName") as? String {
                                                        if let recieverName = sentImage.value?.objectForKey("receiverName") as? String {
                                                            let newImage = UserImageFile()
                                                            newImage.name = name
                                                            newImage.sentDate = date
                                                            newImage.senderID = sender
                                                            newImage.reciverID = reciever
                                                            newImage.senderName = senderName
                                                            newImage.reciverName = recieverName
                                                            newImage.imageRoot = sentImage.key!
                                                            newImage.imageViewed = imageViewed
                                                            if (imageViewed) {
                                                                newImage.setImage(UIImage(named: "emptyImage.png")!)
                                                            }
                                                            var removedCount = 0
                                                            for i in 0 ..< self.userImageFiles.count {
                                                                let index = i - removedCount
                                                                if (newImage.senderID == self.userImageFiles[index].senderID || newImage.senderID == self.userImageFiles[index].reciverID || newImage.reciverID == self.userImageFiles[index].senderID || newImage.reciverID == self.userImageFiles[index].reciverID) {
                                                                    if (self.userImageFiles[index].imageViewed) {
                                                                        self.userImageFiles.removeAtIndex(index)
                                                                        removedCount += 1
                                                                    }
                                                                }
                                                            }
                                                            self.userImageFiles.append(newImage)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            // let currect users name be stored in a seperatre array
//                                if let name = sentImage.value?.objectForKey("imageName") as? String {
//                                    if (!self.userNames.contains(name)) {
//                                        self.userNames.append(name)
//                                    } else {
//                                        self.userNames.insert(name, atIndex: 0)
//                                    }
//                                }

                        }
                    }

                }
                self.getImages()
            }
        })

    }

//    func sortContactData() {
//        for contactData in userImageFiles {
//            if
//        }
//    }

    func getImages() {
        var imagesGotten = 0
        if (userImageFiles.count > 0) {
            for userImage in userImageFiles {
                if (!userImage.imageViewed) {
                    let imageRef = storageRef.child("sentImages").child("\(userImage.senderID)&\(userImage.reciverID)").child(userImage.name)
                    let tempStorageDir = NSURL(fileURLWithPath: NSTemporaryDirectory())
                    let fileDir = tempStorageDir.URLByAppendingPathComponent("\(userImage.senderID)& \(userImage.reciverID)")?.URLByAppendingPathExtension("png")
                    imageRef.writeToFile(fileDir!, completion: { (url, error) in
                        if (error != nil) {
                            print(error?.localizedDescription)

                        } else {
                            let data = NSData(contentsOfURL: url!)
                            let image = UIImage(data: data!)
                            userImage.setImage(image!)
                            imagesGotten += 1

                        }
                        if (imagesGotten == self.userImageFiles.count) {
                            self.contactsTable.reloadData()
                            self.refresher.endRefreshing()
                        }
                    })
                } else {
                    self.contactsTable.reloadData()
                    self.refresher.endRefreshing()

                }
            }
        } else {
            self.contactsTable.reloadData()
            self.refresher.endRefreshing()
        }

    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userImageFiles.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        tableView.registerNib(UINib(nibName: "myCell", bundle: nil), forCellReuseIdentifier: "Cell")
        let cell: myCell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as! myCell
        if (currUID == userImageFiles[indexPath.row].senderID) {
            cell.userName.text = userImageFiles[indexPath.row].reciverName
        } else {
            cell.userName.text = userImageFiles[indexPath.row].senderName
        }
        if (currUID != userImageFiles[indexPath.row].reciverID) {
            if (userImageFiles[indexPath.row].imageViewed) {
                cell.imageReceivedNotifier.image = UIImage(named: "emptyImage.png")
            } else {
                cell.imageReceivedNotifier.image = UIImage(named: "unviewedImage.png")
            }
        }
//        print("getting cell")
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        // fix this replace reciver with sender
        if (currUID != userImageFiles[indexPath.row].senderID) {
            // show image

//
            let receivedImage = UIImageView(frame: CGRectMake(0, 0, 50, 50))
            receivedImage.frame.size
                .width = self.view.frame.width
            receivedImage.frame.size
                .height = self.view.frame.height
            receivedImage.tag = 22
            receivedImage.contentMode = UIViewContentMode.Redraw
            receivedImage.image = userImageFiles[indexPath.row].image
//            receivedImage.image = UIImage(named: "placeholder.png")
            self.view.addSubview(receivedImage)
            timer = NSTimer.scheduledTimerWithTimeInterval(10, target: self, selector: Selector("dismissRecievedImage"), userInfo: nil, repeats: false)
            receivedImage.userInteractionEnabled = true
            selectedIndex = indexPath.row
            let tapRecogniser = UITapGestureRecognizer(target: self, action: Selector("closeImage"))
            receivedImage.addGestureRecognizer(tapRecogniser)
//            self.view.userInteractionEnabled = false

//            selectedUsersName = userImageFiles[indexPath.row].sender
//            capturedImage = userImageFiles[indexPath.row].image
//            isReceviedImage = true
//            let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
//            let previewVC = mainStoryBoard.instantiateViewControllerWithIdentifier("imagePreview")
//            previewVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
//            self.presentViewController(previewVC, animated: true, completion: nil)

        } else {
            // error or do nothing
            if (userImageFiles[indexPath.row].imageViewed) {
                displayAlert("Alert!", message: "\(userImageFiles[indexPath.row].reciverName) has viewed your image yet.")

            } else {
                displayAlert("Alert!", message: "\(userImageFiles[indexPath.row].reciverName) has not viewed your image yet.")
            }
        }
    }

    func dismissRecievedImage() {
        timer.invalidate()
        self.view.userInteractionEnabled = true
        closeImage()

    }

    func closeImage() {
        for view in self.view.subviews {
            if (view.tag == 22) {
                view.removeFromSuperview()
                self.databaseRef.child("\(userImageFiles[selectedIndex].senderID)&\(userImageFiles[selectedIndex].reciverID)/\(userImageFiles[selectedIndex].imageRoot)").child("imageViewed").setValue(true)
            }
        }
        getDataFromFirebase()
    }

    @IBAction func showFriends(sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let previewVC = mainStoryBoard.instantiateViewControllerWithIdentifier("friendsView")
        previewVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(previewVC, animated: true, completion: nil)
    }
    @IBAction func showSettings(sender: AnyObject) {
        let mainStoryBoard = UIStoryboard(name: "Main", bundle: nil)
        let previewVC = mainStoryBoard.instantiateViewControllerWithIdentifier("friendsView")
        previewVC.modalPresentationStyle = UIModalPresentationStyle.OverFullScreen
        self.presentViewController(previewVC, animated: true, completion: nil)

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
