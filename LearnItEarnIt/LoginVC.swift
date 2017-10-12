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

    
    var profile: Profile!
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func signInTapped(_ sender: Any) {
//        let forgetPwdAlert = UIAlertController(title: "Login Fail", message: "Forget your password? Select 'Forget Password? to reset your password'", preferredStyle: .alert)
//        
//        forgetPwdAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//        
//        let newLearnerAlert = UIAlertController(title: "Login Fail", message: "New Learner? Sign up to enjoy the jurney.", preferredStyle: .alert)
//        
//        newLearnerAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        if let email = emailTextField.text, let password = passwordTextField.text {
            KeychainWrapper.standard.set(email, forKey: CURRENT_EMAIL)
            currentEmail = KeychainWrapper.standard.string(forKey: CURRENT_EMAIL)
            KeychainWrapper.standard.set(password, forKey: CURRENT_PASSWORD)
            currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
            Auth.auth().signIn(withEmail: email, password: password, completion: { (user, error) in
                if error == nil {
//                    print("Grandon: successfully sign in!")
                    if let user = user {
                        self.completeSignIn(id: user.uid)
                    }
                } else {
//                    let errorAlert = UIAlertController(title: "Login Fail", message: "\(error?.localizedDescription)!", preferredStyle: .alert)
//                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                        self.present(errorAlert, animated: true, completion: nil)
                    print("Grandon: unable to sign in user - \(error)")
                    if error.debugDescription.contains("The password is invalid") {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "Forget your password? Select 'Forget Password?' to reset your password.", actionTitle: ["OK"])
//                        self.present(forgetPwdAlert, animated: true, completion: nil)
                    } else if error.debugDescription.contains("There is no user record") {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "The email address entered does not exist. Please enter your email address again.", actionTitle: ["OK"])
                    } else {
                        self.sendAlertWithoutHandler(alertTitle: "Login Fail", alertMessage: "New Learner? Sign up to enjoy the jurney.", actionTitle: ["OK"])
//                        self.present(newLearnerAlert, animated: true, completion: nil)
                    }
                }
            })
        }
    }
    
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        
        let facebookLogin = FBSDKLoginManager()
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                let loginAlert = UIAlertController(title: "Login Fail", message: "Unable to authenticate with Facebook - \(error)", preferredStyle: .alert)
                loginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(loginAlert, animated: true, completion: nil)
//                print("Grandon(LoginVC): unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                let cancelLoginAlert = UIAlertController(title: "Login Cancelled", message: "Cancelled Facebook authentication", preferredStyle: .alert)
                cancelLoginAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(cancelLoginAlert, animated: true, completion: nil)
//                print("Grandon(LoginVC): user cancelled Facebook authentication")
            } else {
                let credential = FacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseSignIn(with: credential)
//                self.performSegue(withIdentifier: "MainVC", sender: nil)
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
        DataService.ds.uid = KeychainWrapper.standard.string(forKey: KEY_UID)
        print("Grandon(LoginVC): the new uid is \(KeychainWrapper.standard.string(forKey: KEY_UID))")
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
                if error.debugDescription.contains("There is no user") {
                    print("Grandon: unable to send password reset email - \(error)")
                    let noUserAlert = UIAlertController(title: "Forget Password", message: "There is no user record corresponding to the email address. Please confirm your email address.", preferredStyle: .alert)
                    noUserAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(noUserAlert, animated: true, completion: nil)
                } else if error.debugDescription.contains("An internal error") {
                    let emptyEmailAlert = UIAlertController(title: "Forget Password", message: "Missing email address. Please enter your email address.", preferredStyle: .alert)
                    emptyEmailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emptyEmailAlert, animated: true, completion: nil)
                } else {
                    let emailSentAlert = UIAlertController(title: "Reset Email", message: "An email has been sent to the email address to reset your password.", preferredStyle: .alert)
                    emailSentAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(emailSentAlert, animated: true, completion: nil)
//                    print("Grandon: successfully sent a password reset email")
                }
            })
        }
        
    }
    
//    func sendAlertWithSingleOption(alertTitle: String, alertMessage: String, actionTitle: String) {
//        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
//        alert.addAction(UIAlertAction(title: actionTitle, style: .default, handler: nil))
//        self.present(alert, animated: true, completion: nil)
//    }
    
    func sendAlertWithoutHandler(alertTitle: String, alertMessage: String, actionTitle: [String]) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        for action in actionTitle {
            alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
