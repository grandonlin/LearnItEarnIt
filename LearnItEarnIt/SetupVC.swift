//
//  SetupVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-29.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class SetupVC: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {


    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var backBtnImageView: FancyBtn!
    @IBOutlet weak var signOutBtnView: UIButton!
    
    var imagePicker: UIImagePickerController!
    var profileImg: UIImage!
    var userName: String!
    var newProfileSetup: Bool! = false
    var imageUrl: String!
    var newProfileImage: Bool! = false
    var setting: Settings!
    var myPostTVCTitle: String!
    
    let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
    }

    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return settings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "SettingCell") as? SettingCell {
            cell.configureCell(setting: settings[indexPath.row])
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 || indexPath.row == 1 {
            setting = settings[indexPath.row]
            performSegue(withIdentifier: "ConfigurationVC", sender: nil)
        } else if indexPath.row == 2 {
            myPostTVCTitle = "My Posts"
            performSegue(withIdentifier: "MyPostTVC", sender: nil)
        } else if indexPath.row == 3 {
            myPostTVCTitle = "My Favourites"
            performSegue(withIdentifier: "MyPostTVC", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ConfigurationVC {
            let configurationTitle = setting.title
            destination.configurationTitle = configurationTitle
        }
        
        if let destination = segue.destination as? MyPostTVC {
            destination.pageTitle = myPostTVCTitle
        }
    }
    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    @IBAction func profileImgTapped(_ sender: Any) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }

    @IBAction func backBtnTapped(_ sender: Any) {
        if newProfileSetup == true {
            performSegue(withIdentifier: "ProfileVC", sender: nil)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @IBAction func signOutBtnTapped(_ sender: Any) {
        do {
            try Auth.auth().signOut()
            KeychainWrapper.standard.removeObject(forKey: KEY_UID)
            print("Grandon(SetupVC): the current key is \(KeychainWrapper.standard.string(forKey: KEY_UID))")
            performSegue(withIdentifier: "LoginVC", sender: nil)
        } catch let err as NSError {
            print(err.debugDescription)
        }
        
    }
}
