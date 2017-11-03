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
    let myPostIDRef = DataService.ds.REF_USERS_CURRENT.child("myPosts")
    let postsRef = DataService.ds.REF_POSTS
    let myFavIDRef = DataService.ds.REF_USERS_CURRENT.child("myLikes")
    
    override func viewDidLoad() {
        super.viewDidLoad()

        postTableView.dataSource = self
        postTableView.delegate = self
        searchBar.delegate = self
        searchBar.returnKeyType = UIReturnKeyType.done
        
        indicator.center = self.view.center
        indicator.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 4.0, height: 4.0)
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.color = UIColor.red
        self.view.addSubview(indicator)
        
        titleLbl.text = pageTitle
        
        if pageTitle == "My Favourites" {
            editBtn.isHidden = true
        }
        
        loadingView = LoadingView(uiView: view, message: "Loading...")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        myPosts.removeAll()
        print("Grandon(MyPostTVC): myPosts has \(myPosts.count) records")
        myPostIds.removeAll()
        print("Grandon(MyPostTVC): myPostIds has \(myPostIds.count) records")
        myFavPostIds.removeAll()
        print("Grandon(MyPostTVC): myFavPostIds has \(myFavPostIds.count) records")
        myFavPosts.removeAll()
        indicator.startAnimating()
        searchPost()
        indicator.stopAnimating()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadingView.hide()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        myPosts.removeAll()
        myFavPostIds.removeAll()
        myPostIds.removeAll()
        myFavPosts.removeAll()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageTitle == "My Posts" {
            if isSearchMode {
                return filterPosts.count
            } else {
                return myPosts.count
            }
        } else {
            if isSearchMode {
                return filterPosts.count
            } else {
                return myFavPosts.count
            }
        }

    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "MyPostCell") as? MyPostCell {
            let post: Post!
            if pageTitle == "My Posts" {
                if isSearchMode {
                    
                    post = filterPosts[indexPath.row]
                } else {
                    post = myPosts[indexPath.row]
                }
                
            } else {
                if isSearchMode {
                    post = filterPosts[indexPath.row]
                } else {
                    post = myFavPosts[indexPath.row]
                }
            }
            cell.configurePostCell(post: post)
            return cell
        }
        return UITableViewCell()
    }
 
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var post: Post!
        print("Grandon(MyPostTVC): there are \(myPosts.count) records, indexPath.row is \(indexPath.row)")
        if pageTitle == "My Posts" {
            if isSearchMode {
                post = filterPosts[indexPath.row]
            } else {
                post = myPosts[indexPath.row]
            }
        } else {
            if isSearchMode {
                post = filterPosts[indexPath.row]
            } else {
                post = myFavPosts[indexPath.row]
            }
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
        let postTitleToBeDeleted = post.title
        myPostIDRef.child(postKey).removeValue()
        postsRef.child(postKey).removeValue()
        DataService.ds.POST_IMAGE.child(postKey).child(postTitleToBeDeleted).delete(completion: nil)
        postTableView.deleteRows(at: [indexPath], with: .fade)
        if isSearchMode {
            filterPosts.remove(at: indexPath.row)
        } else {
            myPosts.remove(at: indexPath.row)
        }
        postTableView.reloadData()
        postTableView.endUpdates()
        
    }
    
    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCellEditingStyle {
        if pageTitle == "My Posts" {
            return .delete
        }
        return .none
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
            if pageTitle == "My Posts" {
                filterPosts = myPosts.filter({ (text) -> Bool in
                    let tmp = text as Post
                    let range = tmp.title.lowercased().contains(searchText.lowercased())
                    return range
                })
            } else {
                filterPosts = myFavPosts.filter({ (text) -> Bool in
                    let tmp = text as Post
                    let range = tmp.title.lowercased().contains(searchText.lowercased())
                    return range
            })
//            let lower = searchBar.text!.lowercased()
            //            filterPosts = myPosts.filter({$0.title.range(of: lower) != nil })
            postTableView.reloadData()
            }
        }
    }
    
    func searchPost() {
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
            myFavIDRef.queryOrderedByKey().observeSingleEvent(of: .value, with: { (snapshot) in
                if let snapShot = snapshot.children.allObjects as? [DataSnapshot] {
                    if snapShot.count > 0 {
                        for snap in snapShot {
                            myFavPostIds.append(snap.key)
                            print("Grandon(MyPostTVC): myFavPostIds array has \(myFavPosts.count) records")
                        }
                        for favPostId in myFavPostIds {
                            self.postsRef.observeSingleEvent(of: .value, with: { (postSnapshot) in
                                if let postSnapShot = postSnapshot.children.allObjects as? [DataSnapshot] {
                                    for postSnap in postSnapShot {
                                        if postSnap.key == favPostId {
                                            if let postDict = postSnap.value as? Dictionary<String, Any> {
                                                let post = Post(key: postSnap.key, postDict: postDict)
                                                myFavPosts.append(post)
                                                print("Grandon(MyPostTVC): myFavPosts array has \(myFavPosts.count) records")
                                                self.postTableView.reloadData()
                                            }
                                        }
                                    }
                                }
                            })
                        }
                    } else {
                        self.postTableView.reloadData()
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
        myPosts.removeAll()
        myFavPostIds.removeAll()
        myPostIds.removeAll()
        myFavPosts.removeAll()
        dismiss(animated: true, completion: nil)
    }
  
}
