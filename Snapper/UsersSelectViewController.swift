//
//  UsersSelectViewController.swift
//  Snapper
//
//  Created by Abid Amirali on 8/9/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import UIKit
import Firebase

class UsersSelectViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var navBar: UINavigationBar!
    @IBOutlet weak var usersTable: UITableView!
    let databaseRef = FIRDatabase.database().reference().child("users")
    let storageRef = FIRStorage.storage().referenceForURL("gs://snapper-6d1fe.appspot.com")
    let currUID = "\((FIRAuth.auth()?.currentUser?.uid)!)"
    let currUserName = (FIRAuth.auth()?.currentUser?.displayName)!
    var otherUsersContacts = [String]()
    var currUsersContactList = ""
    var friendsString = ""
    var userNames = [String]()
    var userUIDS = [String]()
    var selectedUsers = [String]()
    var refresher: UIRefreshControl!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        refresher = UIRefreshControl()
        refresher.attributedTitle = NSAttributedString(string: "Pull To Refresh")
        refresher.addTarget(self, action: "getFriendsList", forControlEvents: UIControlEvents.ValueChanged)
        setUpUIRefresher()
        self.usersTable.addSubview(refresher)
    }

    func setUpUIRefresher() {
        let refreshViewBundle = NSBundle.mainBundle().loadNibNamed("refreshView", owner: self, options: nil)
        let refreshView = refreshViewBundle?.first as! UIView
        refreshView.frame = refresher.bounds
        refreshView.backgroundColor = UIColor.clearColor()

        UIView.animateWithDuration(0.4, delay: 0, options: [.Autoreverse, .CurveLinear, .Repeat], animations: {

            refreshView.backgroundColor = UIColor.greenColor()
            refreshView.backgroundColor = UIColor.blueColor()
            refreshView.backgroundColor = UIColor.yellowColor()
            }, completion: nil)
        self.refresher.addSubview(refreshView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        getFriendsList()
    }

    func getFriendsList() {
        databaseRef.child(currUID).observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                // check if you are using this
                if let friends = snapshot.value?.objectForKey("friends") as? String {
                    self.friendsString = friends
                }
                if let contacts = snapshot.value?.objectForKey("imagesFrom") as? String {
                    self.otherUsersContacts.append(contacts)
                } else {
                    self.otherUsersContacts.append("")
                }

                if let contacts = snapshot.value?.objectForKey("imagesSentTo") as? String {
                    self.currUsersContactList = contacts
                }
                // check the stuff above
            }
            // was calling the getFriendsData method, removed for temp fix for one person image sending
            if (self.friendsString.characters.count > 0) {
                self.getFriendsData()
            }

        })
    }

    func sortFriends() {
        let imagesDbRef = FIRDatabase.database().reference().child("sentImages")
        imagesDbRef.observeEventType(.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                if (snapshot.hasChildren()) {
                    for conversation in snapshot.children {
//                        print(conversation)
                        print(conversation.key!)
                        for image in conversation.children {
                            for user in self.userUIDS {
                                print(user)
                                print(image.key!)
                                if (conversation.key!.containsString("\(self.currUID)") && conversation.key!.containsString(user)) {
                                    if let imageViewed = image.value?.objectForKey("imageViewed") as? Bool {
                                        if (!imageViewed) {
                                            self.userUIDS.removeAtIndex(self.userUIDS.indexOf(user)!)
                                            let friendsArray = self.friendsString.componentsSeparatedByString(",")
                                            self.friendsString = ""
                                            for friend in friendsArray {
                                                if (friend != image.key!) {
                                                    self.friendsString += friend
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            self.refresher.endRefreshing()
            self.usersTable.reloadData()
        })
    }

    func getFriendsData() {
        databaseRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                for user in snapshot.children {
                    if (self.friendsString.containsString(user.key!)) {
                        if let name = user.value.objectForKey("name") as? String {
                            if let uid = user.value.objectForKey("uid") as? String {
                                self.userUIDS.append(uid)
                                self.userNames.append(name)
                                if let contacts = user.value.objectForKey("imagesFrom") as? String {
                                    self.otherUsersContacts.append(contacts)
                                } else {
                                    self.otherUsersContacts.append("")
                                }
                            }
                        }
                    }
                }
            }
            self.sortFriends()
        })
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userUIDS.count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("userCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = userNames[indexPath.row]
        return cell
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (selectedUsers.contains(userUIDS[indexPath.row])) {
            selectedUsers.removeAtIndex(selectedUsers.indexOf(userUIDS[indexPath.row])!)
            cell?.accessoryType = UITableViewCellAccessoryType.None
        } else {
            selectedUsers.append(userUIDS[indexPath.row])
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
        }
    }

    func displayAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .Default, handler: nil))
        self.presentViewController(alert, animated: true, completion: nil)

    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        var selectedString = ""
        if (segue.identifier == "doneSendingImages") {
            if (selectedUsers.count > 0) {
                for uid in selectedUsers {
                    // add contacted by other users and update it accordingly
                    let userImageFile = UIImagePNGRepresentation(capturedImage!)

                    let typeMetadata = FIRStorageMetadata()
                    let currentdate = NSDate()
                    let dateFormatter = NSDateFormatter()
                    dateFormatter.dateFormat = "dd,MM,yyyy,HH,mm,ss"
                    let formatedDate = dateFormatter.stringFromDate(currentdate)
                    let currChatBucket = storageRef.child("sentImages/\(currUID)&\(uid)").child(formatedDate)
                    let currDatabaseRef = FIRDatabase.database().reference().child("sentImages").child("\(currUID)&\(uid)")
                    typeMetadata.contentType = "image/png"
                    currChatBucket.putData(userImageFile!, metadata: typeMetadata, completion: { (metadata, error) in
                        if (error != nil) {
                            self.displayAlert("Error", message: (error?.localizedDescription)!)
                        } else {

                            // seperate object
                            // names
                            // date
                            // viewed or not
                            // file name

                            let imageName = (metadata?.name)!

                            let imageData = [
                                "senderID": self.currUID,
                                "senderName": self.currUserName,
                                "receiverID": uid,
                                "receiverName": self.userNames[self.userUIDS.indexOf(uid)!],
                                "imageName": imageName,
                                "imageViewed": false,
                                "date": formatedDate
                            ]

                            let index = self.selectedUsers.indexOf(uid)

                            var contactsString = self.otherUsersContacts[index!]
                            if (!contactsString.containsString(self.currUID)) {
                                contactsString += "\(self.currUID),"
                            } else {
                                let contactsArray = contactsString.componentsSeparatedByString(",")
                                contactsString = "\(self.currUID),"
                                for contact in contactsArray {
                                    if (contact != self.currUID) {
                                        contactsString += "\(contact),"
                                    }
                                }
                            }

                            currDatabaseRef.child("\(currentdate)").setValue(imageData)
                            let reciverData = [
                                "imagesFrom": contactsString,
                                "imageRecived": true

                            ]
                            self.databaseRef.child(uid).updateChildValues(reciverData as [NSObject: AnyObject])
                            selectedString += "\(uid),"

                            if (!self.currUsersContactList.containsString(uid)) {
                                self.currUsersContactList += "\(uid),"
                            } else {
                                let contactsArray = self.currUsersContactList.componentsSeparatedByString(",")
                                self.currUsersContactList = "\(uid),"
                                for contact in contactsArray {
                                    if (contact != uid) {
                                        self.currUsersContactList += "\(contact),"
                                    }
                                }
                            }

                            let senderData = [
                                "imagesSentTo": self.currUsersContactList
                            ]
                            self.databaseRef.child(self.currUID).updateChildValues(senderData)

//                            currDatabaseRef.child("\(currentdate)").observeEventType(FIRDataEventType.ChildChanged, withBlock: { (snapshot) in
//                                if (snapshot.exists()) {
//                                    if (snapshot.key! == "imageViewed") {
//                                        if let didViewImage = snapshot.value?.objectForKey("imageViewed") as? Bool {
//                                            if (didViewimage) {
//
//                                            }
//                                        }
//                                    }
//                                }
//                            })
                        }
                        NSNotificationCenter.defaultCenter().postNotificationName("imageSent", object: self)
                    })
                }
                // rec

            }
        }
    }

}
