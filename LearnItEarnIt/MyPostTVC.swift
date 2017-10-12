//
//  MyPostTVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-09.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class MyPostTVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate {

    @IBOutlet weak var postTableView: UITableView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var editBtn: UIButton!

    
    var pageTitle: String!
    var postTitle: String!
    var postKey: String!
    var filterPosts = [Post]()
    var isSearchMode = false
    var indicator = UIActivityIndicatorView()
    let myPostIDRef = DataService.ds.REF_USERS_CURRENT.child("myPost")
    let postsRef = DataService.ds.REF_POSTS
    let myFavIDRef = DataService.ds.REF_USERS_CURRENT.child("myLikes")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTableView.dataSource = self
        postTableView.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        indicator.center = self.view.center
        indicator.activityIndicatorViewStyle = .whiteLarge
        self.view.addSubview(indicator)
        
        titleLbl.text = pageTitle
        
        if pageTitle == "My Favourites" {
            editBtn.isHidden = true
        }
        

        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myPosts.removeAll()
        print("Grandon(MyPostTVC): myPosts has \(myPosts.count) records")
        myPostIds.removeAll()
        print("Grandon(MyPostTVC): myPostIds has \(myPostIds.count) records")
        myFavPostIds.removeAll()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        indicator.startAnimating()
        searchPost()
        indicator.stopAnimating()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myPosts.removeAll()
        myFavPostIds.removeAll()
        myPostIds.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isSearchMode {
            return filterPosts.count
        } else {
            return myPosts.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCell") as? MyPostCell {
            let post: Post!
            if isSearchMode {
                post = filterPosts[indexPath.row]
            } else {
                post = myPosts[indexPath.row]
            }
            cell.configurePostCell(post: post)
            return cell
        }
        return UITableViewCell()
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var post: Post!
        print("Grandon(MyPostTVC): there are \(myPosts.count) records, indexPath.row is \(indexPath.row)")

        if isSearchMode {
            post = filterPosts[indexPath.row]
        } else {
            post = myPosts[indexPath.row]
        }
        
        postKey = post.key
        postTitle = post.title
        performSegue(withIdentifier: "PostVC", sender: post)
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        postTableView.beginUpdates()
        let post: Post!
        if isSearchMode {
            post = filterPosts[indexPath.row]
        } else {
            post = myPosts[indexPath.row]
        }
        
        postKey = post.key
        myPostIDRef.child(postKey).removeValue()
        postsRef.child(postKey).removeValue()
        DataService.ds.POST_IMAGE.child(postKey).child(postTitle).delete(completion: nil)
        postTableView.deleteRows(at: [indexPath], with: .fade)
        if isSearchMode {
            filterPosts.remove(at: indexPath.row)
        } else {
            myPosts.remove(at: indexPath.row)
        }
        postTableView.reloadData()
        postTableView.endUpdates()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostVC {
            destination.vcTitle = postTitle
            destination.postKey = postKey
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        view.endEditing(true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text == nil || searchBar.text == "" {
            isSearchMode = false
            postTableView.reloadData()
            view.endEditing(true)
        } else {
            isSearchMode = true
//            let lower = searchBar.text!.lowercased()
            filterPosts = myPosts.filter({ (text) -> Bool in
                let tmp = text as Post
                let range = tmp.title.lowercased().contains(searchText.lowercased())
                return range
            })
//            filterPosts = myPosts.filter({$0.title.range(of: lower) != nil })
            postTableView.reloadData()
        }
    }
    
    func searchPost() {
        myPosts.removeAll()
        myPostIds.removeAll()
        myFavPostIds.removeAll()
        print("Grandon(MyPostTVC): current user reference is \(DataService.ds.REF_USERS_CURRENT.key)")

        if pageTitle == "My Posts" {
            myPostIDRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapShot {
//                        postsRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
//                            if let postSnapShot = postSnapshot.children.allObjects as? [DataSnapshot] {
//                                for postSnap in postSnapShot {
//                                    if snap.key == postSnap.key {
//                                        if let postDict = postSnap.value as? Dictionary<String, Any> {
//                                            let post = Post(key: postSnap.key, postDict: postDict)
//                                            myPosts.append(post)
//                                            self.postTableView.reloadData()
//                                        }
//                                        
//                                    }
//                                    
//                                }
//                            }
//                        })
                        myPostIds.insert(snap.key, at: 0)
                        print("Grandon(DetailSettingVC): this post id is \(snap.key)")
                    }
                    for postId in myPostIds {
                        self.postsRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (postSnapshot) in
                            if let postSnapShot = postSnapshot.children.allObjects as? [DataSnapshot] {
                                for postSnap in postSnapShot {
                                    if postSnap.key == postId {
                                        print("Grandon(DetailSettingVC): the postsnap key is \(postSnap.key)")
                                        print("Grandon(DetailSettingVC): the postId is \(postId)")
                                        if let postDict = postSnap.value as? Dictionary<String, Any> {
                                            let post = Post(key: postSnap.key, postDict: postDict)
                                            myPosts.append(post)
                                            self.postTableView.reloadData()
                                        }
                                    }
                                }
                            }
                        })
                    }

                }
            })
        } else if pageTitle == "My Favourites" {
            
            myFavIDRef.observe(.value, with: { (snapshot) in
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    for snap in snapShot {
                        myFavPostIds.append(snap.key)
                    }
                    for favPostId in myFavPostIds {
                        self.postsRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
                            if let postSnapShot = postSnapshot.children.allObjects as? [DataSnapshot] {
                                for postSnap in postSnapShot {
                                    if postSnap.key == favPostId {
                                        if let postDict = postSnap.value as? Dictionary<String, Any> {
                                            let post = Post(key: postSnap.key, postDict: postDict)
                                            myPosts.append(post)
                                            self.postTableView.reloadData()
                                        }
                                    }
                                }
                            }
                        })
                    }
                }
            })
        }
    }
    
    @IBAction func editBtnPressed(_ sender: Any) {
        if postTableView.isEditing {
            postTableView.setEditing(false, animated: false)
            editBtn.setTitle("Edit", for: .normal)
        } else {
            if myPosts.count == 0 {
                postTableView.setEditing(false, animated: false)
            } else {
                postTableView.setEditing(true, animated: true)
                editBtn.setTitle("Save", for: .normal)
            }

        }
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
  
}
