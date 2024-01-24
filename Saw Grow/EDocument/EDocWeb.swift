//
//  EDocWeb.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 17/5/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import WebKit

class EDocWeb: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var edocJSON:JSON?
    
    var edocType:edocType?
    
    var titleString:String?
    var webUrlString:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var sendMailBtn: UIButton!
    @IBOutlet weak var myWebView: WKWebView!
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupField: UITextField!
    @IBOutlet weak var popupCancleBtn: UIButton!
    @IBOutlet weak var popupSubmitBtn: UIButton!
    
    var blurView : UIVisualEffectView!
    
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
        print("Web")
        
        headerTitle.text = titleString
        
        let url = URL(string: edocJSON!["url"].stringValue)!
        //let url = URL(string: webUrlString!)!
        myWebView.load(URLRequest(url: url))
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
        
        blurView = blurViewSetup()
        let popupWidth = self.view.bounds.width*0.9
        let popupHeight = 210.0
        popupView.frame = CGRect(x:100, y:200, width: popupWidth, height: popupHeight)
        popupView.center = self.view.center
        
        popupField.delegate = self
        popupField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        if edocType == .warning_letter {
            sendMailBtn.isHidden = true
        }
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingHUD()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    @IBAction func sentToEmail(_ sender: UIButton) {
        //popupField.text = ""
        popupField.text = edocJSON!["email"].stringValue
        popupSubmitBtn.enableBtn()
        self.popIn(popupView: self.blurView)
        self.popIn(popupView: self.popupView)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if isValidEmail(popupField.text!) {
            popupSubmitBtn.enableBtn()
        }
        else{
            popupSubmitBtn.disableBtn()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {

    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    @IBAction func popupCancel(_ sender: UIButton) {
        self.popOut(popupView: self.popupView)
        self.popOut(popupView: self.blurView)
    }
    
    @IBAction func popupSubmit(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        var parameters:Parameters = ["email":popupField.text!,
                                     "lang":edocJSON!["lang"].stringValue,
                                     "token":edocJSON!["token"].stringValue,
                                     "type":edocJSON!["request_type"].stringValue,
        ]
        
        if edocType == .payslip {
            parameters.updateValue(edocJSON!["period"].stringValue, forKey: "period")
        }
        
        print(parameters)

        loadRequest(method:.get, apiName:"edocument/getsendmail", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SEND EMAIL\(json)")
                
                self.submitSuccess()
                self.popOut(popupView: self.popupView)
                self.popOut(popupView: self.blurView)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
