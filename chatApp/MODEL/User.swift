//
//  User.swift
//  chatApp
//
//  Created by NTGMM-02 on 21/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit

class User: NSObject {
    var id:String?
    var email:String
    var name:String
    var profileImageUrl:String
    init(name:String,email:String,profileImageUrl:String) {
        self.name = name
        self.email = email
        self.profileImageUrl = profileImageUrl
     
    }
}
class massages:NSObject{
    var timeStamp:NSNumber?
    var fromId:String?
    var toId:String?
    var text:String
    init(timeStamp:NSNumber,fromId:String,toId:String,text:String) {
        self.toId = toId
        self.fromId = fromId
        self.timeStamp = timeStamp
        self.text = text
    }
}
