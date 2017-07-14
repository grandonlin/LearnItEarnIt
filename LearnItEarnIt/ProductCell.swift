//
//  ProductCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class ProductCell: UITableViewCell {

    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var stepImg: UIImageView!
    @IBOutlet weak var stepDescription: UILabel!
    
    func configureCell(step: Step) {
        stepLbl.text = "Step \(step.stepNum)"
        stepDescription.text = step.stepDescription
        
        let imageUrl = step.stepImgUrl
        let imageRef = Storage.storage().reference(forURL: imageUrl)
        imageRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("Grandon: the error is \(error)")
            } else {
                if let img = UIImage(data: data!) {
                    self.stepImg.image = img
                }
            }
        }
    }


}
