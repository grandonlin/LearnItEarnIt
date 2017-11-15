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
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleBackgroundTap))
        tapRecognizer.cancelsTouchesInView = false
        self.addGestureRecognizer(tapRecognizer)
        
        stepDescTextView.delegate = self
        
        let toolBar = UIToolbar()
        toolBar.sizeToFit()
        
        let doneButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(doneClicked))
        
        toolBar.setItems([doneButton], animated: false)
        
        self.stepDescTextView.inputAccessoryView = toolBar
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardUP), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDOWN), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        loadingView = LoadingView(uiView: UIView())
        loadingView.hide()
        
    }
    
//    func initCell(step: Step) {
//        stepLbl.text = "Step \(step.stepNum)"
//        stepImg.image = UIImage(named: "emptyImage")
//        stepDescTextView.text = ""
//    }
    
    func handleBackgroundTap(sender: UITapGestureRecognizer) {
        self.stepDescTextView.resignFirstResponder()
    }
    
    func configureCell(step: Step) {
        stepLbl.text = "Step \(step.stepNum)"
        stepImg.image = step.stepImage
        stepDescTextView.text = step.stepDescription
    }
    
    func loadCell(step: Step) {
        stepLbl.text = "Step \(step.stepNum)"
        stepDescTextView.text = step.stepDescription
        let stepImgRef = Storage.storage().reference(forURL: step.stepImgUrl)
        stepImgRef.getData(maxSize: 1024 * 1024, completion: { (data, error) in
            if error != nil {
                print("Grandon(StepCell): the error is \(error)")
            } else {
                if let img = UIImage(data: data!) {
                    self.stepImg.image = img
                }
            }
        })
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        
        stepDescTextView.becomeFirstResponder()
        
        return true
    }
    
    func keyboardUP(notification: Notification) {
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.frame.origin.y -= keyboardSize.height - 50
        }
    }
    
    func keyboardDOWN(notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            self.frame.origin.y += keyboardSize.height - 50
        }
    }
    
    func doneClicked() {
        stepDescTextView.endEditing(true)
    }
    
    override func prepareForReuse() {
        loadingView.hide()
    }



}
