//
//  DetailStepVC.swift
//  LearnItEarnIt
//
//  Created by Grandon Lin on 2017-07-12.
//  Copyright © 2017 Grandon Lin. All rights reserved.
//

import UIKit
import Firebase
import SwiftKeychainWrapper

class DetailStepVC: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var postTitleLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var adjustBtn: UIButton!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var postBtn: UIButton!
    @IBOutlet weak var backBtn: FancyBtn!
    
    var postTitle: String!
    var postId: String!
    var completionImgName: String!
    var imagePicker: UIImagePickerController!
    var selectedIndex: Int!
    var stepCell: StepCell!
    var stepImgName: String!
    var ref: DatabaseReference!
    var indicator = UIActivityIndicatorView()
    var number: Int!
    var stepRef = DataService.ds.REF_POSTS
    var stepImgRef = DataService.ds.STEP_IMAGE
    var loadingView: LoadingView!
//    var stepCount = 1

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        
        tableView.delegate = self
        tableView.dataSource = self
        
        indicator.center = self.view.center
        indicator.frame = CGRect(x: self.view.center.x, y: self.view.center.y, width: 4.0, height: 4.0)
        indicator.hidesWhenStopped = true
        indicator.activityIndicatorViewStyle = .whiteLarge
        indicator.color = UIColor.red
        self.view.addSubview(indicator)
        
        postTitleLbl.text = postTitle

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
            cell.stepDescTextView.delegate = self
//            cell.selectedIndex = selectedIndex
            cell.configureCell(step: step)

            return cell
        }
        return StepCell()
    }
    
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
//        indicator.startAnimating()
        loadingView = LoadingView(uiView: view, message: "Updating...")
        self.view.isUserInteractionEnabled = false
        let sourceStep = steps[sourceIndexPath.row]
        print("Grandon(DetailStepVC): the sourceIndexPath is \(sourceIndexPath.row)")
        print("Grandon(DetailStepVC): the destinationIndexPath is \(destinationIndexPath.row)")
//        let destinationStep = steps[destinationIndexPath.row]
//            0     1      2      3      4      5
//        [Step1, Step2, Step3, Step4, Step5, Step6]
//        [Step1, Step4, Step2, Step3, Step4, Step5, Step6]
//        [Step1, Step4, Step2, Step3, Step5, Step6]
//        [Step1, Step4, Step3, Step4, Step5, Step6]

        if sourceIndexPath.row > destinationIndexPath.row {
            steps.insert(sourceStep, at: destinationIndexPath.row)
            steps.remove(at: sourceIndexPath.row + 1)
            
//            destinationStep.stepNum = destinationIndexPath.row + 1
            for step in steps {
                
                if step.stepNum > destinationIndexPath.row && step.stepNum <= sourceIndexPath.row {
                    print("Grandon(DetailStepVC): step \(step.stepNum) is going to be changed")
                    step.stepNum += 1
                    updateStepDetail(step: step)
                }
            }
            print("Grandon(DetailStepVC): the destination index path is now \(destinationIndexPath.row)")
            let destStep = steps[destinationIndexPath.row]
            destStep.stepNum = destinationIndexPath.row + 1
            updateStepDetail(step: destStep)
            print("Grandon(DetailStepVC): this is step number \(destStep.stepNum), step description is \(destStep.stepDescription)")
            
        } else {
            steps.insert(sourceStep, at: destinationIndexPath.row + 1)
            steps.remove(at: sourceIndexPath.row)
//                0       1      2      3      4      5
//            [Step1, Step2, Step3, Step4, Step5, Step6]
//            [Step1, Step3, Step4, Step2, Step5, Step6]
            for step in steps {
                if step.stepNum > sourceIndexPath.row + 1 && step.stepNum <= destinationIndexPath.row + 1 {
                    print("Grandon(DetailStepVC): step \(step.stepNum) is going to be changed")
                    step.stepNum -= 1
                    updateStepDetail(step: step)
                }
                print("Grandon(DetailStepVC): this is step number \(step.stepNum), step description is \(step.stepDescription)")
            }
        }
        print("Grandon(DetailStepVC): the destination index path is now \(destinationIndexPath.row)")
        let destStep = steps[destinationIndexPath.row]
        destStep.stepNum = destinationIndexPath.row + 1
        updateStepDetail(step: destStep)
