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
    
    var selectedIndex: Int!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
//        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
//        tapGesture.numberOfTapsRequired = 1
//        stepImg.addGestureRecognizer(tapGesture)
//        stepImg.isUserInteractionEnabled = true
        
        stepDescTextView.delegate = self
        
    }
    
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
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        return true
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        stepDescTextView.resignFirstResponder()
    }
    
    
//    func imageTapped(sender: UITapGestureRecognizer) {
//        selectedIndex = self.stepImg.tag
//        
//    }
//    
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        if let selectedImage: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            self.stepImg.image = selectedImage
//            
//        }
//        imagePicker.dismiss(animated: true, completion: nil)
//    }
    
    
    
    
    

}
