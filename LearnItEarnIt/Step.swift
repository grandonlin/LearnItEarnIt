//
//  Step.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class Step {
    private var _stepNum: Int!
//    private var _detailDescription: String!
    private var _stepDescription: String!
    private var _stepImgUrl: String!
    private var _stepImage: UIImage!
    private var _postId: String!
    private var _hasImg: Bool!
    private var _imageData: Data!
    private var _metaData: StorageMetadata!
    
//    var detailDescription: String {
//        return _detailDescription
//    }
    
    var stepNum: Int {
        get {
            return _stepNum
        }
        set {
            return _stepNum = newValue
        }
    }
    
    var stepDescription: String {
        get {
            return _stepDescription
        }
        set {
            return _stepDescription = newValue
        }
    }
    
    var stepImgUrl: String {
        get {
            return _stepImgUrl
        }
        set {
            return _stepImgUrl = newValue
        }
    }
    
    var stepImage: UIImage {
        get {
            return _stepImage
        }
        set {
            return _stepImage = newValue
        }
    }
    
    var postId: String {
        return _postId
    }
    
    var hasImg: Bool {
        get {
            return _hasImg
        }
        set {
            return _hasImg = newValue
        }
    }
    
    var imageData: Data {
        get {
            return _imageData
        }
        set {
            return _imageData = newValue
        }
    }
    
    var metaData: StorageMetadata {
        get {
            return _metaData
        }
        set {
            return _metaData = newValue
        }
    }
    
    
    //Initiate when creating steps
    init(postId: String, stepNum: Int, stepDesc: String, stepImg: UIImage, stepImgUrl: String, imageData: Data, metaData: StorageMetadata) {
        self._postId = postId
        self._stepNum = stepNum
        self._stepDescription = stepDesc
        self._stepImage = stepImg
        self._hasImg = false
        self._stepImgUrl = stepImgUrl
        self._imageData = imageData
        self._metaData = metaData
        
    }
    
    
    //Initiate after downloading from Firebase
    init(stepDetails: Dictionary<String, Any>) {
//        self._detailDescription = detailDesc
        self._postId = nil
        
        if let stepDesc = stepDetails["stepDescription"] as? String {
            self._stepDescription = stepDesc
        }
        
        if let stepNumber = stepDetails["stepNum"] as? Int {
            self._stepNum = stepNumber
        }
        
        if let stepImageUrl = stepDetails["stepImgUrl"] as? String {
            self._stepImgUrl = stepImageUrl
        }
        
        self._stepImage = UIImage()
    }
    
    
    
}
