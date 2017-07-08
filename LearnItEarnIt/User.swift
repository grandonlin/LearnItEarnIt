//
//  User.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-05-02.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import Foundation

class User {
    
    private var _userId: String!
    
    var userId: String {
        return _userId
    }
    
    init(id: String) {
        self._userId = id
    }
}
