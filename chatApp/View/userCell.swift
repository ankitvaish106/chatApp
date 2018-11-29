//
//  userCell.swift
//  chatApp
//
//  Created by NTGMM-02 on 25/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import  Firebase
class userCell:UITableViewCell{
    
    var massages:massages?{
        didSet{
             let toId = massages?.toId
           let ref =  Database.database().reference().child("users").child(toId!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if  let dictionary =  snapshot.value as? [String:AnyObject]{
                    self.usernameLabel.text = dictionary["name"] as? String
                    self.profieImage.loadImageUsingCacheWithUrlString(urlString: dictionary["profileImageUrl"] as! String)
                    self.useremailLabel.text = self.massages?.text
                }
                
                
                
            }, withCancel: nil)
            if let seconds = massages?.timeStamp?.doubleValue{
                let timestampDate = NSDate(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "hh:mm a"
                dateLabel.text = dateFormatter.string(from: timestampDate as Date)
            }
            
            
        }
    }

    
    let usernameLabel:UILabel = {
        let name  = UILabel()
        name.translatesAutoresizingMaskIntoConstraints = false
        name.font = .systemFont(ofSize: 16)
        return name
        
    }()
    let profieImage:UIImageView = {
        let image = UIImageView()
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let dateLabel:UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "hhhhhr"
        label.font = .systemFont(ofSize: 13)
        label.textColor = .gray
        return label
    }()
    
    let useremailLabel:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 13)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        addSubview(profieImage)
        profieImage.leftAnchor.constraint(equalTo: self.leftAnchor,constant:8).isActive = true
        profieImage.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profieImage.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profieImage.heightAnchor.constraint(equalToConstant: 48).isActive = true
        addSubview(dateLabel)
        dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor,constant:8).isActive = true
        dateLabel.topAnchor.constraint(equalTo: self.topAnchor,constant:18).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        dateLabel.heightAnchor.constraint(equalToConstant: 22).isActive = true
        addSubview(usernameLabel)
        usernameLabel.leftAnchor.constraint(equalTo: profieImage.rightAnchor,constant:8).isActive = true
        usernameLabel.topAnchor.constraint(equalTo: profieImage.topAnchor,constant:8).isActive = true
        usernameLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        addSubview(useremailLabel)
        useremailLabel.leftAnchor.constraint(equalTo: profieImage.rightAnchor,constant:8).isActive = true
        useremailLabel.topAnchor.constraint(equalTo: (usernameLabel.bottomAnchor),constant:4).isActive = true
        useremailLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
