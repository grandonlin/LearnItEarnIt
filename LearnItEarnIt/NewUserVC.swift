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
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var userName: String!
    var password: String!
    var email: String!
//    var loadingView: LoadingView!
    
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
            createKeychains(username: userName, email: email, password: password)
//            loadingView = LoadingView(uiView: view)
            activityIndicator.startAnimating()
            Auth.auth().createUser(withEmail: email, password: password, completion: { (user, error) in
                if let error = error {
                    self.sendAlertWithoutHandler(alertTitle: "Error", alertMessage: error.localizedDescription, actionTitle: ["OK"])
                } else {
                    print("Grandon: successfully create a new user")
                    let defaultProfileImgUrl = DEFAULT_PROFILE_IMG_URL
                    let username = self.userName
                    let profileData = ["userName": username, "profileImgUrl": defaultProfileImgUrl, "gender": "", "recentCompletionImgUrl": RECENT_COMPLETION_IMG_URL]
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
    
    func createKeychains(username: String, email: String, password: String) {
        KeychainWrapper.standard.set(userName, forKey: CURRENT_USERNAME)
        currentUsername = KeychainWrapper.standard.string(forKey: CURRENT_USERNAME)
        KeychainWrapper.standard.set(email, forKey: CURRENT_EMAIL)
        currentEmail = KeychainWrapper.standard.string(forKey: CURRENT_EMAIL)
        KeychainWrapper.standard.set(password, forKey: CURRENT_PASSWORD)
        currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
    }
    
    func completeSignIn(id: String, profileData: Dictionary<String, String>) {
        KeychainWrapper.standard.set(id, forKey: KEY_UID)
        DataService.ds.createFirebaseDBUser(uid: id, profileData: profileData)
//        loadingView.hide()
        activityIndicator.stopAnimating()
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
}
