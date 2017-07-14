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

class LoginVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMsgLbl: UILabel!
    @IBOutlet weak var errMsgStackView: UIStackView!
    @IBOutlet weak var testImageView: UIImageView!
    
    var profile: Profile!
    var username: String!
    var gender: String!
    var coverPhotoUrl: String!
    var facebookProfileImg: UIImage!
    var handle: UInt!
    var userExist: Bool!
    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        
        emailTextField.text = ""
        passwordTextField.text = ""
        handle = UInt(0)
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "MainVC", sender: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
//        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
//            performSegue(withIdentifier: "MainVC", sender: nil)
//        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
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
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseSignIn(with: credential)
                
            }
        }
    }
    
    func firebaseSignIn(with credential: AuthCredential) {
        Auth.auth().signIn(with: credential, completion: { (user, error) in
            if let error =  error {
                print("Grandon(LoginVC): unable to authenticate with Firebase - \(error)")
            } else {
                print("Grandon(LoginVC): successfully authenticated with Firebase")
                if let user = user {
                    print("Grandon(LoginVC): userID is \(user.uid)")
                    let ref = DataService.ds.REF_USERS
                    ref.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDict = snapshot.value as? Dictionary<String, Any> {
                            print("Grandon(LoginVC): existing user snap is \(userDict)")
                            let userID = userDict["\(user.uid)"]
                            print("Grandon(DataService): username in profileDict is \(userID)")
                            if userID == nil {
                                let profileDict = ["gender": "", "userName": "", "profileImgUrl": "", "recentCompletionImgUrl": ""]
                                self.indicator.startAnimating()
                                self.newFBUserSignIn(id: user.uid, profileData: profileDict)
                            } else {
                                self.indicator.startAnimating()
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            }
        })
    }
    
    func completeSignIn(id: String) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        performSegue(withIdentifier: "MainVC", sender: nil)
    }
    
    func newFBUserSignIn(id: String, profileData: Dictionary<String, String>) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, profileData: profileData)
        self.indicator.stopAnimating()
        performSegue(withIdentifier: "MainVC", sender: nil)
    }

    @IBAction func newUserBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "NewUserVC", sender: sender)
    }
    
    @IBAction func forgetPwBtnTapped(_ sender: Any) {
        if let email = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
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
