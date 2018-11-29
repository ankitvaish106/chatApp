//
//  LoginController.swift
//  gameofchats
//
//  Created by Brian Voong on 6/24/16.
//  Copyright © 2016 letsbuildthatapp. All rights reserved.
//

import UIKit
import Firebase
import FBSDKLoginKit
import GoogleSignIn
class LoginController: UIViewController,GIDSignInUIDelegate,GIDSignInDelegate{
    
    var messagesController: MessagesController?
    var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    var nameTextFieldHeightAnchor: NSLayoutConstraint?
    var emailTextFieldHeightAnchor: NSLayoutConstraint?
    var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    lazy var loginRegisterButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        button.setTitle("Register", for: UIControlState())
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitleColor(UIColor.white, for: UIControlState())
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
     let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let nameSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    let emailSeparatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(r: 220, g: 220, b: 220)
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    }()
    
    let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    lazy var profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "dp")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action:#selector(handleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.white
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(r: 61, g: 91, b: 151)
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
        setupfacebookLoginButton()
        setupGoogleLoginButton()
    }
    
   
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
     //social login goes here
    lazy var facebookLoginButton:UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Continue With Facebook", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        loginButton.addTarget(self, action: #selector(handleCustomLogin), for: .touchUpInside)
        return loginButton
    }()
    @objc func handleCustomLogin(){
        FBSDKLoginManager().logIn(withReadPermissions: ["email","public_profile"], from: self) { (result, error) in
            if error != nil{
                print(error!)
                return
            }
            self.getUserDetail()
        }
    }
    func  getUserDetail(){
        let accessToken = FBSDKAccessToken.current()
        guard let tokenString = accessToken?.tokenString else {return}
        let credential = FacebookAuthProvider.credential(withAccessToken: (tokenString))
        Auth.auth().signInAndRetrieveData(with: credential) { (user, error) in
            if error != nil{
                print("something went wrong",error!)
                return
            }
            
            FBSDKGraphRequest(graphPath: "/me", parameters: ["fields":"id,name,email"]).start { (connection, result, err) in
                if err != nil{
                    print(err!)
                    return
                }
                
                if let dictionary = result as? [String:AnyObject]{
                    let name = dictionary["name"] as! String
                    let id = dictionary["id"] as! String
                    let email = dictionary["email"] as! String
                    let urlstring = "http://graph.facebook.com/\(id)/picture?type=large"
                      guard let userId = user?.user.uid else {return}
                    let values = ["name": name, "email": email, "profileImageUrl": urlstring,"online":""] as [String : Any]
                    self.registerUserIntoDatabaseWithUID(userId, values: values as [String : AnyObject])
                }
            }
            print("login sucsessfully with facebook with user",user!)
        }
     }
    
    //google login goes here
      lazy var googleLoginButton:UIButton = {
        let loginButton = UIButton(type: .system)
        loginButton.setTitle("Continue With Google", for: .normal)
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.titleLabel?.font = .boldSystemFont(ofSize: 16)
        loginButton.backgroundColor = UIColor(r: 80, g: 101, b: 161)
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        loginButton.translatesAutoresizingMaskIntoConstraints = false
        loginButton.addTarget(self, action: #selector(handleCustomLoginWithGoogle), for: .touchUpInside)
        return loginButton
      }()
    @objc func handleCustomLoginWithGoogle(){
        GIDSignIn.sharedInstance().signIn()
    }
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil{
            print("something went wrong with google signIn ",error!)
            return
        }
        guard let idToken = user.authentication.idToken else{return}
        guard let accessToken = user.authentication.accessToken else {return}
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: accessToken)
        Auth.auth().signInAndRetrieveData(with: credential) { (user1, error) in
            if error != nil{
                print("something went wrong with firebase connectivity ",error!)
            }
            guard let userId = user1?.user.uid else{return}
            if let userData = user1?.additionalUserInfo?.profile{
                let name = userData["name"] as! String
                let email = userData["email"] as! String
                let urlString = userData["picture"] as! String
                let values = ["name": name, "email": email, "profileImageUrl": urlString,"online":""] as [String : Any]
                self.registerUserIntoDatabaseWithUID(userId, values: values as [String : AnyObject])
            }
         }
    }
}

extension UIColor {
    
    convenience init(r: CGFloat, g: CGFloat, b: CGFloat) {
        self.init(red: r/255, green: g/255, blue: b/255, alpha: 1)
    }
    
}








