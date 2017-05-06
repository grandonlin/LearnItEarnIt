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
    @IBOutlet weak var profileUserLbl: UILabel!
    @IBOutlet weak var recentCompletedImg: UIImageView!
    @IBOutlet weak var genderLbl: UILabel!

    static var imageCache: NSCache<NSString, UIImage> = NSCache()
    
    var profile: Profile!
//    var profileDownloaded = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if profileDownloaded {
//            if let img = ProfileVC.imageCache.object(forKey: self.profile.profileImgUrl as NSString) {
//                profileImg.image = img
//            }
//        } else {
            downloadProfileData()
//        }
        
    }

    func downloadProfileData() {
        let profileKey = KeychainWrapper.standard.string(forKey: KEY_UID)!
        print("profileKey is set as: \(profileKey)")
        
        //Download image
//        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
//            print("Grandon: the snapshot value is \(snapshot.value!)")
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    print("SNAPSHOT: \(snap)")
//                    if let snapProfile = snap.value as? Dictionary<String, Any> {
//                        if let profileDict = snapProfile["profile"] as? Dictionary<String, Any> {
//                            print("Profile Dict: \(profileDict)")
//                            let key = snap.key
//                            print("Key is \(key)")
//                            if key == profileKey {
//                                self.profile = Profile(profileKey: key, profileData: profileDict)
//                                print(self.profile.profilekey)
//                                print(self.profile.profileImgUrl)
//                                self.genderLbl.text = self.profile.gender
//                                self.profileUserLbl.text = self.profile.userName
//                                let ref = FIRStorage.storage().reference(forURL: self.profile.profileImgUrl)
//                                ref.data(withMaxSize: 1024 * 1024) { (data, error) in
//                                    if error != nil {
//                                        print("Grandon: the error is \(error)")
//                                    } else {
//                                        if let img = UIImage(data: data!) {
//                                            self.profileImg.image = img
//                                            ProfileVC.imageCache.setObject(img, forKey: self.profile.profileImgUrl as NSString)
//                                            self.profileDownloaded = true
//                                        }
//                                    }
//                                }
//                            }
//                        }
//                    }
//                }
//            }
//        })
        
        let ref = DataService.ds.REF_USERS.child(profileKey).child("profile")
        ref.observe(.value, with: { (snapshot) in
            if let profileDict = snapshot.value as? Dictionary<String, Any> {
                print("Grandon: snapshot is \(snapshot)")
                self.profile = Profile(profileKey: profileKey, profileData: profileDict)
                self.genderLbl.text = self.profile.gender
                self.profileUserLbl.text = self.profile.userName
                let profileRef = FIRStorage.storage().reference(forURL: self.profile.profileImgUrl)
                profileRef.data(withMaxSize: 1024 * 1024, completion: { (data, error) in
                    if error != nil {
                        print("Grandon: the error is \(error)")
                    } else {
                        if let img = UIImage(data: data!) {
                            self.profileImg.image = img
                            
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
            if let image = self.profileImg.image, let username = self.profileUserLbl.text, let gender = self.genderLbl.text {
                destination.profileImg = image
                destination.userName = username
                destination.genderSelected = gender
            }
        }
        
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
