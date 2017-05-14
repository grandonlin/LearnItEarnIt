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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
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
                print("Grandon: unable to authenticate with Facebook - \(error)")
            } else if result?.isCancelled == true {
                print("Grandon: user cancelled Facebook authentication")
            } else {
                print("Grandon: successfully authenticate with Facebook")
                let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
                FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "name,gender,picture"], tokenString: FBSDKAccessToken.current().tokenString, version: nil, httpMethod: nil).start(completionHandler: { (connection, result, error) in
                    if error != nil {
                        print("Grandon: error is \(error)")
                    } else {
                        if let resultDict = result as? Dictionary<String, Any> {
                            self.username = resultDict["name"] as? String
                            self.gender = resultDict["gender"] as? String
                            if let pictureDict = resultDict["picture"] as? Dictionary<String, Any> {
                                print("Grandon: pictureDict is \(pictureDict)")
                                if let data = pictureDict["data"] as? Dictionary<String, Any> {
                                    print("Grandon: data is \(data)")
                                    if let url = data["url"] as? String {
                                    print("Grandon: url is \(url)")
                                        let imageUrl = URL(string: url)!
                                        DispatchQueue.global(qos: .userInitiated).async {
                                            let imageData = NSData(contentsOf: imageUrl)
                                            DispatchQueue.main.sync {
                                                let img = UIImage(data: imageData as! Data)
                                                
                                                self.testImageView.image = img
                                                let profileImage = self.testImageView.image
                                                if let profileImageData = UIImageJPEGRepresentation(profileImage!, 1.0) {
                                                    print("Grandon: This is true")
                                                    let imgUid = NSUUID().uuidString
                                                    print("Grandon: imgUid is \(imgUid)")
                                                    let metadata = FIRStorageMetadata()
                                                    metadata.contentType = "image/jpeg"
                                                    print("Grandon: the metadata content type is \(metadata.contentType) ")
                                                    DataService.ds.STORAGE_PROFILE_IMAGE.child(imgUid).put(profileImageData, metadata: metadata) { (metadata, error) in
                                                        if error != nil {
                                                            print("Grandon: unable to upload image \(error)")
                                                        } else {
                                                            let uploadedImageUrl = metadata?.downloadURL()?.absoluteString
                                                            self.coverPhotoUrl = uploadedImageUrl
                                                            print(self.coverPhotoUrl)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                })
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
                    print("Grandon: userID is \(user.uid)")
                    if DataService.ds.existingUserDetermined(uid: user.uid) == true {
                        print("Grandon: true")
                        self.completeSignIn(id: user.uid)
                    } else {
                        print("Grandon: false")
                        let profileDict = ["gender": self.gender, "userName": self.username, "profileImgUrl": self.coverPhotoUrl, "recentCompletionImgUrl": ""]
                        print("Grandon: the coverphotoUrl is \(self.coverPhotoUrl)")
                        self.newFBUserSignIn(id: user.uid, profileData: profileDict as! Dictionary<String, String>)
                        
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
