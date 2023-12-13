//
//  RewardDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 18/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import WebKit
import Localize_Swift

enum detailMode {
    case redeem
    case mycoupon
    case used
    case expired
}

class RewardDetail: UIViewController, WKNavigationDelegate {
    
    var rewardID:String?
    var rewardJSON:JSON?
    
    var mode:detailMode?
    
    var userPoint:Int?
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var myWebView: WKWebView!
    @IBOutlet weak var submitView: UIView!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //loadReward()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REWARD DETAIL")
        
        if mode == .redeem
        {
            headTitle.text = "REWARD_DETAIL_Header".localized()
            submitBtn.disableBtn()
            loadReward()
        }
        else
        {
            headTitle.text = "REWARD_COUPON_Header".localized()
            submitBtn.disableBtn()
            //submitBtn.isHidden = true
            self.loadCoupon(withLoadingHUD: true)
        }
        
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
    }
    
    func loadReward() {
        let parameters:Parameters = ["id":rewardID!]
        loadRequest(method:.get, apiName:"reward/getrewarddetail", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REWARD DETAIL\(json)")
                
                userPoint = json["data"][0]["point"].intValue
                
                self.rewardJSON = json["data"][0]["reward_banner"][0]
                let url = URL(string: self.rewardJSON!["link_url"].stringValue)
                myWebView.load(URLRequest(url: url!))
                self.redeemBtnCheck()
            }
        }
    }
    
    func redeemBtnCheck() {
        if rewardJSON!["remain"].intValue <= 0 {
            submitBtn.setTitle("REWARD_DETAIL_Out".localized(), for: .normal)
            submitBtn.disableBtn()
        }
        else if userPoint! < rewardJSON!["point"].intValue {
            submitBtn.setTitle("REWARD_DETAIL_Insufficient".localized(), for: .normal)
            submitBtn.disableBtn()
        }
        else {
            submitBtn.setTitle("REWARD_DETAIL_Redeem".localized(), for: .normal)
            submitBtn.enableBtn()
            submitBtn.backgroundColor = .themeColor
        }
    }
    
    func loadCoupon(withLoadingHUD:Bool) {
        let parameters:Parameters = ["id":rewardID!]
        loadRequest(method:.get, apiName:"reward/getcoupon", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS COUPON DETAIL\(json)")
                
                self.rewardJSON = json["data"][0]["redeamlog"][0]
                let url = URL(string: self.rewardJSON!["link_url"].stringValue)
                myWebView.load(URLRequest(url: url!))
                
                if self.rewardJSON!["status"] == "valid" {
                    if mode == .mycoupon
                    {
                        headTitle.text = "REWARD_COUPON_Valid".localized()
                        submitBtn.setTitle("REWARD_COUPON_Use_Button".localized(), for: .normal)
                        submitBtn.enableBtn()
                        submitBtn.backgroundColor = .textPointGold
                    }
                }
                else{
                    if mode == .mycoupon || mode == .used
                    {
                        headTitle.text = "REWARD_COUPON_Used".localized()
                        submitBtn.setTitle("REWARD_COUPON_Used_Button".localized(), for: .normal)
                        submitBtn.disableBtn()
                    }
                    else if mode == .expired
                    {
                        submitBtn.setTitle("REWARD_COUPON_Expired".localized(), for: .normal)
                        submitBtn.disableBtn()
                        myWebView.alpha = 0.6
                        self.loadCoupon(withLoadingHUD: true)
                    }
                }
            }
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingHUD()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
        if mode == .mycoupon
        {
            submitBtn.isHidden = false
        }
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        guard let urlAsString = navigationAction.request.url?.absoluteString.lowercased() else {
            return
        }
        
        if urlAsString.range(of: "the url that the button redirects the webpage to") != nil {
            // do something
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        if mode == .redeem
        {
            confirmRedeem()
        }
        else if mode == .mycoupon
        {
            if self.rewardJSON!["redeam_url"] == "" {
                confirmUseCoupon()
            }
            else{
                showQR()
            }
        }
    }
    
    func confirmRedeem() {
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "REWARD_DETAIL_Redeem_Confirm".localized()
        let expireDate = dateFromServerString(dateStr: rewardJSON!["expire_date"].stringValue)
        alert.message = "\("REWARD_DETAIL_Alert_Expire".localized()) \(appStringFromDate(date: expireDate!, format: "dd MMM yyyy"))"
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmitRedeem()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmitRedeem() {
        let parameters:Parameters = ["reward_id":rewardID!]
        print(parameters)
        
        loadRequest(method:.post, apiName:"reward/setredeam", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REDEEM\(json)")

                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "Coupon") as! Coupon
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    
    func confirmUseCoupon() {
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "REWARD_COUPON_Use_Confirm".localized()
        alert.message = self.rewardJSON!["remark"].stringValue
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadUseCoupon()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadUseCoupon() {
        let parameters:Parameters = ["id":rewardID!]
        print(parameters)
        
        loadRequest(method:.post, apiName:"reward/setusecoupon", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS USE COUPON\(json)")

                self.submitSuccess()
                self.loadCoupon(withLoadingHUD: false)
            }
        }
    }
    
    func showQR() {
        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "QRCode") as! QRCode
        vc.qrJSON = self.rewardJSON
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
