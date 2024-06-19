//
//  ResetPassword.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 4/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ResetPassword: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var sendBtn: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        emailField.returnKeyType = .done
        
        emailField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        sendBtn.disableBtn()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        if isValidEmail(emailField.text!) {
            sendBtn.enableBtn()
        }
        else{
            sendBtn.disableBtn()
        }
    }
    
    func isValidEmail(_ email: String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: email)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if emailField.text! == "" {
            return false
        } else if textField == emailField {
            emailField.resignFirstResponder()
            return true
        }else {
            return false
        }
    }
    
    @IBAction func sendClick(_ sender: UIButton) {
        loadReset()
    }
    
    func loadReset() {
        let parameters:Parameters = ["email":emailField.text!]
        loadRequest(method:.post, apiName:"auth/forgot", authorization:false, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS \(json)")
                // use `value` here
                ProgressHUD.showSuccess("Please Check Your Email")
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}//end ViewController
