//
//  Post.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class Post {
    private var _title: String!
    private var _likes: Int!
    private var _postImgUrl: String!
    private var _created: String!
    private var _key: String!
    private var _postDescription: String!
    private var _isNew: Bool!
    
    var title: String {
        return _title
    }
    
    var likes: Int {
        return _likes
    }
    
    var postImgUrl: String {
        return _postImgUrl
    }
    
    var key: String {
        return _key
    }
    
    var created: String {
        return _created
    }
    
    var postDescription: String {
        return _postDescription
    }
    
    var isNew: Bool {
        get {
            return _isNew
        }
        set {
            return _isNew = newValue
        }
    }
    
    init(key: String) {
        self._key = key
        self._created = "\(NSDate().timeCreated())"
        self._isNew = true
    }
    
//    init(key: String, postTitle: String, postImgUrl: String, postDesc: String) {
//        self._key = key
//        self._created = "\(NSDate())"
//        self._title = postTitle
//        self._postImgUrl = postImgUrl
//        self._likes = 0
//    }
    
    //Initiating after downloading data from Firebase
    init(key: String, postDict: Dictionary<String, Any>) {
        self._key = key
        
        if let postTitle = postDict["postTitle"] as? String {
            self._title = postTitle
        }
        
        if let likes = postDict["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = postDict["completionImgUrl"] as? String {
            self._postImgUrl = imageUrl
        }
        
        if let created = postDict["created"] as? String {
            let removeRange = created.range(of: " at")
            let index = removeRange!.lowerBound
            let dateCreated = created.substring(to: index)
            self._created = dateCreated
        }
        
        if let postStep = postDict["steps"] as? Dictionary<String, Any> {
            let postDesc = postStep["detailDescription"] as! String
            self._postDescription = postDesc
        }
        
    }
    
}

extension NSDate {
    func timeCreated() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .medium
        return dateFormatter.string(from: self as Date)
    }
}
