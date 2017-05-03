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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Download image
        DataService.ds.REF_USERS.observe(.value, with: { (snapshot) in
            print("Grandon: the snapshot value is \(snapshot.value!)")
            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
                for snap in snapshot {
                    print("SNAPSHOT: \(snap)")
                    if let userDict = snap.value as? Dictionary<String, Any> {
                        print("User Dict: \(userDict)")
                        let key = snap.key
                        print("Key is \(key)")
                        let key1 = DataService.ds.REF_USERS.child(key)
                        print("Key from user is: \(key1)")
                        //self.profile = Profile(profileKey: key, profileData: userDict)
                    }
                }
            }
            
        })
        
        
        
//        let ref = FIRStorage.storage().reference(forURL: profile.profileImageUrl)
//        ref.data(withMaxSize: 1024 * 1024) { (data, error) in
//            if error != nil {
//                print("Grandon: the error is \(error)")
//            } else {
//                if let img = UIImage(data: data!) {
//                    self.profileImg.image = img
//                }
//                
//            }
//        }
        
//        DataSservice.ds.REF_POSTS.observe(.value, with: { (snapshot) in
//            if let snapshot = snapshot.children.allObjects as? [FIRDataSnapshot] {
//                for snap in snapshot {
//                    print("SNAP: \(snap)")
//                    if let postDict = snap.value as? Dictionary<String, Any> {
//                        let key = snap.key
//                        let post = Post(postKey: key, postData: postDict)
//                        self.posts.append(post)
//                    }
//                }
//            }
//            self.tableView.reloadData()
//        })

        
    }
    
    
    

    

    
    @IBAction func settingBtnTapped(_ sender: Any) {
        
        performSegue(withIdentifier: "SetupVC", sender: sender)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

}
