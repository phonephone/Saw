//
//  AlertMoodVC.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 28/3/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import SDWebImage

class AlertMoodVC : UIViewController {
    
    var selectedMood = 0
    
    @IBOutlet weak var moodIcon1: UIButton!
    @IBOutlet weak var moodTitle1: UILabel!
    
    @IBOutlet weak var moodIcon2: UIButton!
    @IBOutlet weak var moodTitle2: UILabel!
    
    @IBOutlet weak var moodIcon3: UIButton!
    @IBOutlet weak var moodTitle3: UILabel!
    
    @IBOutlet weak var moodIcon4: UIButton!
    @IBOutlet weak var moodTitle4: UILabel!
    
    @IBOutlet weak var moodIcon5: UIButton!
    @IBOutlet weak var moodTitle5: UILabel!
    
    @IBOutlet weak var moodIcon6: UIButton!
    @IBOutlet weak var moodTitle6: UILabel!
    
    @IBOutlet weak var moodTextFiled: UITextField!
    @IBOutlet weak var moodImageView: UIImageView!
    
    @IBOutlet weak var moodSubmitBtn: UIButton!
    
    var complete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
        
        moodImageView.isHidden = true
    }
    
    func setupView() {
//        titleLabel.text = alertTitle
//        bodyLabel.text = alertBody
//        actionButton.setTitle(alertActionButtonTitle, for: .normal)
        
        clearMood(thenSelect: 0)
    }
    
    func clearMood(thenSelect:Int) {
        
        let unselectImage = UIImage(named: "home_feeling1")
        let unselectTitle = "ไม่มีความสุข"
        
        moodIcon1.setImage(unselectImage, for: .normal)
        moodIcon2.setImage(unselectImage, for: .normal)
        moodIcon3.setImage(unselectImage, for: .normal)
        moodIcon4.setImage(unselectImage, for: .normal)
        moodIcon5.setImage(unselectImage, for: .normal)
        moodIcon6.setImage(unselectImage, for: .normal)
        
        moodTitle1.text = unselectTitle
        moodTitle2.text = unselectTitle
        moodTitle3.text = unselectTitle
        moodTitle4.text = unselectTitle
        moodTitle5.text = unselectTitle
        moodTitle6.text = unselectTitle
        
        selectedMood = thenSelect
        switch selectedMood {
        case 1:
            setMood(moodBtn: moodIcon1, moodTitle: moodTitle1)
            
        case 2:
            setMood(moodBtn: moodIcon2, moodTitle: moodTitle2)
            
        case 3:
            setMood(moodBtn: moodIcon3, moodTitle: moodTitle3)
            
        case 4:
            setMood(moodBtn: moodIcon4, moodTitle: moodTitle4)
            
        case 5:
            setMood(moodBtn: moodIcon5, moodTitle: moodTitle5)
            
        case 6:
            setMood(moodBtn: moodIcon6, moodTitle: moodTitle6)
            
        default:
            moodSubmitBtn.disableBtn()
        }
    }
    
    func setMood(moodBtn:UIButton, moodTitle:UILabel) {
        let selectImage = UIImage(named: "home_feeling4")
        let selectTitle = "มีความสุขมาก"
        
        moodBtn.setImage(selectImage, for: .normal)
        moodTitle.text = selectTitle
        moodSubmitBtn.enableBtn()
    }
    
    @IBAction func didTapMood(_ sender: UIButton) {
        clearMood(thenSelect: sender.tag)
    }
    
    @IBAction func didTapCamera(_ sender: UIButton) {
        chooseImageSource()
    }
    
    func chooseImageSource()
    {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: false)
            
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                self.moodImageView.image = image
                self.moodImageView.isHidden = false
            }
        }
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        submitMood(moodID: String(selectedMood))
    }
    
    func submitMood(moodID:String) {
        self.complete?()
        self.dismiss(animated: true)
        
//        var parameters:Parameters = ["mood_id":moodID]
//        
//        if moodImageView.image != nil {
//            let base64Image = moodImageView.image!.convertImageToBase64String()
//            parameters.updateValue(base64Image, forKey: "image")
//        }
//        
//        print(parameters)
//        
//        loadRequest(method:.post, apiName:"auth/setmoodlog", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
//            switch result {
//            case .failure(let error):
//                print(error)
//                //ProgressHUD.dismiss()
//                
//            case .success(let responseObject):
//                let json = JSON(responseObject)
//                print("SUCCESS SETMOOD\(json)")
//                
//                self.clearMood(thenSelect: 0)
//                
//                self.complete?()
//                self.dismiss(animated: true)
//            }
//        }
    }
}


