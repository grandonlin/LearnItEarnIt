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
    @IBOutlet weak var fullView: UIStackView!
    
    var userName: String!
    var password: String!
    var email: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUp), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDown), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }

    func keyboardUp(notification: Notification) {
        if passwordTextField.isEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.fullView.frame.origin.y -= keyboardSize.height - 70
            }
        }
    }
    
    func keyboardDown(notification: Notification) {
        if !passwordTextField.isEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
                self.fullView.frame.origin.y += keyboardSize.height - 70
            }
        }
        
    }
    
    @IBAction func createUserBtnTapped(_ sender: Any) {
        userName = usernameTextField.text
        password = passwordTextField.text
        email = emailTextField.text
        
         if userName != "" && password != "" && email != "" {
            KeychainWrapper.standard.set(userName, forKey: CURRENT_USERNAME)
            currentUsername = KeychainWrapper.standard.string(forKey: CURRENT_USERNAME)
            KeychainWrapper.standard.set(email, forKey: CURRENT_EMAIL)
            currentEmail = KeychainWrapper.standard.string(forKey: CURRENT_EMAIL)
            KeychainWrapper.standard.set(password, forKey: CURRENT_PASSWORD)
            currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    self.sendAlertWithoutHandler(alertTitle: "Error", alertMessage: error.localizedDescription, actionTitle: ["OK"])
                } else {
                    print("Grandon: successfully create a new user")
                    let defaultProfileImgUrl = "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/profile_pic%2FnewProfileImage?alt=media&token=6fc887bc-9833-4d60-925f-16bc73a0bad0"
                    let username = self.userName
                    let profileData = ["userName": username, "profileImgUrl": defaultProfileImgUrl, "gender": "", "recentCompletionImgUrl": "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/profile_pic%2FdefaultCompletionImage.jpg?alt=media&token=90f151a9-65c9-4b1b-b706-eaae1f6170a1"]
                    if let user = user {
                        print("User.uid is: \(user.uid)")
                        self.completeSignIn(id: user.uid, profileData: profileData as! Dictionary<String, String>)
                        Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in
                            if error == nil {
                                print("Grandon: sent email verification")
                            } else {
                                self.sendAlertWithoutHandler(alertTitle: "Not able to send email verification", alertMessage: (error?.localizedDescription)!, actionTitle: ["OK"])
                            }
                        })
                    }
                }
            })
         } else if userName == nil || userName == "" {
            self.sendAlertWithoutHandler(alertTitle: "Missing Username", alertMessage: "Please enter Username", actionTitle: ["OK"])
         } else if email == nil || email == "" {
            self.sendAlertWithoutHandler(alertTitle: "Missing Email Address", alertMessage: "Please enter email address", actionTitle: ["OK"])
         } else if password == nil || password == "" {
            self.sendAlertWithoutHandler(alertTitle: "Missing Password", alertMessage: "Please enter Password", actionTitle: ["OK"])
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
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func sendAlertWithoutHandler(alertTitle: String, alertMessage: String, actionTitle: [String]) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        for action in actionTitle {
            alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
