//
//  Post.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class Post {
    private var _title: String!
    private var _likes: Int!
    private var _postImgUrl: String!
    private var _created: String!
    private var _key: String!
    
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
    
    init() {
//        self._title = title
//        self._postImgUrl = postImgUrl
//        self._likes = likes
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateStyle = .medium
//        dateFormatter.timeStyle = .medium
//        self._created = NSDate()
//        dateFormatter.string(from: self._created as Date)
        
    }
    
    init(key: String, postDict: Dictionary<String, Any>) {
        self._key = key
        
        if let postDescription = postDict["postDescription"] as? String {
            self._title = postDescription
        }
        
        if let likes = postDict["likes"] as? Int {
            self._likes = likes
        }
        
        if let imageUrl = postDict["completionImgUrl"] as? String {
            self._postImgUrl = imageUrl
        }
        
        if let created = postDict["created"] as? String {
            self._created = created
        }
        
    }
    
    
}
