//
//  Global.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-08-02.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import SwiftKeychainWrapper
import Firebase

var steps = [Step]()

let personal = Settings(title: "Personal", image: UIImage(named: "personal")!)
let security = Settings(title: "Security", image: UIImage(named: "security")!)
let myPost = Settings(title: "My Posts", image: UIImage(named: "post")!)
let favourite = Settings(title: "My Favourites", image: UIImage(named: "favourite")!)
let userRef = DataService.ds.REF_USERS

var currentEmail: String!
var currentUsername: String!
var currentPassword: String!
var settings = [personal, security, myPost, favourite]
var posts = [Post]()
var myPosts = [Post]()
var myPostIds = [String]()
var myFavPostIds = [String]()
var myFavPosts = [Post]()
var loadingView: LoadingView!

 
extension UIViewController {
    func sendAlertWithoutHandler(alertTitle: String, alertMessage: String, actionTitle: [String]) {
        let alert = UIAlertController(title: alertTitle, message: alertMessage, preferredStyle: .alert)
        for action in actionTitle {
            alert.addAction(UIAlertAction(title: action, style: .default, handler: nil))
        }
        self.present(alert, animated: true, completion: nil)
    }
}
