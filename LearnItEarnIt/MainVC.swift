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

class MainVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeNumLbl: UILabel!

    
    var posts = [Post]()
    var postTitle: String!
    
    var ref: FIRDatabaseReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
        
        ref = FIRDatabase.database().reference()
        
        let post1 = Post(title: "Something Funny")
        posts.append(post1)
        let post2 = Post(title: "Mini Motorcycle by Lighter")
        posts.append(post2)
        
        
        
        
    }
    
//    override func viewDidAppear(_ animated: Bool) {
//        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    print("SNAP: \(snap)")
//                    if let snapValue = snap.value {
//                        print("SNAPVALUE: \(snapValue)")
//                    }
//                }
//            }
//        })
//    }

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
    
    
    
    
    
    
    
}
