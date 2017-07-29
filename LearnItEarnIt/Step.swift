//
//  Step.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class Step {
    private var _stepNum: Int!
//    private var _detailDescription: String!
    private var _stepDescription: String!
    private var _stepImgUrl: String!
    private var _stepImage: UIImage
    private var _postId: String!
    
//    var detailDescription: String {
//        return _detailDescription
//    }
    
    var stepNum: Int {
        return _stepNum
    }
    
    var stepDescription: String {
        return _stepDescription
    }
    
    var stepImgUrl: String {
        return _stepImgUrl
    }
    
    var stepImage: UIImage {
        return _stepImage
    }
    
    var postId: String {
        return _postId
    }
    
    //Initiate when creating steps
    init(postId: String, stepNum: Int, stepDesc: String, stepImg: UIImage) {
        self._postId = postId
        self._stepNum = stepNum
        self._stepDescription = stepDesc
        self._stepImage = stepImg
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
