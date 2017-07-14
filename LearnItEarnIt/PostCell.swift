//
//  PostCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-21.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class PostCell: UITableViewCell {

    @IBOutlet weak var cellTitleLbl: UILabel!
    @IBOutlet weak var cellImg: UIImageView!
    @IBOutlet weak var likeNumLbl: UILabel!
    
    
    func configureCell(post: Post) {
        cellTitleLbl.text = post.title
        likeNumLbl.text = "\(post.likes)"
        
        let imageUrl = post.postImgUrl
        let cellImgRef = Storage.storage().reference(forURL: imageUrl)
        cellImgRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("Grandon: not able to create image")
            } else {
                if let img = UIImage(data: data!) {
                    self.cellImg.image = img
                }
            }
        }
        
    }

    
}
