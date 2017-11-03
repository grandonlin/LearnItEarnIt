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

class PostCreateVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var postCreateImage: UIImageView!
    @IBOutlet weak var postTitleTextField: UITextField!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var topSpace: NSLayoutConstraint!

    var imagePicker: UIImagePickerController!
    var indicator = UIActivityIndicatorView()
    var post: Post!
    var postId: String!
    var completionImgName: String!
    var lastPost: Int! = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTitleTextField.delegate = self
        textView.delegate = self
        
        imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = true
        imagePicker.delegate = self
        
        indicator.center = self.view.center
        indicator.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 4.0, height: 4.0)
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
        lastPost = KeychainWrapper.standard.integer(forKey: LAST_POST)
        print("Grandon(postCreateVC): postCount is now \(lastPost)")
        postId = "\(lastPost + 1)"
        
//        postId = NSUUID().uuidString
        post = Post(key: postId)
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        
        tapRecognizer.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tapRecognizer)
        
        //Uncover the content behind the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUP), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDOWN), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(self.doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        textView.inputAccessoryView = toolBar
        postTitleTextField.inputAccessoryView = toolBar
        
        if steps.count == 0 {
            self.post.isNew = true
        }
        
    }
    
    func doneClicked() {
        view.endEditing(true)
    }
    
    func keyboardUP(notification: Notification) {
        if !postTitleTextField.isEditing {
            if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
//                self.stackView.frame.origin.y = 0
                self.stackView.frame.origin.y -= keyboardSize.height
            }
        }
    
    }
    
    func keyboardDOWN(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.stackView.frame.origin.y += keyboardSize.height
        }
    }

    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        self.textView.resignFirstResponder()
        self.postTitleTextField.resignFirstResponder()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.returnKeyType = .done
        return true
    }
    
    @IBAction func nextBtnPressed(_ sender: Any) {
//        self.indicator.startAnimating()
        guard let postTitle = postTitleTextField.text, postTitle != "" else {
            let titleAlert = UIAlertController(title: "Missing Title", message: "Please give your post a cool name.", preferredStyle: .alert)
            titleAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(titleAlert, animated: true, completion: nil)
            return
        }
        
        guard let postDesc = textView.text, postDesc != "" else {
            let descAlert = UIAlertController(title: "Missing Description", message: "Post description is not entered.", preferredStyle: .alert)
            descAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(descAlert, animated: true, completion: nil)
            return
        }
        
        loadingView = LoadingView(uiView: view, message: "Creating...")
        
        if self.post.isNew {
            let stepImgUrl = "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/emptyImage.png?alt=media&token=a683e44f-e9ab-4ecc-a5a4-19ad16411a49"
            let stepToBeInit = Step(postId: self.postId, stepNum: 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!, stepImgUrl: stepImgUrl, imageData: Data(), metaData: StorageMetadata())
            steps.append(stepToBeInit)
        }
        
        DataService.ds.REF_USERS_CURRENT.child("myPosts").child(postId).setValue(post.created)
        
        if let postImg = postImage.image {
            if let imgData = UIImageJPEGRepresentation(postImg, 0.5) {
                completionImgName = postTitle
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.POST_IMAGE.child(postId).child(completionImgName).putData(imgData, metadata: metadata) { (data, error) in
                    if error != nil {
                        let imgAlert = UIAlertController(title: "Error", message: "\(error?.localizedDescription)", preferredStyle: .alert)
                        imgAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
                        self.present(imgAlert, animated: true, completion: nil)
//                        print("Grandon(postCreateVC): not able to upload image")
                    } else {
                        let imgUrl = data?.downloadURL()?.absoluteString
                        if self.post.isNew {
                            let step = ["stepDescription": "", "stepImgUrl": "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/emptyImage.png?alt=media&token=a683e44f-e9ab-4ecc-a5a4-19ad16411a49", "stepNum" : 1] as [String : Any]
                            let postDict = ["completionImgUrl": imgUrl!, "created": self.post.created, "likes": 0, "postTitle": postTitle, "steps": ["detailDescription" : postDesc, "stepDetails": ["step1": step]]] as [String : Any]
                            DataService.ds.REF_POSTS.child(self.postId).updateChildValues(postDict)                            
                            self.post.isNew = false
                        } else {
                            DataService.ds.REF_POSTS.child(self.postId).child("completionImgUrl").setValue(imgUrl!)
                            DataService.ds.REF_POSTS.child(self.postId).child("postTitle").setValue(postTitle)
                            DataService.ds.REF_POSTS.child(self.postId).child("steps").child("detailDescription").setValue(postDesc)
                        }
                        
                    }
                }

            }
        }
//        self.indicator.stopAnimating()
        loadingView.hide()
        performSegue(withIdentifier: "DetailStepVC", sender: sender)
        
    }
    
    @IBAction func onDismissKeyboard(_ sender: Any) {
        self.postTitleTextField.resignFirstResponder()
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
            destination.completionImgName = self.completionImgName
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        loadingView = LoadingView(uiView: view, message: "")
        let postRef = DataService.ds.REF_POSTS
        postRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapShot {
                    if snap.key == self.postId {
                        DataService.ds.REF_USERS_CURRENT.child("myPosts").child(self.postId).removeValue()
                        DataService.ds.REF_POSTS.child(self.postId).removeValue()
                        DataService.ds.POST_IMAGE.child(self.postId).child(self.completionImgName).delete(completion: nil)
                        break
                    }
                }
            }
        })
        loadingView.hide()
        dismiss(animated: true, completion: nil)
    }
    
}
