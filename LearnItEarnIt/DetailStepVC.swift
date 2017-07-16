//
//  DetailStepVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-12.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class DetailStepVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var postTitle: String!
    var postId: String!
    var steps = [Step]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        postTitleLbl.text = postTitle
        
        let step = Step(postId: postId, stepNum: 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!)
        steps.append(step)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as? StepCell {
            let step = steps[indexPath.row]
            cell.configureCell(step: step)
            return cell
        }
        return StepCell()
    }
    
    
    
    @IBAction func addStepBtnPressed(_ sender: Any) {
        let newStep = Step(stepNum: steps.count + 1)
        steps.append(newStep)
        let indexPath = IndexPath(row: steps.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
    }
    
    @IBAction func adjustStepBtnPressed(_ sender: Any) {
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
        DataService.ds.POST_IMAGE.child(self.postId).delete { (error) in
            if error != nil {
                print("Grandon(postCreateVC): not able to delete")
            }
        }
        DataService.ds.REF_USERS_CURRENT.child("myPost").child(self.postId).removeValue()
        DataService.ds.REF_POSTS.child(self.postId).removeValue()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        DataService.ds.POST_IMAGE.child(self.postId).delete { (error) in
            if error != nil {
                print("Grandon(postCreateVC): not able to delete")
            }
        }
        DataService.ds.REF_USERS_CURRENT.child("myPost").child(self.postId).removeValue()
        DataService.ds.REF_POSTS.child(self.postId).removeValue()
        performSegue(withIdentifier: "MainVC", sender: nil)
    }

}
