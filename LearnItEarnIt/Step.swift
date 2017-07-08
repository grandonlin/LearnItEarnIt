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
    private var _detailDescription: String!
    private var _stepDescription: String!
    private var _stepImgUrl: String!
    
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
    
    init(stepDetails: Dictionary<String, Any>) {
//        self._detailDescription = detailDesc
        
        if let stepDesc = stepDetails["stepDescription"] as? String {
            self._stepDescription = stepDesc
        }
        
        if let stepNumber = stepDetails["stepNum"] as? Int {
            self._stepNum = stepNumber
        }
        
        if let stepImageUrl = stepDetails["stepImgUrl"] as? String {
            self._stepImgUrl = stepImageUrl
        }
    }
}
