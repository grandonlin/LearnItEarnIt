//
//  DetailSettingVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-09.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class DetailSettingVC: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var imageBtn: UIButton!
    @IBOutlet weak var pwResetView: UIView!
    @IBOutlet weak var currentPwTextField: UITextField!
    @IBOutlet weak var newPwTextField: UITextField!
    @IBOutlet weak var confPwTextField: UITextField!
    @IBOutlet weak var saveBtn: UIButton!
    @IBOutlet weak var authLbl: UILabel!
    @IBOutlet weak var authBtn: CircleButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var detailSettingTitle: String!
    var imagePicker: UIImagePickerController!
    var genders = ["Male", "Female"]
    var gender: String = "Male"
    let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
    let profileRef = DataService.ds.REF_USERS_CURRENT.child("profile")
    var existNames : [String]!
    var usernameChanged: Bool! = false
    var currentPw: String!
    var newPw: String!
    var confPw: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        nameTextField.delegate = self
        genderPickerView.delegate = self
        genderPickerView.dataSource = self
        currentPwTextField.delegate = self
        newPwTextField.delegate = self
        confPwTextField.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        
        authBtn.circleHeight()
        
        titleLbl.text = detailSettingTitle
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUP), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
//        
//        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDOWN), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        existNames = [String]()
        
        loadScreen()
    }
    
    func loadScreen() {
        if titleLbl.text == "Profile Image" {
            profileImageView.isHidden = false
            imageBtn.isHidden = false
            let profileImgRef = profileRef.child("profileImgUrl")
            profileImgRef.observe(.value, with: { (snapshot) in
                if let url = snapshot.value as? String {
                    let profileRef = Storage.storage().reference(forURL: url)
                    profileRef.getData(maxSize: 1024 * 1024, completion: { (data, error) in
                        if error != nil {
                            print("Grandon(ProfileVC): the error is \(error)")
                        } else {
                            if let img = UIImage(data: data!) {
                                self.profileImageView.image = img
                            }
                        }
                    })
                }
            })
        } else if titleLbl.text == "Name" {
            nameTextField.isHidden = false
            currentUsername = KeychainWrapper.standard.string(forKey: CURRENT_USERNAME)
            let profileNameRef = profileRef.child("userName")
            profileNameRef.observe(.value, with: { (snapshot) in
                if let username = snapshot.value as? String {
                    self.nameTextField.text = username
                }
            })
        } else if titleLbl.text == "Gender" {
            genderPickerView.isHidden = false
            let profileGenderRef = profileRef.child("gender")
            profileGenderRef.observe(.value, with: { (snapshot) in
                if let profileGender = snapshot.value as? String {
                    if profileGender == "" || profileGender == "Male"{
                        self.genderPickerView.selectRow(0, inComponent: 0, animated: true)
                    } else {
                        self.genderPickerView.selectRow(1, inComponent: 0, animated: true)
                    }
                }
            })
        } else if titleLbl.text == "Password" {
            pwResetView.isHidden = false
            saveBtn.isHidden = false
            saveBtn.alpha = 0.4
            saveBtn.isUserInteractionEnabled = false
            currentPw = currentPwTextField.text
            newPw = newPwTextField.text
            confPw = confPwTextField.text
            currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
            currentEmail = KeychainWrapper.standard.string(forKey: CURRENT_EMAIL)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if titleLbl.text == "Name" {
            if nameTextField.text != currentUsername {
                usernameChanged = true
            } else {
                usernameChanged = false
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if nameTextField.isHidden == false {
            nameTextField.resignFirstResponder()
        } else if pwResetView.isHidden == false {
            if currentPwTextField.isEditing {
                currentPwTextField.resignFirstResponder()
            } else if newPwTextField.isEditing {
                newPwTextField.resignFirstResponder()
            } else if confPwTextField.isEditing {
                confPwTextField.resignFirstResponder()
            }
        }
        return true
    }
    
//    func keyboardUP(notification: Notification) {
//        if confPwTextField.isEditing {
//            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                self.view.frame.origin.y -= keyboardSize.height
//            }
//        }
//        
//    }
//    
//    func keyboardDOWN(notification: Notification) {
//        if confPwTextField.isEditing {
//            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                self.view.frame.origin.y += keyboardSize.height
//            }
//        }
//        
//    }
    

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    @IBAction func imageBtnTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        activityIndicator.startAnimating()
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = selectedImage
            if let imageData = UIImageJPEGRepresentation(selectedImage, 0.5) {
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.STORAGE_PROFILE_IMAGE.child(self.profileKey).child("profile Image").putData(imageData, metadata: metadata) { (metadata, error) in
                    if error != nil {
                        print("Grandon(DetailSettingVC): unable to upload picture - \(error?.localizedDescription)")
                    } else {
                        let profileImageUrl = metadata?.downloadURL()?.absoluteString
                        DataService.ds.REF_USERS.child(self.profileKey).child("profile").child("profileImgUrl").setValue(profileImageUrl)
                    }
                }
            }
        }
        activityIndicator.stopAnimating()
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func authBtnPressed(_ sender: Any) {
        currentPw = currentPwTextField.text
        print("Grandon(DetailSettingVC): the email is \(currentEmail), the password is \(currentPassword)")
        let credential = EmailAuthProvider.credential(withEmail: currentEmail, password: currentPw)
        let user = Auth.auth().currentUser
        user?.reauthenticate(with: credential, completion: { (error) in
            if let error = error {
                self.sendAlertWithoutHandler(alertTitle: "Error", alertMessage: "\(error.localizedDescription)", actionTitle: ["Cancel"])
            } else {
                self.authLbl.text = "Successfully Authenticate"
                self.saveBtn.alpha = 1
                self.saveBtn.isUserInteractionEnabled = true
                self.newPwTextField.isUserInteractionEnabled = true
                self.confPwTextField.isUserInteractionEnabled = true
            }
        })
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if genderPickerView.isHidden == false {
            let genderPicked = genderPickerView.selectedRow(inComponent: 0)
            if genderPicked == 0 {
                DataService.ds.REF_USERS_CURRENT.child("profile").child("gender").setValue("Male")
                self.dismiss(animated: true, completion: nil)
            } else {
                DataService.ds.REF_USERS_CURRENT.child("profile").child("gender").setValue("Female")
                self.dismiss(animated: true, completion: nil)
            }
        } else if nameTextField.isHidden == false {
            if nameTextField.text != currentUsername {
                usernameChanged = true
            } else {
                usernameChanged = false
            }
            
            if nameTextField.text == "" {
                    let emptyUsernameAlert = UIAlertController(title: "Missing Username", message: "Please make sure your username is entered", preferredStyle: .alert)
                    emptyUsernameAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                    self.present(emptyUsernameAlert, animated: true, completion: nil)
            } else if usernameChanged == true {
                self.existNames.removeAll()
                DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
                    if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                        for snap in snapshot {
                            if let userSnap = snap.value as? Dictionary<String, Any> {
                                if let profileSnap = userSnap["profile"] as? Dictionary<String, Any> {
                                    if let userName = profileSnap["userName"] as? String {
                                        print("Grandon: username is \(userName)")
                                        if let username = self.nameTextField.text {
                                            if userName == username {
                                                self.existNames.append(userName)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                        print("Grandon: the existNames array has \(self.existNames.count) records")
                        if self.existNames.count >= 1 {
                            let dupUsernameAlert = UIAlertController(title: "Username Exists", message: "This username has been used, please use another.", preferredStyle: .alert)
                            dupUsernameAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                            self.present(dupUsernameAlert, animated: true, completion: nil)
                        } else {
                            DataService.ds.REF_USERS_CURRENT.child("profile").child("userName").setValue(self.nameTextField.text)
                            KeychainWrapper.standard.set(self.nameTextField.text!, forKey: CURRENT_USERNAME)
                            currentUsername = KeychainWrapper.standard.string(forKey: CURRENT_USERNAME)
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                })
            } else {
                dismiss(animated: true, completion: nil)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        activityIndicator.startAnimating()
        if let currentPw = currentPwTextField.text, let newPw = newPwTextField.text, let confPw = confPwTextField.text {
            if newPw != confPw {
                sendAlertWithoutHandler(alertTitle: "Password Reset Fails", alertMessage: "Passwords not matched", actionTitle: ["OK"])
            } else if currentPw == newPw {
                sendAlertWithoutHandler(alertTitle: "Same Password", alertMessage: "Your new password is the same as your current password, please enter a new one.", actionTitle: ["OK"])
            } else if newPw.characters.count < 8 {
                sendAlertWithoutHandler(alertTitle: "Password Reset Fails", alertMessage: "Password must be at least 8 characters. Please re-enter.", actionTitle: ["OK"])
            } else {
                let user = Auth.auth().currentUser
                user?.updatePassword(to: newPw, completion: { (error) in
                    print("Grandon(DetailSettingVC): update started?")
                    if let error = error {
                        self.sendAlertWithoutHandler(alertTitle: "Error", alertMessage: error.localizedDescription, actionTitle: ["Cancel"])
                    } else {
                        let updateCompleteAlert = UIAlertController(title: "Update Complete", message: "Successfully update your password", preferredStyle: .alert)
                        let handler = { (action: UIAlertAction!) -> Void in
                            KeychainWrapper.standard.set(newPw, forKey: CURRENT_PASSWORD)
                            currentPassword = KeychainWrapper.standard.string(forKey: CURRENT_PASSWORD)
                            print("Grandon: the new password is \(currentPassword)")
                            self.dismiss(animated: true, completion: nil)
                        }
                        
                        updateCompleteAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: handler
                        ))
                        self.present(updateCompleteAlert, animated: true, completion: nil)
                        
                    }
                })
                
                print("Grandon: the current new password is \(currentPassword)")

            }
        }
        activityIndicator.stopAnimating()
    }
}
