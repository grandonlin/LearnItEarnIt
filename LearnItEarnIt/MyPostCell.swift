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
        let daysPassed = calculateInterval(post: post)
        assignPostDateLbl(daysPassed: daysPassed, post: post)
        self.postDescLbl.text = post.postDescription
    }
    
    func calculateInterval(post: Post) -> Int {
        let currentDate = NSDate()
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = df.date(from: post.created)!
        let interval = currentDate.timeIntervalSince(date as Date)
        return Int(interval) / 259200
    }

    func assignPostDateLbl(daysPassed: Int, post: Post) {
        if  daysPassed > 3 {
            self.postDateLbl.text = "\(daysPassed)ds ago"
        } else {
            let date = post.created
            let index = date.index(date.startIndex, offsetBy: 10)
            let shortDate = date.substring(to: index)
            self.postDateLbl.text = "\(shortDate)"
        }
    }
    
}
