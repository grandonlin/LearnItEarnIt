//
//  MyPostCell.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-09.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class MyPostCell: UITableViewCell {

    @IBOutlet weak var postCellImage: UIImageView!
    @IBOutlet weak var postDateLbl: UILabel!
    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var postDescLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configurePostCell(post: Post) {
        let imgUrl = post.postImgUrl
        let cellImgRef = Storage.storage().reference(forURL: imgUrl)
        cellImgRef.getData(maxSize: 2 * 1024 * 1024) { (data, error) in
            if error != nil {
                print("Grandon: not able to create image")
            } else {
                if let img = UIImage(data: data!) {
                    self.postCellImage.image = img
                }
            }
        }
        self.postTitleLbl.text = post.title
        self.postDateLbl.text = "\(post.created)"
        self.postDescLbl.text = post.postDescription
    }

}
