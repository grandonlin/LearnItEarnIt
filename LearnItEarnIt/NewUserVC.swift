//
//  NewUserVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-28.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class NewUserVC: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorMsgStackView: UIStackView!
    @IBOutlet weak var errMsgLbl: UILabel!
    
    var userName: String!
    var password: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self

    }

    @IBAction func createUserBtnTapped(_ sender: Any) {
        userName = usernameTextField.text
        password = passwordTextField.text
        email = emailTextField.text
        
         if userName != "" && password != "" && email != "" {
            FIRAuth.auth()?.createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    print("Grandon: \(error)")
                    self.showErrorView()
                    self.errMsgLbl.text = error.localizedDescription
                } else {
                    print("Grandon: successfully create a new user")
                    let defaultProfileImgUrl = "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/profile_pic%2FnewProfileImage?alt=media&token=6fc887bc-9833-4d60-925f-16bc73a0bad0"
                    let username = self.userName
                    let profileData = ["userName": username, "profileImgUrl": defaultProfileImgUrl, "gender": "", "recentCompletionImgUrl": "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/profile_pic%2FdefaultCompletionImage.jpg?alt=media&token=90f151a9-65c9-4b1b-b706-eaae1f6170a1"]
                    if let user = user {
                        print("User.uid is: \(user.uid)")
                        self.completeSignIn(id: user.uid, profileData: profileData as! Dictionary<String, String>)
                        FIRAuth.auth()?.currentUser?.sendEmailVerification(completion: { (error) in
                            if error == nil {
                                print("Grandon: sent email verification")
                            } else {
                                print("Grandon: unable to send email verification - \(error)")
                            }
                        })
                    }
                }
            })
         } else if userName == nil || userName == "" {
            self.showErrorView()
            errMsgLbl.text = "Please enter Username"
         } else if email == nil || email == "" {
            self.showErrorView()
            errMsgLbl.text = "Please enter Email Address"
         } else if password == nil || password == "" {
            self.showErrorView()
            errMsgLbl.text = "Please enter Password"
        }
    }
    
    
    @IBAction func cancelBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    func completeSignIn(id: String, profileData: Dictionary<String, String>) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, profileData: profileData)
        performSegue(withIdentifier: "SetupVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SetupVC {
            if let username = self.usernameTextField.text {
                destination.userName = username
                destination.newProfileSetup = true
                
            }
        }
    }

    @IBAction func errorCancelBtnTapped(_ sender: Any) {
        self.errorView.isHidden = true
        self.errorMsgStackView.isHidden = true
    }

    func showErrorView() {
        errorView.isHidden = false
        errorMsgStackView.isHidden = false
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
