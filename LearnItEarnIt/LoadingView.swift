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
//    let message: String!
    let messageLabel = UILabel()
    
//    let loadingSV = UIStackView()
//    let loadingView = UIView()
    let backgroundView = UIView()
    let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
    
//    init(uiView: UIView, message: String) {
//        self.uiView = uiView
////        self.message = message
//        self.setup()
//    }
    
    init(uiView: UIView) {
        self.uiView = uiView
        //        self.message = message
        self.setup()
    }
    
    func setup(){
//        let viewWidth = uiView.bounds.width
//        let viewHeight  = uiView.bounds.height
        
        
//        activityIndicator.color = UIColor.red
        
        // Configuring the message label
//        messageLabel.text = message
//        messageLabel.textColor = UIColor.white
//        messageLabel.textAlignment = .center
//        messageLabel.numberOfLines = 1
//        messageLabel.lineBreakMode = .byWordWrapping
        
        backgroundView.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        print("Grandon(LoadingView): the backgroundView's frame is \(backgroundView.frame)")
        backgroundView.center = uiView.center
        backgroundView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 10
        
//        activityIndicator.frame.size.width = 40
//        activityIndicator.frame.size.height = 40
//        activityIndicator.center = CGPoint(x: backgroundView.frame.width / 2, y: backgroundView.frame.height / 2)
        activityIndicator.frame = CGRect(x: backgroundView.frame.width / 4, y: backgroundView.frame.height / 4, width: 40, height: 40)
        
        print("Grandon(LoadingView): the backgroundView's frame's width is \(backgroundView.frame.width)")
        print("Grandon(LoadingView): the AI's x is \(activityIndicator.frame.origin)")
//        activityIndicator.center = backgroundView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = UIColor.red
        
        // Creating stackView to center and align Label and Activity Indicator
//        loadingSV.axis = .vertical
//        loadingSV.distribution = .equalSpacing
//        loadingSV.alignment = .center
//        loadingSV.addArrangedSubview(activityIndicator)
//        loadingSV.addArrangedSubview(messageLabel)
        
        // Creating loadingView, this acts as a background for label and activityIndicator
//        loadingView.frame = uiView.frame
//        loadingView.center = uiView.center
//        loadingView.backgroundColor = UIColor.darkGray.withAlphaComponent(0.3)
//        loadingView.clipsToBounds = true
        

        
        // Disabling auto constraints
//        loadingSV.translatesAutoresizingMaskIntoConstraints = false
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
        
        // Adding subviews
//        loadingView.addSubview(backgroundView)
        backgroundView.addSubview(activityIndicator)
        uiView.addSubview(backgroundView)
//        uiView.addSubview(loadingView)
//        activityIndicator.startAnimating()
        
        // Views dictionary
//        let views = [
////            "loadingSV": loadingSV
//            "backgroundView": backgroundView
//        ]
        
        // Constraints for loadingSV
//        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-[loadingSV(400)]-|", options: [], metrics: nil, views: views))
//        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "H:|-\(viewWidth / 2.4)-[backgroundView(75)]-|", options: [], metrics: nil, views: views))
//        uiView.addConstraints(NSLayoutConstraint.constraints(withVisualFormat: "V:|-\(viewHeight / 2)-[backgroundView(75)]-|", options: [], metrics: nil, views: views))
    }
    
    // Call this method to hide loadingView
    func show() {
        backgroundView.isHidden = false
        activityIndicator.startAnimating()
    }
    
    // Call this method to show loadingView
    func hide(){
        backgroundView.isHidden = true
        activityIndicator.stopAnimating()
    }
    
    // Call this method to check if loading view already exists
    func isHidden() -> Bool{
        if backgroundView.isHidden == false{
            return false
        }
        else{
            return true
        }
    }
}
