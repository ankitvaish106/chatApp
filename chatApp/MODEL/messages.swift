//
//  messages.swift
//  chatApp
//
//  Created by NTGMM-02 on 10/07/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import Firebase
class Message: NSObject {
    var fromId: String?
    var text: String?
    var timestamp: NSNumber?
    var toId: String?
    var imageUrl:String?
    var image_height:NSNumber?
    var image_width:NSNumber?
    var videoUrl:String?
    var deleteId:String?
    init(dictionary: [String: Any]) {
        self.fromId = dictionary["fromId"] as? String
        self.text = dictionary["text"] as? String
        self.toId = dictionary["toId"] as? String
        self.timestamp = dictionary["timestamp"] as? NSNumber
        self.imageUrl = dictionary["messages-images"] as? String
        self.image_height = dictionary["image-height"] as? NSNumber
        self.image_width = dictionary["image-width"] as? NSNumber
        self.videoUrl = dictionary["videoUrl"] as? String
        self.deleteId = dictionary["deleteId"] as? String
    }
    func chatPartnerId()->String{
        return (fromId! == Auth.auth().currentUser!.uid ? toId :fromId)!
    }
}
