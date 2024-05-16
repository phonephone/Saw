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
    
    var moodJSON:JSON?
    
    var selectedMood = ""
    
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
    
    @IBOutlet weak var moodImageMainView: UIView!
    @IBOutlet weak var moodImageView: UIImageView!
    @IBOutlet weak var moodImageDeleteBtn: UIButton!
    
    @IBOutlet weak var moodSubmitBtn: UIButton!
    
    var complete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        clearMood(thenSelect: 0)
    }
    
    func clearMood(thenSelect:Int) {
        
        setMood(on:false ,moodBtn: moodIcon1, moodTitle: moodTitle1)
        setMood(on:false ,moodBtn: moodIcon2, moodTitle: moodTitle2)
        setMood(on:false ,moodBtn: moodIcon3, moodTitle: moodTitle3)
        setMood(on:false ,moodBtn: moodIcon4, moodTitle: moodTitle4)
        setMood(on:false ,moodBtn: moodIcon5, moodTitle: moodTitle5)
        setMood(on:false ,moodBtn: moodIcon6, moodTitle: moodTitle6)
        
        switch thenSelect {
        case 1:
            setMood(on:true ,moodBtn: moodIcon1, moodTitle: moodTitle1)
            
        case 2:
            setMood(on:true ,moodBtn: moodIcon2, moodTitle: moodTitle2)
            
        case 3:
            setMood(on:true ,moodBtn: moodIcon3, moodTitle: moodTitle3)
            
        case 4:
            setMood(on:true ,moodBtn: moodIcon4, moodTitle: moodTitle4)
            
        case 5:
            setMood(on:true ,moodBtn: moodIcon5, moodTitle: moodTitle5)
            
        case 6:
            setMood(on:true ,moodBtn: moodIcon6, moodTitle: moodTitle6)
            
        default://Clear All
            moodTextFiled.text = ""
            moodImageView.image = nil
            moodImageMainView.isHidden = true
            moodSubmitBtn.disableBtn()
        }
    }
    
    func setMood(on:Bool, moodBtn:UIButton, moodTitle:UILabel) {
        moodBtn.imageView!.contentMode = .scaleAspectFit
        
        var selectedMoodJSON = moodJSON![moodBtn.tag-1]
        
        if on {//ACTIVE
            moodBtn.sd_setImage(with: URL(string:selectedMoodJSON["icon_url_active"].stringValue), for: .normal, placeholderImage: nil)
            
            selectedMood = selectedMoodJSON["value"].stringValue
            moodSubmitBtn.enableBtn()
        }
        else {//INACTIVE
            moodBtn.sd_setImage(with: URL(string:selectedMoodJSON["icon_url"].stringValue), for: .normal, placeholderImage: nil)
        }
        moodTitle.text = selectedMoodJSON["name"].stringValue
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
                self.moodImageMainView.isHidden = false
            }
        }
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        moodImageView.image = nil
        moodImageMainView.isHidden = true
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        submitMood(moodID: String(selectedMood))
    }
    
    func submitMood(moodID:String) {
//        print("Select Mood \(selectedMood)")
//        print("With Comment \(String(describing: moodTextFiled.text))")
        
        var parameters:Parameters = ["mood_id":moodID,
                                     "remark":moodTextFiled.text ?? ""
        ]
        
        if moodImageView.image != nil {
            let base64Image = moodImageView.image!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "image")
        }
        //print(parameters)
        
        loadRequest(method:.post, apiName:"auth/setmoodlog", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SETMOOD\(json)")
                
                self.clearMood(thenSelect: 0)
                
                self.complete?()
                self.dismiss(animated: true)
            }
        }
    }
}


