//
//  PrivacyPolicy.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 16/10/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class PrivacyPolicy: UIViewController, UIScrollViewDelegate {
    
    var agreementShow:Bool?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var myScrollView: MyScrollView!
    
    @IBOutlet weak var agreementStack: UIStackView!
    @IBOutlet weak var checkboxBtn: UIButton!
    @IBOutlet weak var checkboxLabel: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PRIVACY")
        
        //headerTitle.text = ""
        
        myScrollView.contentInset = UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)
        submitBtn.disableBtn()
        
        agreementDisplay(agreementShow ?? true)
        
        //myScrollView.dropShadow()
    }
    
    func agreementDisplay(_ show:Bool) {
        if show {
            agreementStack.isHidden = false
            backBtn.isHidden = true
        } else {
            agreementStack.isHidden = true
            backBtn.isHidden = false
        }
    }
    
    @IBAction func checkboxClick(_ sender: UIButton) {
        if sender.imageView?.image != UIImage(named: "form_checkbox_on") {
            checkboxBtn.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
            submitBtn.enableBtn()
        } else {
            checkboxBtn.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
            submitBtn.disableBtn()
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        var parameters:Parameters = [:]

        loadRequest(method:.post, apiName:"auth/setprivacypolicystatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PRIVACY\(json)")
                
                self.submitSuccess()
                self.navigationController!.popViewController(animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

