//
//  LoadingView.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-10-23.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class LoadingView {
    
    let uiView: UIView!
    let message: String!
    let messageLabel = UILabel()
    
    let loadingSV = UIStackView()
    let loadingView = UIView()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
    init(uiView: UIView, message: String) {
        self.uiView = uiView
        self.message = message
        self.setup()
    }
    
    func setup(){
        let viewWidth = uiView.bounds.width
        let viewHeight  = uiView.bounds.height
        
        activityIndicator.hidesWhenStopped = true
        
        // Configuring the message label
        messageLabel.text = message
        messageLabel.textColor = UIColor.white
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 1
        messageLabel.lineBreakMode = .byWordWrapping
        
        // Creating stackView to center and align Label and Activity Indicator
        loadingSV.axis = .vertical
        loadingSV.distribution = .equalSpacing
        loadingSV.alignment = .center
        loadingSV.addArrangedSubview(activityIndicator)
        loadingSV.addArrangedSubview(messageLabel)
        
        // Creating loadingView, this acts as a background for label and activityIndicator
        loadingView.frame = uiView.frame
        loadingView.center = uiView.center
        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
        loadingView.clipsToBounds = true
        
        // Disabling auto constraints
        loadingSV.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
        loadingView.addSubview(loadingSV)
        uiView.addSubview(loadingView)
        activityIndicator.startAnimating()
        
        // Views dictionary
        let views = [
            "loadingSV": loadingSV
        ]
        
        // Constraints for loadingSV
//        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[loadingSV(400)]-|", options: [], metrics: nil, views: views))
        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(viewWidth / 2.4)-[loadingSV(75)]-|", options: [], metrics: nil, views: views))
        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(viewHeight / 2)-[loadingSV(75)]-|", options: [], metrics: nil, views: views))
    }
    
    // Call this method to hide loadingView
    func show() {
        loadingView.isHidden = false
    }
    
    // Call this method to show loadingView
    func hide(){
        loadingView.isHidden = true
    }
    
    // Call this method to check if loading view already exists
    func isHidden() -> Bool{
        if loadingView.isHidden == false{
            return false
        }
        else{
            return true
        }
    }
}
