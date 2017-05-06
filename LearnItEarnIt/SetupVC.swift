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

class SetupVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate {

    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var genderPickerView: UIPickerView!
    @IBOutlet weak var profileImageView: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var profileImg: UIImage!
    let genders = ["Male", "Female"]
    var genderSelected: String! = "Male"
    var userName: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        genderPickerView.dataSource = self
        genderPickerView.delegate = self
        
        userNameTextField.text = userName
        profileImageView.image = profileImg
        if genderSelected == "Male" {
            genderPickerView.selectRow(0, inComponent: 0, animated: true)
        } else {
            genderPickerView.selectRow(1, inComponent: 0, animated: true)
        }
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
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            profileImg = image
        } else {
            print("Grandon: a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    func uploadProfileData() {
        if userNameTextField.text != nil && userNameTextField.text != "" {
                if let imageData = UIImageJPEGRepresentation(profileImg, 0.3) {
                    let imgUid = NSUUID().uuidString
                    let metadata = FIRStorageMetadata()
                    metadata.contentType = "image/jpeg"
                    DataService.ds.STORAGE_PROFILE_IMAGE.child(imgUid).put(imageData, metadata: metadata, completion: { (metadata, error) in
                        if let error = error {
                            print("Grandon: unable to upload data - \(error)")
                        } else {
                            print("Grandon: successfully upload data")
                            let downloadURL = metadata?.downloadURL()!.absoluteString
                            let newProfileData = ["gender": self.genderSelected, "profileImgUrl": downloadURL!, "recentCompletionImgUrl": "", "userName": self.userName] as [String : String]
                            let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
                            DataService.ds.REF_USERS.child(profileKey).child("profile").updateChildValues(newProfileData)
                        }
                    })
                }
        } else {
            print("Grandon: username cannot be empty.")
        }
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        uploadProfileData()
        performSegue(withIdentifier: "ProfileVC", sender: genderSelected)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? ProfileVC {
//            
//        }
//    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signOutBtnTapped(_ sender: Any) {
        do {
            try FIRAuth.auth()?.signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            performSegue(withIdentifier: "LoginVC", sender: nil)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
    
    
}
