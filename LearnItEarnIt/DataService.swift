//
//  DataService.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-26.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

let DB_BASE = Database.database().reference()
let STORAGE_BASE = Storage.storage().reference()

var userName: String!

class DataService {
    
    static let ds = DataService()
    let uid = KeychainWrapper.standard.string(forKey: KEY_UID)

    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_POSTS = DB_BASE.child("posts")
    //private var _REF_PROFILE = DB_BASE.child("profile")
    
    //STORAGE references
    private var _STORAGE_PROFILE_IMAGE = STORAGE_BASE.child("profile_pic")
    
    var REF_BASE: DatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: DatabaseReference {
        return _REF_USERS
    }
    
    var REF_USERS_CURRENT: DatabaseReference {
        let user = DataService.ds._REF_USERS.child(uid!)
        return user
    }
    
    var REF_USERS_CURRENT_LIKE: DatabaseReference {
        return REF_USERS_CURRENT.child("myLikes")
    }
    
    var REF_POSTS: DatabaseReference {
        return _REF_POSTS
    }
    
//    var REF_PROFILE: FIRDatabaseReference {
//        return _REF_PROFILE
//    }
    
    var STORAGE_PROFILE_IMAGE: StorageReference {
        return _STORAGE_PROFILE_IMAGE
    }
    
    func createFirebaseDBUser(uid: String, profileData: Dictionary<String, String>) {
//        let profileKey = REF_USERS.child(uid).child("profile").childByAutoId().key
//        REF_USERS.child(uid).child("profile").child("\(profileKey)").updateChildValues(profileData)
        REF_USERS.child(uid).child("profile").updateChildValues(profileData)
        
        
    }
    
//    func existingUserDetermined(profileKey: String, ref: FIRDatabaseReference) -> Bool {
//        
//        ref.observe(.value, with: { (snapshot) in
//            if let profileDict = snapshot.value as? Dictionary<String, String> {
//                print("Grandon(DataService): existing user snap is \(profileDict)")
//                let username = profileDict["userName"]
//                print("Grandon(DataService): username in profileDict is \(username)")
//                if username != "" && username != nil {
//                    userName = username
//                }
//            }
//        })
//        print("Grandon(DataService): userName is \(userName)")
//
//        if userName != "" && userName != nil {
//            return true
//        } else {
//            return false
//        }
//    }


}
