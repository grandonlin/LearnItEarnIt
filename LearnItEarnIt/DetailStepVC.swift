//
//  DetailStepVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-12.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase

class DetailStepVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    
    var postTitle: String!
    var postId: String!
    var completionImgName: String!
//    var steps = [Step]()
    var imagePicker: UIImagePickerController!
    var selectedIndex: Int!
    var stepCell: StepCell!
    var stepImgName: String!
    var ref: DatabaseReference!
//    var stepCount = 1
    
 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        tableView.delegate = self
        tableView.dataSource = self
        postTitleLbl.text = postTitle
        

//        if steps.count == 0 {
//            let step = Step(postId: postId, stepNum: 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!)
//            steps.append(step)
//        }

        print("Grandon(DetailStepVC): The steps array is: \(steps[0].stepNum), \(steps[0].stepImage), \(steps[0].stepDescription)")

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
            
            let step = steps[indexPath.row]
            cell.stepLbl.text = "Step \(step.stepNum)"
            cell.stepDescTextView.delegate = self
//            cell.selectedIndex = selectedIndex
            cell.configureCell(step: step)
            
//            if step.hasImg {
//                cell.stepImg.removeGestureRecognizer(tapGesture)
//                cell.stepImg.isUserInteractionEnabled = false
//                cell.deleteImgBtn.isHidden = false
//            } else {
//                cell.stepImg.addGestureRecognizer(tapGesture)
//                cell.stepImg.isUserInteractionEnabled = true
//                cell.deleteImgBtn.isHidden = true
//            }
//            cell.stepLbl.text = "Step \(indexPath.row + 1)"
            return cell
        }
        return StepCell()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        var v: UIView = textView
        repeat { v = v.superview!} while !(v is UITableViewCell)
        stepCell = v as! StepCell
        if stepCell.stepDescTextView.text != nil && stepCell.stepDescTextView.text != "" {
            let ip = tableView.indexPath(for: stepCell)!
            let step = steps[ip.row]
            step.stepDescription = stepCell.stepDescTextView.text
            steps[ip.row] = step
            print("Grandon(DetailStepVC): the step information is \(step.stepNum), \(step.stepDescription)")
            DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(selectedIndex+1)").child("stepDescription").setValue(step.stepDescription)
            textView.resignFirstResponder()
        }
    }
 
    
    @IBAction func addStepBtnPressed(_ sender: Any) {
        let newStep = Step(postId: postId, stepNum: steps.count + 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!)
        steps.append(newStep)
        print("Grandon(DetailStepVC): the last step number is \(steps[steps.count-1].stepNum)")

        let indexPath = IndexPath(row: steps.count - 1, section: 0)
//        print("Grandon(DetailStepVC): the index path is \(indexPath.row)")
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        let step = ["stepDescription": "", "stepImgUrl": "https://firebasestorage.googleapis.com/v0/b/learnitearnit-2223f.appspot.com/o/emptyImage.png?alt=media&token=a683e44f-e9ab-4ecc-a5a4-19ad16411a49", "stepNum" : steps.count] as [String : Any]
        DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(steps.count)").updateChildValues(step)
    }
    
    @IBAction func adjustStepBtnPressed(_ sender: Any) {
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        for step in steps {
            let stepDesc = step.stepDescription
            if stepDesc == "" {
                print("Grandon(DetailStepVC): Step \(step.stepNum) does not have a description, are you sure")
            }
        }
    }
    
    
    @IBAction func backBtnPressed(_ sender: Any) {
//        DataService.ds.POST_IMAGE.child(self.postId).delete { (error) in
//            if error != nil {
//                print("Grandon(postCreateVC): not able to delete")
//            }
//        }
//        DataService.ds.REF_USERS_CURRENT.child("myPost").child(self.postId).removeValue()
//        DataService.ds.REF_POSTS.child(self.postId).removeValue()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
        steps.removeAll()
        DataService.ds.POST_IMAGE.child(self.postId).child(self.completionImgName).delete { (error) in
            if error != nil {
                print("Grandon(DetailStepVC): not able to delete \(error)")
            }
        }
        DataService.ds.STEP_IMAGE.child(postId).parent()?.delete { (error) in
            if error != nil {
                print("Grandon(DetailStepVC): unable to delete \(error)")
            }
        }
        DataService.ds.REF_USERS_CURRENT.child("myPost").child(self.postId).removeValue()
        DataService.ds.REF_POSTS.child(self.postId).removeValue()
        performSegue(withIdentifier: "MainVC", sender: nil)
    }

    func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableView)
        let ip = tableView.indexPathForRow(at: location)!
        selectedIndex = ip.row
        print("Grandon(DetailStepVC): the current selected index is \(selectedIndex)")
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
//            var v: UIView = UIImageView()
//            repeat { v = v.superview!} while !(v is UITableViewCell)
//            let cell = v as! StepCell
//            let ip = tableView.indexPath(for: cell)!
//            let step = steps[ip.row]
//            step.stepImage = selectedImage
//            steps[ip.row] = step
            
            let index = NSIndexPath(row: selectedIndex, section: 0) as IndexPath
            if let cell = tableView(tableView, cellForRowAt: index) as? StepCell {
                cell.stepImg.image = selectedImage
            }
            
            let step = steps[selectedIndex]
            step.stepImage = selectedImage
            step.hasImg = true
            steps[selectedIndex] = step
            tableView.reloadRows(at: [index], with: .automatic)
            
            if let imageData = UIImageJPEGRepresentation(selectedImage, 0.5) {
                stepImgName = "Step \(step.stepNum)"
                let metadata = StorageMetadata()
                metadata.contentType = "image/jpeg"
                DataService.ds.STEP_IMAGE.child(postId).child(stepImgName).putData(imageData, metadata: metadata) {
                    (data, error) in
                    if error != nil {
                        print("Grandon(DetailStepVC): unable to upload profile image.")
                    } else {
                        print("Grandon(DetailStepVC): successfully upload profile image.")
                        let imageUrl = data?.downloadURL()?.absoluteString
                        DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(self.selectedIndex + 1)").child("stepImgUrl").setValue(imageUrl)
                    }
                }
            }

//            tableView.reloadData()
            
        }
        dismiss(animated: true, completion: nil)
    }
}



