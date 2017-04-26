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


class LoginVC: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!


    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    var currentAccessToken = FBSDKAccessToken.current()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if currentAccessToken != nil {
            performSegue(withIdentifier: "MainVC", sender: currentAccessToken)
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
                    FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                        if error == nil {
                            print("Grandon: successfully created a user")
                            if let user = user {
                                self.completeSignIn(id: user.uid)
                                FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                                    if error == nil {
                                        print("Grandon: sent email verification")
                                    } else {
                                        print("Grandon: unable to send email verification - \(error)")
                                    }
                                })
                            }
                        } else {
                            print("Grandon: unable to sign in - \(error)")
                        }
                    })
                }
            })
        }
    }
    
    
    @IBAction func facebookBtnTapped(_ sender: Any) {
        let facebookLogin = FBSDKLoginManager()
        
        facebookLogin.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            if error != nil {
                print("Grandon: unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Grandon: user cancelled Facebook authentication")
            } else {
                print("Grandon: successfully authenticate with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                self.firebaseSignIn(with: credential)
            }
        }
    }
    
    func firebaseSignIn(with credential: FIRAuthCredential) {
        FIRAuth.auth()?.signIn(with: credential, completion: { (user, error) in
            if let error =  error {
                print("Grandon: unable to authenticate with Firebase - \(error)")
            } else {
                print("Grandon: successfully authenticated with Firebase")
                if let user = user {
                    self.completeSignIn(id: user.uid)
                }
            }
        })
    }
    
    func completeSignIn(id: String) {
        
        performSegue(withIdentifier: "MainVC", sender: AnyObject.self)
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

    
//    FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (emailVerificationError) in
//    if emailVerificationError != nil {
//    print("Grandon: unable to send email verification")
//    } else {
//    print("Grandon: successfully sent email verification")
//    }
//    })

    
}
