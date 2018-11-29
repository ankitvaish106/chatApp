//
//  ViewController.swift
//  chatApp
//
//  Created by NTGMM-02 on 20/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import Firebase

class ViewController: UITableViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(handleLogout))
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "if_6_1173388"), style: .plain, target: self, action: #selector(handleNewMassages))
        checkUserIfLoggedIn()
        tableView.register(userCell.self, forCellReuseIdentifier: "cellId")
       observeValueForUser()
    }
    var messages = [massages]()
    var messageDictionary = [String:massages]()
    
    func observeValueForUser(){
        guard  let uid = Auth.auth().currentUser?.uid else {return}
        let ref = Database.database().reference().child("user-messages").child(uid)
        ref.observe(.value, with: { (snapshot) in
            let messageId = snapshot.key
            print(snapshot,messageId)
            let messageRefrence = Database.database().reference().child("massages").child(messageId)
            
            messageRefrence.observeSingleEvent(of: .value, with: { (snapshot1) in
                print(snapshot1.value)
                if let dictionary  = snapshot1.value as? [String:AnyObject]{
                    print(snapshot1)
                    let messages = massages(timeStamp: dictionary["timeStamp"] as! NSNumber, fromId: dictionary["fromId"] as!String, toId: dictionary["toId"] as! String
                        , text:dictionary["text"] as! String)
                    self.messages.append(messages)
                    if let toId = messages.toId{
                        self.messageDictionary[toId] = messages
                        self.messages  = Array(self.messageDictionary.values)
                        self.messages.sort(by: { (message1,message2 ) -> Bool in
                            return message1.timeStamp!.intValue > message2.timeStamp!.intValue
                        })
                    }
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                }
                
                
            }, withCancel: nil)
            
        }, withCancel: nil)
    }
    
    
    
    
    func observeMassages(){
        let ref = Database.database().reference().child("massages")
        ref.observe(.childAdded, with: { (snapshot) in
            if let dictionary  = snapshot.value as? [String:AnyObject]{
                let messages = massages(timeStamp: dictionary["timeStamp"] as! NSNumber, fromId: dictionary["fromId"] as!String, toId: dictionary["toId"] as! String
, text:dictionary["text"] as! String)
                self.messages.append(messages)
                if let toId = messages.toId{
                    self.messageDictionary[toId] = messages
                   self.messages  = Array(self.messageDictionary.values)
                    self.messages.sort(by: { (message1,message2 ) -> Bool in
                        return message1.timeStamp!.intValue > message2.timeStamp!.intValue
                    })
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
        
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath) as? userCell
        let massages = messages[indexPath.row]
        cell?.massages = massages
        return cell!
    }
    
    
    @objc func handleNewMassages(){
       let NewMassagesController = newMassageViewController()
        NewMassagesController.massageController = self
        let MassageViewController = UINavigationController(rootViewController:NewMassagesController)
        present(MassageViewController, animated: true, completion: nil)
    }
    
    func checkUserIfLoggedIn(){
        if Auth.auth().currentUser?.uid == nil{
            perform(#selector(handleLogout), with: nil, afterDelay: 0)
        }else{
            checkUserAndUploadTitle()
        }
    }
    
    func checkUserAndUploadTitle(){
        if  let udi = Auth.auth().currentUser?.uid{
            Database.database().reference().child("users").child(udi).observeSingleEvent(of: .value,with:{
                (snapshot) in
                if let dictionary = snapshot.value as? [String:AnyObject]{
                    let user = User(name: dictionary["name"] as! String, email: dictionary["email"] as! String, profileImageUrl: dictionary["profileImageUrl"] as! String)
                    self.setupNavBarWithUser(user)
                }
            })
        }
    }
    
//    func getmassages()->massages{
//        var massage:massages?
//        Database.database().reference().child("massages").observe(.childAdded, with: { (snapshot) in
//            if let dictionary  =   snapshot.value as? [String:AnyObject] {
//                let  massage1 = massages(timeStamp: dictionary["timeStamp"] as! NSNumber, fromId: dictionary["fromId"] as! String, toId: dictionary["toId"] as! String, text: )
//               massage = massage1
//            }
//        }, withCancel: nil)
//        return massage!
//    }
    
let titleView:UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        view.isUserInteractionEnabled = true
        return view
    }()
    
    
    
    func handlechatMassages(_ user:User){
      let chatController = chatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatController.user = user
        navigationController?.pushViewController(chatController, animated: true)
    }
    func setupNavBarWithUser(_ user: User) {
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let imageTiltle = UIImageView()
        imageTiltle.translatesAutoresizingMaskIntoConstraints = false
        imageTiltle.contentMode = .scaleAspectFill
        imageTiltle.layer.cornerRadius = 20
        imageTiltle.clipsToBounds = true
        imageTiltle.loadImageUsingCacheWithUrlString(urlString: user.profileImageUrl)
        
        containerView.addSubview(imageTiltle)
        
        //ios 9 constraint anchors
        //need x,y,width,height anchors
        imageTiltle.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        imageTiltle.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        imageTiltle.widthAnchor.constraint(equalToConstant: 40).isActive = true
        imageTiltle.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        let titleLabel = UILabel()
        
        containerView.addSubview(titleLabel)
        titleLabel.text = user.name
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        //need x,y,width,height anchors
        titleLabel.leftAnchor.constraint(equalTo: imageTiltle.rightAnchor, constant: 8).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: imageTiltle.centerYAnchor).isActive = true
        titleLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        titleLabel.heightAnchor.constraint(equalTo: imageTiltle.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView
        
    }
    
  
    
    @objc func  handleLogout(){
        do{
            try Auth.auth().signOut()
        }catch let error{
            print(error)
        }
        let loginController = LoginController()
        loginController.mssagecontroller = self
        present(loginController,animated:true,completion:nil)
    }
    
}

