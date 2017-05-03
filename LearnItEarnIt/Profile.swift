//
//  Profile.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-29.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class Profile {
    
//    static let pf = Profile()
    
    private var _profileKey: String!
    private var _userName: String = ""
    private var _profileImageUrl: String = ""
    private var _gender: String = ""
    private var _profileImage: UIImageView! = nil
    private var _recentCompletedImage: UIImageView! = nil
    
    var profilekey: String {
        return _profileKey
    }
    
    var userName: String {
        get {
            return _userName
        } set {
            _userName = newValue
        }
    }
    
    var profileImageUrl: String {
        get {
            return _profileImageUrl
        }
    }
    
    var gender: String {
        get {
            return _gender
        } set {
            _gender = newValue
        }
    }
    
    var profileImage: UIImageView! {
        get {
            return _profileImage
        } set {
            _profileImage = newValue
        }
    }
    
    var recentCompletedImage: UIImageView! {
        get {
            return _recentCompletedImage
        } set {
            _recentCompletedImage = newValue
        }
    }
    
    init(profileKey: String, profileData: Dictionary<String, Any>) {
        self._profileKey = profileKey
        
//        if let profileImageUrl = profileData["profileImageUrl"] as? String {
//            self._profileImageUrl = profileImageUrl
//        }
     }
    
}
