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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

//    var loadingView: LoadingView!
    var profile: Profile!
    var gender: String!
    var coverPhotoUrl: String!
    var facebookProfileImg: UIImage!
    var handle: UInt!
    var userExist: Bool!
//    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.text = ""
        passwordTextField.text = ""
        handle = UInt(0)
        
//        loadingView = LoadingView(uiView: view)
//        loadingView.hide()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if let _ = KeychainWrapper.standard.string(forKey: KEY_UID) {
            performSegue(withIdentifier: "MainVC", sender: nil)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signInTapped(_ sender: Any) {
        self.activityIndicator.startAnimating()
        if let email = emailTextField.text, let password = passwordTextField.text {
            assignKeychainWrapperValueForEmailAndPassword(email: email, password: password);            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
//                    self.loadingView.show()
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
                    self.activityIndicator.stopAnimating()
                    print("Grandon: unable to sign in user - \(error)")
//                    self.loadingView.hide()
                    if error.debugDescription.contains("The password is invalid") {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "Forget your password? Select 'Forget Password?' to reset your password.", actionTitle: ["OK"])
                    } else if error.debugDescription.contains("There is no user record") {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "The email address entered does not exist. Please enter your email address again.", actionTitle: ["OK"])
                    } else {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "New Learner? Sign up to enjoy the jurney.", actionTitle: ["OK"])
                    }
                }
            })
        }
    }
    
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "Unable to authenticate with Facebook - \(error)", actionTitle: ["OK"])
            } else if result?.isCancelled == true {
                self.sendAlertWithoutHandler(alertTitle: "Login Cancelled", alertMessage: "Cancelled Facebook authentication", actionTitle: ["OK"])
            } else {
                self.activityIndicator.startAnimating()
//                self.loadingView.show()
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
                self.activityIndicator.startAnimating()
                if let user = user {
                    userRef.observeSingleEvent(of: .value, with: { (snapshot) in
                        if let userDict = snapshot.value as? Dictionary<String, Any> {
                            let userID = userDict["\(user.uid)"]
                            if userID == nil {
                                let profileDict = ["gender": "", "userName": "", "profileImgUrl": "", "recentCompletionImgUrl": ""]
                                self.newFBUserSignIn(id: user.uid, profileData: profileDict)
                            } else {
                                self.completeSignIn(id: user.uid)
                            }
                        }
                    })
                }
            }
        })
    }
    
    func assignKeychainWrapperValueForEmailAndPassword(email: String, password: String) {
        KeychainWrapper.standard.set(email, forKey: CURRENT_EMAIL)
        currentEmail = KeychainWrapper.standard.string(forKey: CURRENT_EMAIL)
        KeychainWrapper.standard.set(password, forKey: CURRENT_PASSWORD)
        currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
    }
    
    func completeSignIn(id: String) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        activityIndicator.stopAnimating()
//        loadingView.hide()
        performSegue(withIdentifier: "MainVC", sender: nil)
    }
    
    func newFBUserSignIn(id: String, profileData: Dictionary<String, String>) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, profileData: profileData)
        activityIndicator.stopAnimating()
//        loadingView.hide()
        performSegue(withIdentifier: "MainVC", sender: nil)
    }

    @IBAction func newUserBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "NewUserVC", sender: sender)
    }
    
    @IBAction func forgetPwBtnTapped(_ sender: Any) {
        if let email = emailTextField.text {
            Auth.auth().sendPasswordReset(withEmail: email, completion: { (error) in
                if error.debugDescription.contains("There is no user") {
                    self.sendAlertWithoutHandler(alertTitle: "Forget Password", alertMessage: "There is no user record corresponding to the email address. Please confirm your email address.", actionTitle: ["Cancel"])
                } else if error.debugDescription.contains("An internal error") {
                    self.sendAlertWithoutHandler(alertTitle: "Forget Password", alertMessage: "Missing email address. Please enter your email address.", actionTitle: ["OK"])
                } else {
                    self.sendAlertWithoutHandler(alertTitle: "Reset Email", alertMessage: "An email has been sent to the email address to reset your password.", actionTitle: ["OK"])
                }
            })
        }
        
    }
    
}
