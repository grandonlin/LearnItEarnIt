//
//  PostCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-21.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class PostCell: UITableViewCell {

    @IBOutlet weak var cellTitleLbl: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var likeNumLbl: UILabel!
    
    
    func configureCell(post: Post) {
        cellTitleLbl.text = post.title
        cellImg.image = UIImage(named: "finishedPic")
    }

}
