//
//  PostCreateVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-05.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper

class PostCreateVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    @IBAction func postPressed(_ sender: Any) {
        let post = Post()
        let created = ["created": "\(post.created)"]
        let postKey = "34nnf923"
        DataService.ds.REF_POSTS.child(postKey).updateChildValues(created)
        print(created)
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
