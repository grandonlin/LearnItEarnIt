//
//  RecentCompletionVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-06-16.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class RecentCompletionVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var completionImage: UIImage!
    var imagePicker: UIImagePickerController!
    var imageUrl: String!
    var indicator = UIActivityIndicatorView()
    let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
    
    @IBOutlet weak var completionImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
        completionImageView.image = completionImage
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
    }

    @IBAction func imagePressed(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
        
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            completionImageView.image = selectedImage
        }
        imagePicker.dismiss(animated: true
            , completion: nil)
    }
    
    @IBAction func saveBtnPressed(_ sender: Any) {
        indicator.startAnimating()
        let imageData = UIImageJPEGRepresentation(completionImageView.image!, 0.5)
        let imageUid = NSUUID().uuidString
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        DataService.ds.STORAGE_PROFILE_IMAGE.child(imageUid).put(imageData!, metadata: metadata) { (data, error) in
            if error != nil {
                print("Grandon(Recent): unable to upload picture.")
            } else {
                let imageUrl = data?.downloadURL()?.absoluteString
                let completionImgDic = ["recentCompletionImgUrl": imageUrl]
            DataService.ds.REF_USERS.child(self.profileKey).child("profile").updateChildValues(completionImgDic)
                self.indicator.stopAnimating()
            }
        }
        performSegue(withIdentifier: "ProfileVC", sender: AnyObject.self)
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
