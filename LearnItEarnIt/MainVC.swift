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

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeNumLbl: UILabel!
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var searchBar: UISearchBar!
    
    var inSearchMode = false
    var post: Post!
    var posts = [Post]()
    var filterPosts = [Post]()
    var postKey: String!
    var postTitle: String!
    var profile: Profile!
    var username: String!
    var gender: String!
    var coverPhotoUrl: String!
    var facebookProfileImg: UIImage!
    var defaultCompletionImgUrl: String!
    var ref: DatabaseReference!
    var postRef: DatabaseReference!
    let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done

        postRef = DataService.ds.REF_POSTS
//        postRef.queryOrdered(byChild: "created").observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    if let postDict = snap.value as? Dictionary<String, Any> {
//                        let key = snap.key
//                        let post = Post(key: key, postDict: postDict)
//                        self.posts.insert(post, at: 0)
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })
        fetchData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        ref = DataService.ds.REF_USERS.child(profileKey).child("profile")
        ref.observeSingleEvent(of: .value, with: { (snapshot) in
            if let profileDict = snapshot.value as? Dictionary<String, Any> {
                print("Grandon(MainVC): existing user snap is \(profileDict)")
                if let username = profileDict["userName"] as? String {
                    print("Grandon(MainVC): username in profileDict is \(username)")
                    if username == "" {
                        self.createFBProfile(id: self.profileKey)
                    }
                }
            }
        })
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeObserver(withHandle: HANDLE)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if inSearchMode {
            return filterPosts.count
        } else {
            return posts.count
        }
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "PostCell") as? PostCell {
            let post: Post!
            if inSearchMode {
                post = filterPosts[indexPath.row]
                cell.configureCell(post: post)
            } else {
                post = posts[indexPath.row]
                cell.configureCell(post: post)
            }

            return cell
        }
        return PostCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var post: Post!
        if inSearchMode {
            post = filterPosts[indexPath.row]
        } else {
            post = posts[indexPath.row]
        }
        
        postKey = post.key
        print("Grandon(MainVC): post key is \(postKey)")
        postTitle = post.title
        performSegue(withIdentifier: "PostVC", sender: post)
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            inSearchMode = false
            tableView.reloadData()
            view.endEditing(true)
        } else {
            inSearchMode = true
            let lower = searchBar.text!.lowercased()
            filterPosts = posts.filter({$0.title.range(of: lower) != nil })
            tableView.reloadData()
        }
    }


    @IBAction func listChange(_ sender: Any) {
        fetchData()
    }
    
    func fetchData() {
        if segment.selectedSegmentIndex == 0 {
            self.posts.removeAll()
            postRef.queryOrdered(byChild: "created").observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let post = Post(key: key, postDict: postDict)
                            self.posts.insert(post, at: 0)
                        }
                    }
                }
                
                self.tableView.reloadData()
            })
        } else if segment.selectedSegmentIndex == 1 {
            self.posts.removeAll()
            postRef.queryOrdered(byChild: "likes").observe(.value, with: { (snapshot) in
                if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapshot {
                        if let postDict = snap.value as? Dictionary<String, Any> {
                            let key = snap.key
                            let post = Post(key: key, postDict: postDict)
                            self.posts.insert(post, at: 0)
                        }
                    }
                }
                self.tableView.reloadData()
            })
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostVC {
            destination.vcTitle = postTitle
            destination.postKey = postKey
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
                print("Grandon(MainVC): The result is \(result)")
                if let resultDict = result as? Dictionary<String, Any> {
                    if let name = resultDict["name"] as? String {
                        self.username = name
                    }
                    if let gender = resultDict["gender"] as? String {
                        self.gender = gender.capitalized
                    }
//                    self.username = resultDict["name"] as! String
//                    self.gender = resultDict["gender"] as! String
//                    self.gender = self.gender.capitalized
                    if let pictureDict = resultDict["picture"] as? Dictionary<String, Any> {
//                        print("Grandon(MainVC): pictureDict is \(pictureDict)")
                        if let data = pictureDict["data"] as? Dictionary<String, Any> {
//                            print("Grandon(MainVC): data is \(data)")
                            if let url = data["url"] as? String {
                                print("Grandon(MainVC): url is \(url)")
                                let imageUrl = URL(string: url)!
                                DispatchQueue.global(qos: .userInitiated).async {
                                    let imageData = NSData(contentsOf: imageUrl)
                                    DispatchQueue.main.sync {
                                        let img = UIImage(data: imageData as! Data)
                                        if let profileImageData = UIImageJPEGRepresentation(img!, 1.0) {
                                            let imgUid = NSUUID().uuidString
                                            let metadata = StorageMetadata()
                                            metadata.contentType = "image/jpeg"
                                            DataService.ds.STORAGE_PROFILE_IMAGE.child(imgUid).putData(profileImageData, metadata: metadata) { (metadata, error) in
                                                if error != nil {
                                                    print("Grandon(MainVC): unable to upload image \(error)")
                                                } else {
                                                    self.coverPhotoUrl = metadata?.downloadURL()?.absoluteString
                                                    self.defaultCompletionImgUrl = "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/profile_pic%2FdefaultCompletionImage.jpg?alt=media&token=90f151a9-65c9-4b1b-b706-eaae1f6170a1"
                                                    let profileDict = ["userName": self.username!, "gender": self.gender!, "profileImgUrl": self.coverPhotoUrl!, "recentCompletionImgUrl": self.defaultCompletionImgUrl!]
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
    
    @IBAction func addBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "PostCreateVC", sender: nil)
    }
    
    
}