//        indicator.stopAnimating()
        loadingView.hide()
        self.view.isUserInteractionEnabled = true
        print("Grandon(DetailStepVC): this is step number \(destStep.stepNum), step description is \(destStep.stepDescription)")
    }
    
    
    
    func textViewDidEndEditing(_ textView: UITextView) {
//        indicator.startAnimating()
        loadingView = LoadingView(uiView: view, message: "")
        self.view.isUserInteractionEnabled = false
        var v: UIView = textView
        repeat { v = v.superview!} while !(v is UITableViewCell)
        stepCell = v as! StepCell
        if stepCell.stepDescTextView.text != nil && stepCell.stepDescTextView.text != "" {
            let ip = tableView.indexPath(for: stepCell)!
            let step = steps[ip.row]
            step.stepDescription = stepCell.stepDescTextView.text
            steps[ip.row] = step
            print("Grandon(DetailStepVC): the step information is \(step.stepNum), \(step.stepDescription)")
            DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(step.stepNum)").child("stepDescription").setValue(step.stepDescription)
            textView.resignFirstResponder()
        }
//        indicator.stopAnimating()
        loadingView.hide()
        self.view.isUserInteractionEnabled = true
    }
    
    @IBAction func addStepBtnPressed(_ sender: Any) {
//        indicator.startAnimating()
        loadingView = LoadingView(uiView: view, message: "")
        self.view.isUserInteractionEnabled = false
        let stepImgUrl = INIT_IMG_URL
        let newStep = Step(postId: postId, stepNum: steps.count + 1, stepDesc: "", stepImg: UIImage(named: "emptyImage")!, stepImgUrl: stepImgUrl, imageData: Data(), metaData: StorageMetadata())
        steps.append(newStep)
        print("Grandon(DetailStepVC): the last step number is \(steps[steps.count-1].stepNum)")

        let indexPath = IndexPath(row: steps.count - 1, section: 0)
//        print("Grandon(DetailStepVC): the index path is \(indexPath.row)")
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        let step = ["stepDescription": "", "stepImgUrl": INIT_IMG_URL, "stepNum" : steps.count] as [String : Any]
        DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step00000000000\(steps.count)").updateChildValues(step)
        
        tableView.scrollToRow(at: indexPath, at: .middle, animated: true)
//        indicator.stopAnimating()
        loadingView.hide()
        self.view.isUserInteractionEnabled = true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
//        startActiveIndicator()
        loadingView = LoadingView(uiView: view, message: "")
        number = indexPath.row + 1
        stepRef.child(self.postId).child("steps").child("stepDetails").child("step\(number!)").removeValue()
        stepImgRef.child(self.postId).child("Step \(number!)").delete(completion: nil)
        
//        [Step1, Step2, Step3, Step4, Step5]
//        [Step1, Step2, Step4, Step5]
//        [Step1, Step2, Step3, Step4]
        
        tableView.beginUpdates()
        steps.remove(at: indexPath.row)
        for step in steps {
            if step.stepNum > indexPath.row {
                if step.stepNum > steps.count {
                    DataService.ds.STEP_IMAGE.child(self.postId).child("Step \(step.stepNum)").delete(completion: nil)
                    step.stepNum -= 1
                    updateStepDetail(step: step)
                } else if step.stepNum <= steps.count {
                    step.stepNum -= 1
                    updateStepDetail(step: step)
//                let ref = DataService.ds.STEP_IMAGE.child(self.postId).child("Step \(step.stepNum)")
//                updateStorageFileName(postId: self.postId, ref: ref, step: step)
                }
                print("Grandon(DetailStepVC): this step is step\(step.stepNum), \(step.stepDescription), \(step.stepImgUrl)")
            }
        }
        
        tableView.deleteRows(at: [indexPath], with: .fade)
        
        tableView.reloadData()
        tableView.endUpdates()
//        stopActiveIndicator()
        loadingView.hide()
    }
    
    @IBAction func adjustStepBtnPressed(_ sender: Any) {
        if tableView.isEditing {
            adjustBtn.setTitle("Adjust Steps", for: .normal)
//            indicator.startAnimating()
            loadingView = LoadingView(uiView: view, message: "Updating...")
            var stepDictionary = [String: Any]()
            for i in 0...steps.count - 1 {
                //            if step.stepNum == number {
                //                steps.remove(at: indexPath.row)
                //            } else if step.stepNum > number {
                //                step.stepNum = step.stepNum - 1
                let step = steps[i]
                let stepDetail = ["stepDescription": step.stepDescription, "stepImgUrl": step.stepImgUrl, "stepNum": step.stepNum] as [String : Any]
                stepDictionary["step\(step.stepNum)"] = stepDetail
                //            }
            }
            stepRef.child(self.postId).child("steps").child("stepDetails").setValue(stepDictionary)
//            indicator.stopAnimating()
            loadingView.hide()
            tableView.setEditing(false, animated: true)
            tableView.reloadData()
        } else {
            tableView.setEditing(true, animated: true)
            adjustBtn.setTitle("Complete Editing", for: .normal)
        }
    }
    
    @IBAction func postBtnPressed(_ sender: Any) {
        var missingImgCount = 0
        var missingDescCount = 0
        let imgAlert = UIAlertController(title: "Missing Image", message: "One of yous steps do not have an image, are you sure?", preferredStyle: .alert)
        let descAlert = UIAlertController(title: "Missing Description", message: "One of your steps do not have a description, are you sure?", preferredStyle: .alert)
        
        let descConfirmHandler = { (action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "PostVC", sender: nil)
        }
        
        let imageConfirmHandler = { (action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "PostVC", sender: nil)
        }
        
        let descAndImgHandler = { (action: UIAlertAction) -> Void in
            imgAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: imageConfirmHandler))
            imgAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(imgAlert, animated: true, completion: nil)
        }
        
        for step in steps {
            let stepImg = step.stepImage
            let stepDesc = step.stepDescription
            if stepImg == UIImage(named: "emptyImage") {
                missingImgCount += 1
            }
            
            if stepDesc == "" {
                missingDescCount += 1
            }
        }
        print("Grandon(DetailStepVC): missing image count is \(missingImgCount), missing description count is \(missingDescCount)")
        
        if missingImgCount == 0 && missingDescCount == 0 {
            performSegue(withIdentifier: "PostVC", sender: nil)
        } else if missingDescCount != 0 && missingImgCount == 0 {
            descAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: descConfirmHandler))
            descAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(descAlert, animated: true, completion: nil)
        } else if missingImgCount != 0 && missingDescCount == 0 {
            imgAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: imageConfirmHandler))
            imgAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(imgAlert, animated: true, completion: nil)
        } else if missingDescCount != 0 && missingImgCount != 0 {
            descAlert.addAction(UIAlertAction(title: "Yes", style: .default, handler: descAndImgHandler))
            descAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
            self.present(descAlert, animated: true, completion: nil)
        }
        
        steps.removeAll()
