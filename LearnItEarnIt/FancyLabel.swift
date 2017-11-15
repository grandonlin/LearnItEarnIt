//
//  FancyLabel.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-11-14.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class FancyLabel: UILabel {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layer.cornerRadius = 15
        layer.masksToBounds = true
    }
}
