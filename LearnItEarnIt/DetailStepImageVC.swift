//
//  DetailStepImageVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-11-02.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class DetailStepImageVC: UIViewController {

    @IBOutlet weak var stepImage: UIImageView!

    var image: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stepImage.image = image
    }

    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }


}
