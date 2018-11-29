//
//  File.swift
//  chatApp
//
//  Created by NTGMM-02 on 21/06/18.
//  Copyright © 2018 NTGMM-02. All rights reserved.
//

import UIKit
import Firebase
extension LoginController:UIImagePickerControllerDelegate,UINavigationControllerDelegate{
   //handler for loginResistrations
    
    @objc func  handleprofileImage(){
        let uipicker = UIImagePickerController()
        uipicker.delegate = self
        uipicker.allowsEditing = true
        present(uipicker, animated: true, completion: nil)
    } 
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var selectedImageFromPicker:UIImage?
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage{
            selectedImageFromPicker = editedImage
        }else{
            if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage{
                selectedImageFromPicker = originalImage
            }
        }
        if selectedImageFromPicker != nil{
              profileImageView.image = selectedImageFromPicker
        }
      
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    func  handleRegister(){
        guard let email = emailTextField.text ,let password = passwordTextField.text ,let name = nameTextField.text else{print("invalid form");return}
        
        Auth.auth().createUser(withEmail: email, password: password, completion:{
            (user,error) in
            if error != nil{
                print(error!)
                return
            }
            guard let userId = user?.user.uid else {return}
            let imagename = NSUUID().uuidString
            let strorageRef = Storage.storage().reference().child("myImages").child("\(imagename).jpg")
            if let uploadCompressedData = UIImageJPEGRepresentation(self.profileImageView.image!, 0.1){
                strorageRef.putData(uploadCompressedData, metadata: nil, completion: { (metadata, error) in
                    if error != nil{
                        print(error as Any)
                        return
                    }
                    strorageRef.downloadURL(completion: { (url, error) in
                        if let imageUrl = url?.absoluteString {
                            let values = ["name": name, "email": email, "profileImageUrl": imageUrl]
                            
                            self.reisterUserIntoDataBaseWithUid(userId, values as [String : AnyObject])
                        }else{
                            print("unable to upload data")
                        }
                    })
                    
                })
            }
          
            
        })
        
    }
    fileprivate func reisterUserIntoDataBaseWithUid(_ uid:String,_ values:[String:AnyObject]){
        let ref = Database.database().reference()
        let childRefrence = ref.child("users").ref.child(uid)
        childRefrence.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil{
                print(err!)
            }
          self.mssagecontroller?.checkUserAndUploadTitle()
            self.dismiss(animated: true, completion: nil)
            
        })
    }
    func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("Form is not valid")
            return
        }
        
        Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
            
            if let error = error {
                print(error)
                return
            }
            self.mssagecontroller?.checkUserAndUploadTitle()
            self.dismiss(animated: true, completion: nil)
            
        })
    }
}

/////////////////////////////////////////////////////////////////////////////////



