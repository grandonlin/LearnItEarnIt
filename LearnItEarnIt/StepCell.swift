//
//  StepCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-15.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class StepCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var stepImg: UIImageView!
    @IBOutlet weak var stepDescTextView: UITextView!
    
//    func initCell(step: Step) {
//        stepLbl.text = "Step \(step.stepNum)"
//        stepImg.image = UIImage(named: "emptyImage")
//        stepDescTextView.text = ""
//    }
    
    func configureCell(step: Step) {
        stepLbl.text = "Step \(step.stepNum)"
        stepImg.image = step.stepImage
        stepDescTextView.text = step.stepDescription
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        
        
    }
    
}
