//
//  PostVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-04-22.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class PostVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var productDescription: UITextView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var likeBtnImg: CircleButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    var steps = [Step]()
    var postKey: String!
    var vcTitle: String!
    let emptyHeartImg = UIImage(named: "empty-heart")
    let filledHeartImg = UIImage(named: "filled-heart")
    var myLikeRef: DatabaseReference!
    var initialLike: Bool!
    var finalLike: Bool!
    var likeChange: Bool!
    var isNewPost: Bool = false
    var isMyPost: Bool = false
    var loadingView: LoadingView!
    var selectedImage: UIImage!
    var stepLoaded = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        postTitleLbl.text = vcTitle
        print("Grandon(PostVC): the post key is \(postKey)")
        
//        loadingView = LoadingView(uiView: view)
        
        activityIndicator.startAnimating()
        
        loadPost()
        
    
    }
    

    
    override func viewDidAppear(_ animated: Bool) {
//        loadingView.hide()
        if checkStepLoaded(steps: steps) {
            activityIndicator.stopAnimating()
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let step = steps[indexPath.row]
        
        if let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell") as? ProductCell {
            cell.configureCell(step: step)
            return cell
        }
        return ProductCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! ProductCell
        selectedImage = cell.stepImg.image
        performSegue(withIdentifier: "DetailStepImageVC", sender: selectedImage)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? DetailStepImageVC {
            destination.image = selectedImage
        }
    }
  
    @IBAction func likeBtnPressed(_ sender: Any) {
//        loadingView = LoadingView(uiView: view)
        activityIndicator.startAnimating()
        let likeRef = DataService.ds.REF_POSTS.child(postKey).child("likes")
        var likes: Int!
        likeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let likesNum = snapshot.value as? Int {
                likes = likesNum
                if self.likeBtnImg.currentImage != UIImage(named: "filled-heart") {
                    let filledHeartImg = UIImage(named: "filled-heart")
                    self.likeBtnImg.setImage(filledHeartImg, for: .normal)
                    likes = likes + 1
                    DataService.ds.REF_USERS_CURRENT_LIKE.child(self.postKey!).setValue(true)
                    self.finalLike = true
                    
                } else {
                    let emptyHeartImg = UIImage(named: "empty-heart")
                    self.likeBtnImg.setImage(emptyHeartImg, for: .normal)
                    likes = likes - 1
                    DataService.ds.REF_USERS_CURRENT_LIKE.child(self.postKey!).removeValue()
                    self.finalLike = false
                }
                let likeData = ["likes": likes!]
                DataService.ds.REF_POSTS.child(self.postKey).updateChildValues(likeData)
            }
        })
//        loadingView.hide()
        activityIndicator.stopAnimating()
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        if isNewPost {
            performSegue(withIdentifier: "MainVC", sender: sender)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }
    
    func loadPost() {
        myLikeRef = DataService.ds.REF_USERS_CURRENT_LIKE.child(postKey)
        myLikeRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? NSNull {
                self.likeBtnImg.setImage(self.emptyHeartImg, for: .normal)
                self.initialLike = false
                self.finalLike = false
            } else {
                self.likeBtnImg.setImage(self.filledHeartImg, for: .normal)
                self.initialLike = true
                self.finalLike = true
            }
        })
        
        let postTitleRef = DataService.ds.REF_POSTS.child(postKey).child("postTitle")
        postTitleRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let postTitle = snapshot.value as? String {
                self.postTitleLbl.text = postTitle
            }
        })
        
        
        let detailDescRef = DataService.ds.REF_POSTS.child(postKey).child("steps")
        detailDescRef.observeSingleEvent(of: .value, with: { (snapshot) in
            if let stepDetails = snapshot.value as? Dictionary<String, Any> {
                if let detailDesc = stepDetails["detailDescription"] as? String {
                    self.productDescription.text = detailDesc
                }
            }
        })
        
        
        let stepRef = DataService.ds.REF_POSTS.child(postKey).child("steps").child("stepDetails")
        stepRef.queryOrderedByKey().observe(.value, with: { (snapshot) in
            print("Grandon(PostVC): snapshot is \(snapshot)")
            if let snapshot = snapshot.children.allObjects as? [DataSnapshot] {
                for snap in snapshot {
                    if let stepDict = snap.value as? Dictionary<String, Any> {
                        let step = Step(stepDetails: stepDict)
                        print("Grandon(PostVC): step description is \(step.stepDescription)")
                        self.steps.append(step)
                        self.stepLoaded += 1
                    }
                }
            }
            self.tableView.reloadData()
        })
    }
    
    func checkStepLoaded(steps: [Step]) -> Bool {
        if stepLoaded == steps.count {
            return true
        }
        return false
    }
}
