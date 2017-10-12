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

var currentEmail: String!
var currentUsername: String!
var currentPassword: String!
var settings = [personal, security, myPost, favourite]
var posts = [Post]()
var myPosts = [Post]()
var myPostIds = [String]()
var myFavPostIds = [String]()
