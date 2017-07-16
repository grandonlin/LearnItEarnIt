//
//  PostCreateVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-05.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class PostCreateVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postCreateImage: UIImageView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var postImage: UIImageView!
    
    var imagePicker: UIImagePickerController!
    var indicator = UIActivityIndicatorView()
    var postId: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTitleTextField.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func nextBtnPressed(_ sender: Any) {
        guard let postTitle = postTitleTextField.text, postTitle != "" else {
            print("Grandon: post title must be entered")
            return
        }
        guard let postDesc = textView.text, postDesc != "" else {
            print("Grandon: post description is not entered")
            return
        }
        
        indicator.startAnimating()
        postId = NSUUID().uuidString
        DataService.ds.REF_USERS_CURRENT.child("myPost").child(postId).setValue(true)
        
        let post = Post(key: postId)

        
        if let postImg = postImage.image {
            if let imgData = UIImageJPEGRepresentation(postImg, 0.5) {
                let imgUid = NSUUID().uuidString
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.POST_IMAGE.child(postId).child(imgUid).putData(imgData, metadata: metadata) { (data, error) in
                    if error != nil {
                        print("Grandon(postCreateVC): not able to upload image")
                    } else {
                        let imgUrl = data?.downloadURL()?.absoluteString
                        let postDict = ["completionImgUrl": imgUrl!, "created": post.created, "likes": 0, "postTitle": postTitle, "steps": ["detailDescription" : postDesc]] as [String : Any]
                        DataService.ds.REF_POSTS.child(self.postId).updateChildValues(postDict)
                        
                    }
                }

            }
        }
        indicator.stopAnimating()
        performSegue(withIdentifier: "DetailStepVC", sender: sender)
        
    }
    
    @IBAction func postImageTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            postImage.image = selectedImage
        }
        imagePicker.dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailStepVC {
            destination.postTitle = postTitleTextField.text
            destination.postId = self.postId
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
