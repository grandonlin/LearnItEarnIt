//
//  LoginVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-24.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMsgLbl: UILabel!
    @IBOutlet weak var errMsgStackView: UIStackView!
    @IBOutlet weak var testImageView: UIImageView!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var profile: Profile!
    var username: String!
    var gender: String!
    var coverPhotoUrl: String!
    var facebookProfileImg: UIImage!
    var ref: FIRDatabaseReference!
    var handle: UInt!
    var userExist: Bool!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       handle = UInt(0)
        
        
    }
    

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "MainVC", sender: nil)
        }
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            FIRAuth.auth()?.signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
                    print("Grandon: successfully sign in!")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    print("Grandon: unable to sign in user - \(error)")
                    self.showErrorView()
                    if user?.isEmailVerified == true {
                        self.errorMsgLbl.text = "Forgot your password? Select 'Forget Password?'"
                    } else {
                        self.errorMsgLbl.text = "New learner? Sign up to enjoy the jurney."
                    }
                }
            })
        }
    }
    
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Grandon(LoginVC): unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Grandon(LoginVC): user cancelled Facebook authentication")
            } else {
                print("Grandon(LoginVC): successfully authenticate with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseSignIn(with: credential)
            }
        }
    }
    
    func firebaseSignIn(with credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error =  error {
                print("Grandon(LoginVC): unable to authenticate with Firebase - \(error)")
            } else {
                print("Grandon(LoginVC): successfully authenticated with Firebase")
                if let user = user {
                    print("Grandon(LoginVC): userID is \(user.uid)")
                    
                    self.ref = DataService.ds.REF_USERS.child(user.uid).child("profile")
                    if DataService.ds.existingUserDetermined(profileKey: user.uid, ref: self.ref) == true {
                        print("Grandon(LoginVC): true")
                        self.completeSignIn(id: user.uid)
                    } else {
                        print("Grandon(LoginVC): false")
                        let profileDict = ["gender": "", "userName": "", "profileImgUrl": "", "recentCompletionImgUrl": ""]
                        self.newFBUserSignIn(id: user.uid, profileData: profileDict)
                        
                    }
                }
            }
        })
    }
    
    func completeSignIn(id: String) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "MainVC", sender: AnyObject.self)
    }
    
    func newFBUserSignIn(id: String, profileData: Dictionary<String, String>) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, profileData: profileData)
        performSegue(withIdentifier: "MainVC", sender: nil)
    }

    @IBAction func newUserBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "NewUserVC", sender: sender)
    }
    
    @IBAction func forgetPwBtnTapped(_ sender: Any) {
        if let email = emailTextField.text {
            FIRAuth.auth()?.sendPasswordReset(withEmail: email, completion: { (error) in
                if error != nil {
                    print("Grandon: unable to send password reset email - \(error)")
                } else {
                    print("Grandon: successfully sent a password reset email")
                }
            })
        }
        
    }
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        self.errorView.isHidden = true
        self.errMsgStackView.isHidden = true
    }
    
    func showErrorView() {
        errorView.isHidden = false
        errMsgStackView.isHidden = false
    }
    
    
}
