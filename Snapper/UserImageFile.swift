//
//  UserImageFile.swift
//  Snapper
//
//  Created by Abid Amirali on 8/13/16.
//  Copyright © 2016 Abid Amirali. All rights reserved.
//

import Foundation
import UIKit

class UserImageFile {
    var name = String()
    var image = UIImage()
    var sentDate = String()
    var senderID = String()
    var reciverID = String()
    var imageURL = NSURL()
    var senderName = String()
    var reciverName = String()
    var imageRoot = String()
    var imageViewed = Bool()
    
    func setImage(inputImage: UIImage) {
        image = inputImage
    }
}