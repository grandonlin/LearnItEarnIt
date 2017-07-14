//
//  SetupVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-29.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SetupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var backBtnImageView: FancyBtn!
    @IBOutlet weak var saveBtnView: UIButton!
    @IBOutlet weak var signOutBtnView: UIButton!
    
    var imagePicker: UIImagePickerController!
    var profileImg: UIImage!
    let genders = ["Male", "Female"]
    var genderSelected: String! = "Male"
    var userName: String!
    var newProfileSetup: Bool!
    var imageUrl: String!
    var newProfileImage: Bool! = false
//    var imageData1: Data!
//    var imgUid1: String!
//    var metadata1: FIRStorageMetadata!
    var indicator = UIActivityIndicatorView()
    
    let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        userNameTextField.delegate = self
        
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        
        userNameTextField.text = userName
        profileImageView.image = profileImg
        
        if genderSelected == "Female" {
            genderPickerView.selectRow(1, inComponent: 0, animated: true)
        } else {
            genderPickerView.selectRow(0, inComponent: 0, animated: true)
        }
        
        if newProfileSetup == true {
            backBtnImageView.isHidden = true
            signOutBtnView.isHidden = true
        } else {
            backBtnImageView.isHidden = false
            signOutBtnView.isHidden = false
        }
        
        
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genders[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderSelected = genders[row]
    }
    
    @IBAction func profileImgTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            if let selectedProfileImg = info[UIImagePickerControllerEditedImage] as? UIImage {
                profileImageView.image = selectedProfileImg
                profileImg = selectedProfileImg
                self.newProfileImage = true
//                imageData1 = UIImageJPEGRepresentation(profileImg, 0.5)
//                imgUid1 = NSUUID().uuidString
//                metadata1 = FIRStorageMetadata()
//                metadata1.contentType = "image/jpeg"
            } else {
                print("Grandon: a valid image wasn't selected")
            }
        imagePicker.dismiss(animated: true, completion: nil)
    }
        
    @IBAction func saveBtnTapped(_ sender: Any) {
        if let username = userNameTextField.text {
            if username != "" {
                if self.newProfileImage == true {
                    indicator.startAnimating()
                    if let imageData = UIImageJPEGRepresentation(profileImg!, 0.5) {
                        let imgUid = NSUUID().uuidString
                        let metadata = StorageMetadata()
                        metadata.contentType = "image/jpeg"
                        DataService.ds.STORAGE_PROFILE_IMAGE.child(imgUid).putData(imageData, metadata: metadata) {
                            (data, error) in
                            if error != nil {
                                print("Grandon(SetupVC): unable to upload profile image.")
                            } else {
                                print("Grandon(SetupVC): successfully upload profile image.")
                                self.imageUrl = data?.downloadURL()?.absoluteString
                                let newProfileData = ["gender": self.genderSelected, "userName": username, "profileImgUrl": self.imageUrl!]
                                DataService.ds.REF_USERS.child(self.profileKey).child("profile").updateChildValues(newProfileData)
                                self.indicator.stopAnimating()
                            }
                        }
                    }
                } else {
                    let newProfileData = ["gender": self.genderSelected, "userName": username]
                    DataService.ds.REF_USERS.child(self.profileKey).child("profile").updateChildValues(newProfileData)
                    print("Grandon(SetupVC): profile image not changed.")
                }
                performSegue(withIdentifier: "MainVC", sender: AnyObject.self)
            } else {
                print("Grandon: please enter your user name")
            }

        }
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signOutBtnTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            performSegue(withIdentifier: "LoginVC", sender: nil)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    

    
}
