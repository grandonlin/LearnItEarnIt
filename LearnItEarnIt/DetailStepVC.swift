//
//  DetailStepVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-12.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit

class DetailStepVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var postTitle: String!
    var postId: String!
    var steps = [Step]()
    var imagePicker: UIImagePickerController!
    var selectedIndex: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
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
        print("Grandon(DetailStepVC): there are \(steps.count) steps.")
        return steps.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: "StepCell", for: indexPath) as? StepCell {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
            tapGesture.numberOfTapsRequired = 1
            cell.stepImg.addGestureRecognizer(tapGesture)
            cell.stepImg.isUserInteractionEnabled = true
//            let step = steps[indexPath.row]
//            cell.configureCell(step: step)
            cell.stepLbl.text = "Step \(indexPath.row + 1)"
            selectedIndex = indexPath.row
            print("Grandon(DetailStepVC): the current selectedIndex is \(selectedIndex)")
            cell.stepImg.tag = indexPath.row
            print("Grandon(DetailStepVC): the cell image tag is \(cell.stepImg.tag)")
            return cell
        }
        return StepCell()
    }
    
    
    
    @IBAction func addStepBtnPressed(_ sender: Any) {
        let newStep = Step(postId: postId, stepNum: steps.count + 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!)
        steps.append(newStep)
        print("Grandon(DetailStepVC): \(steps.last?.stepNum)")
        let indexPath = IndexPath(row: steps.count - 1, section: 0)
        print("Grandon(DetailStepVC): the index path is \(indexPath.row)")
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

    func imageTapped(_ sender: UITapGestureRecognizer) {
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            let index = NSIndexPath(row: selectedIndex, section: 0)
            let cell = tableView.cellForRow(at: index as IndexPath) as! StepCell
                cell.stepImg.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
}
