//
//  Profile.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-29.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class Profile {
    
    private var _profileKey: String!
    private var _userName: String!
    private var _profileImgUrl: String!
    private var _gender: String!
    private var _recentCompletionImgUrl: String!
    
    var profilekey: String {
        return _profileKey
    }
    
    var userName: String {
        return _userName
    }
    
    var profileImgUrl: String {
        return _profileImgUrl
    }
    
    var gender: String {
        return _gender
    }
    
    var recentCompletionImgUrl: String! {
        return _recentCompletionImgUrl
    }
    
    init(profileKey: String) {
        self._profileKey = profileKey
    }
    
    init(profileKey: String, profileData: Dictionary<String, Any>) {
        self._profileKey = profileKey
        
        if let profileImageUrl = profileData["profileImgUrl"] as? String {
            self._profileImgUrl = profileImageUrl
        }
        
        if let username = profileData["userName"] as? String {
            self._userName = username
        }
        
        if let gender = profileData["gender"] as? String {
            self._gender = gender
        }
        
        if let recentCompletionImageUrl = profileData["recentCompletionImgUrl"] as? String {
            self._recentCompletionImgUrl = recentCompletionImageUrl
        }
     }
    
}
