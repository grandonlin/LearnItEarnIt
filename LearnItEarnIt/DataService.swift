//
//  DataService.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-26.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import Foundation
import Firebase

let DB_BASE = FIRDatabase.database().reference()
let STORAGE_BASE = FIRStorage.storage().reference()

class DataService {
    
    static let ds = DataService()
    
    //DB references
    private var _REF_BASE = DB_BASE
    private var _REF_USERS = DB_BASE.child("users")
    private var _REF_POSTS = DB_BASE.child("posts")
    
    var REF_PROFILES: FIRDatabaseReference!
    
    //STORAGE references
    private var _STORAGE_PROFILE_IMAGE = STORAGE_BASE.child("profile_pic")
    
    var REF_BASE: FIRDatabaseReference {
        return _REF_BASE
    }
    
    var REF_USERS: FIRDatabaseReference {
        return _REF_USERS
    }
    
    var REF_POSTS: FIRDatabaseReference {
        return _REF_POSTS
    }
    
    var STORAGE_PROFILE_IMAGE: FIRStorageReference {
        return _STORAGE_PROFILE_IMAGE
    }
    
    func createFirebaseDBUser(uid: String, profileData: Dictionary<String, String>) {
        let profileKey = REF_USERS.child(uid).child("profile").childByAutoId()
        REF_USERS.child(uid).child("profile").child("\(profileKey)").updateChildValues(profileData)
        REF_PROFILES = REF_USERS.child(uid).child("profile").child("\(profileKey)")
    }

}
