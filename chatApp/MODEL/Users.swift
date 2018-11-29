//
//  User.swift
//  gameofchats
//
//  Created by Brian Voong on 6/29/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import  Firebase
class User: NSObject {
    var id: String?
    var name: String?
    var email: String?
    var profileImageUrl: String?
    var online:String?
    init(dictionary: [String: AnyObject]) {
        self.name = dictionary["name"] as? String
        self.email = dictionary["email"] as? String
        self.profileImageUrl = dictionary["profileImageUrl"] as? String
         self.online = dictionary["online"] as? String
    }
}

