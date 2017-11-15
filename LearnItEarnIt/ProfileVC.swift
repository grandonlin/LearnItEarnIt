//
//  ProfileVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-24.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class ProfileVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var profileImg: CircleView!
    @IBOutlet weak var profileUserLbl: FancyLabel!
    @IBOutlet weak var recentCompletedImg: UIImageView!
    @IBOutlet weak var genderLbl: FancyLabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!

//    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var profile: Profile!
    var handle: UInt!
    var ref: DatabaseReference!
    var completionImage: UIImage!
//    var indicator = UIActivityIndicatorView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        loadingView = LoadingView(uiView: view)
//        loadingView.show()
        
        
        activityIndicator.startAnimating()
//        downloadProfileData()

    }
    
    override func viewWillAppear(_ animated: Bool) {
        downloadProfileData()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
//        loadingView.hide()
        activityIndicator.stopAnimating()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        ref.removeObserver(withHandle: handle)
    }

    func downloadProfileData() {
        let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
        print("Grandon(ProfileVC): profileKey is set as: \(profileKey)")
                
        //Download profile data
        ref = DataService.ds.REF_USERS.child(profileKey).child("profile")
        handle = ref.observe(.value, with: { (snapshot) in
            if let profileDict = snapshot.value as? Dictionary<String, Any> {
                print("Grandon(ProfileVC): snapshot is \(snapshot)")
                self.profile = Profile(profileKey: profileKey, profileData: profileDict)
                self.genderLbl.text = self.profile.gender
                self.profileUserLbl.text = self.profile.userName
                let profileRef = Storage.storage().reference(forURL: self.profile.profileImgUrl)
                profileRef.getData(maxSize: 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Grandon(ProfileVC): the error is \(error)")
                    } else {
                        if let img = UIImage(data: data!) {
                            self.profileImg.image = img
                            
                        }
                    }
                })
                let completionRef = Storage.storage().reference(forURL: self.profile.recentCompletionImgUrl)
                completionRef.getData(maxSize: 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Grandon(ProfileVC): the error is \(error)")
                    } else {
                        if let img = UIImage(data: data!) {
                            self.recentCompletedImg.image = img
                        }
                    }
                })
            }
        })
    }

    @IBAction func settingBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "SetupVC", sender: sender)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SetupVC {
            if let username = self.profileUserLbl.text {
                print("Grandon(ProfileVC): the username is \(username)")
                KeychainWrapper.standard.set(username, forKey: CURRENT_USERNAME)
                destination.userName = username
            }
        }
        if let destination = segue.destination as? RecentCompletionVC {
            if let image = self.recentCompletedImg.image {
                destination.completionImage = image
            }
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        performSegue(withIdentifier: "MainVC", sender: sender)
    }

}
