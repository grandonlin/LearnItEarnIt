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
//    var loadingView: LoadingView!
    
    @IBOutlet weak var completionImageView: UIImageView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

      
        
        completionImageView.image = completionImage
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
    }

    override func viewDidAppear(_ animated: Bool) {
//        loadingView.hide()
        activityIndicator.stopAnimating()
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
    
    @IBAction func saveBtnPressed(_ sender: UIButton) {
//        indicator.startAnimating()
//        loadingView.show()
        if let imageData = UIImageJPEGRepresentation(completionImageView.image!, 0.5) {
            let imageUid = "Recent Completion Image"
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            DataService.ds.STORAGE_PROFILE_IMAGE.child(self.profileKey).child(imageUid).putData(imageData, metadata: metadata) { (metadata, error) in
                if error != nil {
                    print("Grandon(RecentVC): unable to upload picture.")
                } else {
                    let imageUrl = metadata?.downloadURL()?.absoluteString
                    let completionImgDic = ["recentCompletionImgUrl": imageUrl!]
                    DataService.ds.REF_USERS.child(self.profileKey).child("profile").updateChildValues(completionImgDic)
                }
            }
            performSegue(withIdentifier: "ProfileVC", sender: AnyObject.self)
            
        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
}
