//
//  ProductCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class ProductCell: UITableViewCell {

    @IBOutlet weak var stepLbl: UILabel!
    @IBOutlet weak var stepImg: UIImageView!
    @IBOutlet weak var stepDescription: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configureCell(step: Step) {
        stepLbl.text = "Step \(step.stepNum)"
        //stepImg.image = UIImage(named: step.)
        //stepDescription.text = step.
    }


}
