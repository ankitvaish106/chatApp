//
//  newMassageTableViewController.swift
//  chatApp
//
//  Created by NTGMM-02 on 21/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import Firebase
class newMassageViewController: UITableViewController {
    
    var users = [User]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handlBack))
        fetchUser()
        tableView.register(massageCell.self, forCellReuseIdentifier: "massageCell")
    }
    func fetchUser(){
        Database.database().reference().child("users").observe(.childAdded, with: { (snapshot) in
            if let Dictionary = snapshot.value as? [String:AnyObject]{
                let user = User(name: Dictionary["name"] as! String, email: Dictionary["email"] as! String, profileImageUrl: Dictionary["profileImageUrl"] as! String)
                user.id = snapshot.key
                self.users.append(user)
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    @objc func handlBack(){
        self.dismiss(animated: true, completion: nil)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "massageCell", for: indexPath) as! massageCell
        let user = users[indexPath.row]
        cell.textLabel?.text = user.name
        cell.useremailLabel.text = user.email
       cell.profieImage.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl)
        return cell
    }
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    var massageController:ViewController?
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
      let user =   self.users[indexPath.row]
        dismiss(animated: true) {
            self.massageController?.handlechatMassages(user)
//            self.handlechatMassages(user)
        }
     
    }
    func handlechatMassages(_ user:User){
        let chatController = chatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        self.navigationController?.pushViewController(chatController, animated: true)
    }
}
class massageCell:UITableViewCell{
    
    override func layoutSubviews() {
        super.layoutSubviews()
        textLabel?.frame = CGRect(x: 64, y: 20, width: (textLabel?.frame.width)!, height: 20)
    }
    let profieImage:UIImageView = {
    let image = UIImageView()
        image.layer.cornerRadius = 24
        image.layer.masksToBounds = true
        image.contentMode = .scaleAspectFill
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
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
        addSubview(useremailLabel)
        useremailLabel.leftAnchor.constraint(equalTo: profieImage.rightAnchor,constant:8).isActive = true
        useremailLabel.topAnchor.constraint(equalTo: (textLabel?.bottomAnchor)!,constant:4).isActive = true
//        useremailLabel.widthAnchor.constraint(equalToConstant: 48).isActive = true
        useremailLabel.heightAnchor.constraint(equalToConstant: 15).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

