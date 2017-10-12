//
//  SettingCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-07.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class SettingCell: UITableViewCell {

    @IBOutlet weak var settingImageView: UIImageView!
    @IBOutlet weak var settingTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configureCell(setting: Settings) {
        settingTitleLbl.text = setting.title
        settingImageView.image = setting.image
    }

}
