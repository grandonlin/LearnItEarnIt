//
//  ConfigurationVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-09-08.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class ConfigurationVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var configurationTitleLbl: UILabel!
    @IBOutlet weak var configTableView: UITableView!
    
    var configurationTitle: String!
    var profileSettings: [Settings]!
    var securitySettings: [Settings]!
    var postSettings: [String]! = [String]()
    var favouriteSettings: [String]! = [String]()
    let profileImage = Settings(title: "Profile Image")
    let name = Settings(title: "Name")
    let gender = Settings(title: "Gender")
    let password = Settings(title: "Password")
    var detailSettingVCTitle: String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configurationTitleLbl.text = configurationTitle
        
        configTableView.dataSource = self
        configTableView.delegate = self
        
    }

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch configurationTitle {
        case "Personal":
            profileSettings = [profileImage, name, gender]
            return profileSettings.count
        case "Security":
            securitySettings = [password]
            return securitySettings.count
        default:
            return 0
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ConfigurationCell") as? ConfigurationCell {
            if configurationTitle == "Personal" {
                cell.configureCell(setting: profileSettings[indexPath.row])
            } else if configurationTitle == "Security" {
                cell.configureCell(setting: securitySettings[indexPath.row])
            }
            return cell
            }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if configurationTitle == "Personal" {
            if indexPath.row == 0 {
                detailSettingVCTitle = "Profile Image"
            } else if indexPath.row == 1 {
                detailSettingVCTitle = "Name"
            } else if indexPath.row == 2 {
                detailSettingVCTitle = "Gender"
            }
        } else if configurationTitle == "Security" {
            if indexPath.row == 0 {
                detailSettingVCTitle = "Password"
            }
        }
        
        performSegue(withIdentifier: "DetailSettingVC", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailSettingVC {
            destination.detailSettingTitle = detailSettingVCTitle
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
