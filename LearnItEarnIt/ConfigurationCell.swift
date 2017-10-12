//
//  ConfigurationCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-09.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class ConfigurationCell: UITableViewCell {
    
    @IBOutlet weak var confiLbl: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(setting: Settings) {
        self.confiLbl.text = setting.title
    }
    
}
