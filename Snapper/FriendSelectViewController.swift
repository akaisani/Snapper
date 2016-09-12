//
//  FriendSelectViewController.swift
//
//
//  Created by Abid Amirali on 8/9/16.
//
//

import UIKit
import Firebase

class FriendSelectViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var friendsTable: UITableView!
    let databaseRef = FIRDatabase.database().reference().child("users")
    let storageRef = FIRStorage.storage().referenceForURL("gs://snapper-6d1fe.appspot.com")
    let currUID = "\((FIRAuth.auth()?.currentUser?.uid)!)"
    var userEmails = [String]()
    var userUIDS = [String]()
    var userNames = [String]()
    var friendsString = String()
    var usersFriends = [String]()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        print("in here")
        databaseRef.observeSingleEventOfType(FIRDataEventType.Value, withBlock: { (snapshot) in
            if (snapshot.exists()) {
                for user in snapshot.children {
                    if (user.key! != self.currUID) {
                        if let name = user.value.objectForKey("name") as? String {
                            if let uid = user.value.objectForKey("uid") as? String {
                                if let email = user.value.objectForKey("email") as? String {
                                    self.userUIDS.append(uid)
                                    self.userNames.append(name)
                                    self.userEmails.append(email)
                                    if let friends = user.value.objectForKey("friends") as? String {
                                        self.usersFriends.append(friends)
                                    } else {
                                        self.usersFriends.append("")
                                    }
                                }
                            }
                        }
                    } else {
                        if let friends = user.value.objectForKey("friends") as? String {
                            self.friendsString = friends
                        }
                    }
                }
                print(snapshot.childrenCount)
                if (self.userUIDS.count == Int(snapshot.childrenCount - 1)) {
                    self.friendsTable.reloadData()
                }
            }
            print("down low")
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userUIDS.count
    }

    // Row display. Implementers should *always* try to reuse cells by setting each cell's reuseIdentifier and querying for available reusable cells with dequeueReusableCellWithIdentifier:
    // Cell gets various attributes set automatically based on table (separators) and data source (accessory views, editing controls)

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("friendCell", forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.text = userNames[indexPath.row]
        if (friendsString.containsString(userUIDS[indexPath.row])) {
            cell.accessoryType = UITableViewCellAccessoryType.Checkmark
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.None
        }
        return cell
    }

    func addFriend(friendUID: String, var otherUsersFriends: String) {
        friendsString += "\(friendUID),"
        otherUsersFriends += "\(currUID),"
        databaseRef.child(friendUID).child("friends").setValue(otherUsersFriends)

    }

    func removeFriend(friendUID: String, var otherUsersFriends: String) {
        var tempFriendsStore = friendsString.componentsSeparatedByString(",")
        tempFriendsStore.removeLast()
        friendsString = ""
        for friend in tempFriendsStore {
            if (friend != friendUID) {
                friendsString += "\(friend),"
            }
        }

        tempFriendsStore = otherUsersFriends.componentsSeparatedByString(",")
        tempFriendsStore.removeLast()
        otherUsersFriends = ""
        for friend in tempFriendsStore {
            if (friend != friendUID) {
                otherUsersFriends += "\(friend),"
            }
        }
        databaseRef.child(friendUID).child("friends").setValue(otherUsersFriends)
    }

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if (friendsString.containsString(userUIDS[indexPath.row])) {
            cell?.accessoryType = UITableViewCellAccessoryType.None
            removeFriend(userUIDS[indexPath.row], otherUsersFriends: usersFriends[indexPath.row])
        } else {
            cell?.accessoryType = UITableViewCellAccessoryType.Checkmark
            addFriend(userUIDS[indexPath.row], otherUsersFriends: usersFriends[indexPath.row])
        }
    }

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if (segue.identifier == "donePickingFriends") {
            let updatedData = [
                "friends": friendsString
            ]
            self.databaseRef.child(currUID).updateChildValues(updatedData)
        }
    }

}
