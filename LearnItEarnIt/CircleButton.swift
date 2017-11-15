//
//  CircleButton.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-21.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class CircleButton: UIButton {

    override func layoutSubviews() {
        super.layoutSubviews()
        
    }
    
    func circleWidth() {
        layer.cornerRadius = self.frame.width / 2
        imageView?.contentMode = .scaleAspectFit
    }
    
    func circleHeight() {
        layer.cornerRadius = self.frame.height / 2
        imageView?.contentMode = .scaleAspectFit
    }
}
