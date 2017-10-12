//
//  Settings.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-07.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class Settings {
    private var _image: UIImage!
    private var _title: String!
    
    var image: UIImage {
        return _image
    }
    
    var title: String {
        return _title
    }
    
    init(title: String) {
        self._title = title
    }
    
    init(title: String, image: UIImage) {
        self._title = title
        self._image = image
    }
}
