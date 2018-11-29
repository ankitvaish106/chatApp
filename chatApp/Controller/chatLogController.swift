//
//  chatLogController.swift
//  chatApp
//
//  Created by NTGMM-02 on 25/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import Firebase
class chatLogController:UICollectionViewController,UITextFieldDelegate{
    
    
    var user:User?{
        didSet{
            navigationItem.title = user?.name
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
      
        collectionView?.backgroundColor = .white
        setupBottomView()
    }
   func  setupBottomView(){
    view.addSubview(containerView)
    containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
    containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
    containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
    containerView.addSubview(sendButton)
    sendButton.rightAnchor.constraint(equalTo:containerView.rightAnchor).isActive = true
    sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
    sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    containerView.addSubview(inputTextField)
    //x,y,w,h
    inputTextField.leftAnchor.constraint(equalTo: containerView.leftAnchor, constant: 8).isActive = true
    inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
    inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
    inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
    
    let separatorLineView = UIView()
    separatorLineView.backgroundColor = UIColor(r: 220, g: 220, b: 220)
    separatorLineView.translatesAutoresizingMaskIntoConstraints = false
    containerView.addSubview(separatorLineView)
    //x,y,w,h
    separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
    separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
    separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
    separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    let containerView:UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
   lazy var inputTextField:UITextField = {
        let view = UITextField()
        view.placeholder = "Enter massage"
        view.delegate = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let sendButton:UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send", for: .normal)
        button.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    @objc func  handleSend(){
    let ref = Database.database().reference().child("massages")
        let idref = ref.childByAutoId()
        let toId = user!.id!
        let fromId = Auth.auth().currentUser!.uid
        let timeStamp = NSDate().timeIntervalSince1970
        let values = ["text":inputTextField.text!,"toId":toId,"fromId":fromId,"timeStamp":timeStamp] as [String : Any]
//        idref.updateChildValues(values)
        
        idref.updateChildValues(values) { (error, ref) in
            if error != nil{
                print(error)
                return
            }
            let usermessagesRef = Database.database().reference().child("user-messages").child(fromId)
            let messagesId = idref.key
            usermessagesRef.updateChildValues([messagesId:1])
            
            
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        handleSend()
        return true
    }
    
    
}
