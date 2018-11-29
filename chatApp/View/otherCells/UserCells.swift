//
//  UserCell.swift
//  gameofchats
//
//  Created by Brian Voong on 7/8/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase

class UserCell: UITableViewCell {
    
    var message: Message? {
        
        didSet {
            setupNameAndProfileImage()
            if let text = message{
          
                 detailTextLabel?.text = text.text
                ViewremoveFromSuperview()
                if message?.imageUrl != nil && message?.videoUrl == nil{
                    setupImageAndVedio()
                    smallimage.image = #imageLiteral(resourceName: "image").withRenderingMode(.alwaysOriginal)
                    messageText.text = "Image"
                }
                if message?.videoUrl != nil{
                    setupImageAndVedio()
                    smallimage.image = #imageLiteral(resourceName: "video").withRenderingMode(.alwaysOriginal)
                     messageText.text = "Video"
                }
            }
            if let seconds = message?.timestamp?.doubleValue {
                let timestampDate = Date(timeIntervalSince1970: seconds)
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd-MM-yyyy"
                let dateFormatter1 = DateFormatter()
                dateFormatter1.dateFormat = "hh:mm a"
                timeLabel.text = dateFormatter.string(from: timestampDate)
                SubtimeLabel.text = dateFormatter1.string(from: timestampDate)
            }
            
            
        }
    }
   func ViewremoveFromSuperview(){
    smallimage.removeFromSuperview()
    messageText.removeFromSuperview()
    }
    func setupImageAndVedio(){
        addSubview(smallimage)
    NSLayoutConstraint.activate([smallimage.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 15),smallimage.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),smallimage.heightAnchor.constraint(equalToConstant: 16),smallimage.widthAnchor.constraint(equalToConstant: 16)])
        addSubview(messageText)
        NSLayoutConstraint.activate([messageText.leftAnchor.constraint(equalTo: smallimage.rightAnchor, constant: 5),messageText.bottomAnchor.constraint(equalTo: profileImageView.bottomAnchor),messageText.heightAnchor.constraint(equalToConstant: 18)])
      }
    
    let smallimage:UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    let messageText:UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15)
        label.textColor = .gray
        label.translatesAutoresizingMaskIntoConstraints =  false
        return label
    }()
    
    fileprivate func setupNameAndProfileImage() {
        
        if let id = message?.chatPartnerId() {
            let ref = Database.database().reference().child("users").child(id)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                
                if let dictionary = snapshot.value as? [String: AnyObject] {
                    self.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileImageUrl = dictionary["profileImageUrl"] as? String {
                        self.profileImageView.loadImageUsingCacheWithUrlString(profileImageUrl)
                    }
                }
                
            }, withCancel: nil)
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: textLabel!.frame.origin.y - 2, width: textLabel!.frame.width, height: textLabel!.frame.height)
        
        detailTextLabel?.frame = CGRect(x: 64, y: detailTextLabel!.frame.origin.y + 2, width: detailTextLabel!.frame.width, height: detailTextLabel!.frame.height)
    }
    
    let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    let timeLabel: UILabel = {
        let label = UILabel()
        //        label.text = "HH:MM:SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    let SubtimeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        
        addSubview(profileImageView)
        addSubview(timeLabel)
        addSubview(SubtimeLabel)
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 48).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 48).isActive = true
        
        //need x,y,width,height anchors
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
        
        SubtimeLabel.centerXAnchor.constraint(equalTo: timeLabel.centerXAnchor).isActive = true
        SubtimeLabel.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 3).isActive = true
        SubtimeLabel.widthAnchor.constraint(equalToConstant: 80).isActive = true
        SubtimeLabel.heightAnchor.constraint(equalTo: textLabel!.heightAnchor).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

