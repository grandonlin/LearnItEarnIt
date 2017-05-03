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
    @IBOutlet weak var genderPicker: UIPickerView!
    
    var imagePicker: UIImagePickerController!
    var profileImg: UIImage!
    let genders = ["Male", "Female"]
    var genderSelected: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        genderPicker.dataSource = self
        genderPicker.delegate = self
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        genderSelected = genders[row]
        print("This is what is selected: \(genderSelected)")
        return genders[row]
    }
    
    

    @IBAction func profileImgTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            profileImageView.image = image
            
        } else {
            print("Grandon: a valid image wasn't selected")
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func saveBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "ProfileVC", sender: genderSelected)
    }
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if let destination = segue.destination as? ProfileVC {
//            if let gender = sender as? String, let image = sender as? String {
//                print("What's being sent: \(gender)")
//                destination.gender = gender
//                destination.profileImage = image
//            }
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
