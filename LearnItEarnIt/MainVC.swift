//
//  MainVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-21.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit
import SwiftKeychainWrapper

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeNumLbl: UILabel!

    
    var posts = [Post]()
    var postTitle: String!
    var profile: Profile!
    var username: String!
    var gender: String!
    var coverPhotoUrl: String!
    var facebookProfileImg: UIImage!
    var userExist: Bool!
    var ref: FIRDatabaseReference!
    var handle: UInt!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        let post1 = Post(title: "Something Funny")
        posts.append(post1)
        let post2 = Post(title: "Mini Motorcycle by Lighter")
        posts.append(post2)
        
        handle = UInt(0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
        print("Grandon(MainVC): profileKey in MainVC is \(profileKey)")
        ref = DataService.ds.REF_USERS.child(profileKey).child("profile")
        profile = Profile(profileKey: profileKey)
        if DataService.ds.existingUserDetermined(profileKey: profileKey, ref: ref) != true {
            print("Grandon(MainVC), this is false")
            createFBProfile(id: profileKey)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        
        ref.removeObserver(withHandle: handle)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            let post = posts[indexPath.row]
            cell.configureCell(post: post)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let postCell = posts[indexPath.row]
        postTitle = postCell.title
        performSegue(withIdentifier: "PostVC", sender: postCell)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostVC {
            let title = postTitle
            destination.vcTitle = title
        }
        
    }
    
    @IBAction func profileBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "ProfileVC", sender: sender)
    }
    
    func createFBProfile(id: String) {
        FBSDKGraphRequest.init(graphPath: "me", parameters: ["fields": "name,gender,picture"]).start(completionHandler: { (connection, result, error) in
            if error != nil {
                print("Grandon(MainVC): error is \(error)")
            } else {
                if let resultDict = result as? Dictionary<String, Any> {
                    self.username = resultDict["name"] as! String
                    self.gender = resultDict["gender"] as! String
                    self.gender = self.gender.capitalized
                    if let pictureDict = resultDict["picture"] as? Dictionary<String, Any> {
                        print("Grandon(MainVC): pictureDict is \(pictureDict)")
                        if let data = pictureDict["data"] as? Dictionary<String, Any> {
                            print("Grandon(MainVC): data is \(data)")
                            if let url = data["url"] as? String {
                                print("Grandon(MainVC): url is \(url)")
                                let imageUrl = URL(string: url)!
                                DispatchQueue.global(qos: .userInitiated).async {
                                    let imageData = NSData(contentsOf: imageUrl)
                                    DispatchQueue.main.sync {
                                        let img = UIImage(data: imageData as! Data)
//                                        self.testImageView.image = img
//                                        let profileImage = self.testImageView.image
                                        if let profileImageData = UIImageJPEGRepresentation(img!, 1.0) {
//                                            print("Grandon: This is true")
                                            let imgUid = NSUUID().uuidString
//                                            print("Grandon: imgUid is \(imgUid)")
                                            let metadata = FIRStorageMetadata()
                                            metadata.contentType = "image/jpeg"
//                                            print("Grandon: the metadata content type is \(metadata.contentType) ")
                                            DataService.ds.STORAGE_PROFILE_IMAGE.child(imgUid).put(profileImageData, metadata: metadata) { (metadata, error) in
                                                if error != nil {
                                                    print("Grandon(MainVC): unable to upload image \(error)")
                                                } else {
                                                    self.coverPhotoUrl = metadata?.downloadURL()!.absoluteString
                                                    print("Grandon(MainVC): coverPhotoUrl is \(self.coverPhotoUrl!)")
                                                    let profileDict = ["userName": self.username!, "gender": self.gender!, "profileImgUrl": self.coverPhotoUrl!, "recentCompletionImgUrl": ""]
                                                    print("Grandon(MainVC): username is \(self.username), gender is \(self.gender), profileImgUrl is \(self.coverPhotoUrl)")
                                                    self.ref.updateChildValues(profileDict)
                                                    
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
//            connection?.cancel()
        })
    }
    
    
    
}