//        KeychainWrapper.standard.set(Int(self.postId)!, forKey: POST_COUNT)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? PostVC {
            destination.postKey = postId
            destination.isNewPost = true
        }
    }
    
    @IBAction func backBtnPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func cancelBtnPressed(_ sender: Any) {
//        indicator.startAnimating()
        loadingView = LoadingView(uiView: view, message: "Cancelling...")
        self.view.isUserInteractionEnabled = false
        for step in steps {
            DataService.ds.STEP_IMAGE.child(self.postId).child("Step \(step.stepNum)").delete(completion: nil)
        }
        
        steps.removeAll()
        DataService.ds.POST_IMAGE.child(self.postId).child(self.completionImgName).delete { (error) in
            if error != nil {
                print("Grandon(DetailStepVC): not able to delete \(error)")
            }
        }
        DataService.ds.REF_USERS_CURRENT.child("myPosts").child(self.postId).removeValue()
        DataService.ds.REF_POSTS.child(self.postId).removeValue()
//        indicator.stopAnimating()
        loadingView.hide()
        self.view.isUserInteractionEnabled = true
        performSegue(withIdentifier: "MainVC", sender: nil)
        
    }

    func imageTapped(_ sender: UITapGestureRecognizer) {
        let location = sender.location(in: tableView)
        let ip = tableView.indexPathForRow(at: location)!
        selectedIndex = ip.row
        present(imagePicker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
//        self.indicator.startAnimating()
        loadingView = LoadingView(uiView: view, message: "Updating...")
        self.view.isUserInteractionEnabled = false
        if let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
                step.imageData = imageData
                step.metaData = metadata
                DataService.ds.STEP_IMAGE.child(postId).child(stepImgName).putData(imageData, metadata: metadata) {
                    (data, error) in
                    if error != nil {
                        print("Grandon(DetailStepVC): unable to upload profile image.")
                    } else {
                        print("Grandon(DetailStepVC): successfully upload profile image.")
                        let imageUrl = data?.downloadURL()?.absoluteString
                        step.stepImgUrl = imageUrl!
                        DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(self.selectedIndex + 1)").child("stepImgUrl").setValue(imageUrl)
                        
//                        self.indicator.stopAnimating()
                        self.view.isUserInteractionEnabled = true
                    }
                }
            }
            
            loadingView.hide()
//            tableView.reloadData()
            
        }
        dismiss(animated: true, completion: nil)
    }
    
    func updateStepDetail(step: Step) {
//        if let imageData = UIImageJPEGRepresentation(step.stepImage, 0.5) {
//            let stepNumber = "Step \(step.stepNum)"
////            print("Grandon(DetailStepVC): now step number is \(stepNumber)")
//            let metadata = StorageMetadata()
//            metadata.contentType = "image/jpeg"
//            DataService.ds.STEP_IMAGE.child(postId).child(stepNumber).putData(imageData, metadata: metadata) {
//                (data, error) in
//                if error != nil {
//                    print("Grandon(DetailStepVC): unable to upload profile image.")
//                } else {
//                    print("Grandon(DetailStepVC): successfully upload profile image.")
//                    let imageUrl = data?.downloadURL()?.absoluteString
//                    print("Grandon(DetailStepVC): the image url is \(imageUrl!)")
//                    let updatedStep = ["stepDescription": step.stepDescription, "stepImgUrl": imageUrl!, "stepNum" : step.stepNum] as [String : Any]
//                    DataService.ds.REF_POSTS.child(self.postId).child("steps").child("stepDetails").child("step\(step.stepNum)").updateChildValues(updatedStep)
//                }
//            }
//        }
        let updatedStep = ["stepDescription": step.stepDescription, "stepImgUrl": step.stepImgUrl, "stepNum" : step.stepNum] as [String : Any]
        DataService.ds.REF_POSTS.child(postId).child("steps").child("stepDetails").child("step\(step.stepNum)").updateChildValues(updatedStep)
        DataService.ds.STEP_IMAGE.child(postId).child("Step \(step.stepNum)").putData(step.imageData, metadata: step.metaData)
    }
    
    func startActiveIndicator() {
        self.indicator.startAnimating()
    }
    
    func stopActiveIndicator() {
        self.indicator.stopAnimating()
        
    }
}


