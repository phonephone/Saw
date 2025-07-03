//
//  Login.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class Login: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passField: UITextField!
    @IBOutlet weak var signInBtn: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("LOGIN")
        
        emailField.delegate = self
        passField.delegate = self
        emailField.returnKeyType = .next
        
        emailField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        passField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailField.text = ""
        passField.text = ""
        
        signInBtn.disableBtn()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == emailField || textField == passField {
            emailField.text! = emailField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            passField.text! = passField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        
        if isValidEmail(emailField.text!) && passField.text!.count >= 1 {
            signInBtn.enableBtn()
        }
        else{
            signInBtn.disableBtn()
        }
        
        if emailField.text == "666" {//Bypass Test Account
            emailField.text = "admin@sawinzpy.com"
            passField.text = "saw1234"
            signInBtn.enableBtn()
        }
        if emailField.text == "777" {//Bypass Login Employee
            emailField.text = "yuya101@gmail.com"
            passField.text = "123456"
            signInBtn.enableBtn()
        }
        if emailField.text == "888" {//Bypass Login Employee
            emailField.text = "hinbullv2@gmail.com"
            passField.text = "hinbull112"
            signInBtn.enableBtn()
        }
        if emailField.text == "999" {//Bypass Login Head
            emailField.text = "s.awiruth@gmail.com"
            passField.text = "123456"
            signInBtn.enableBtn()
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
            passField.becomeFirstResponder()
            return true
        } else if textField == passField {
            passField.resignFirstResponder()
            return true
        }else {
            return false
        }
    }
    
    @IBAction func secureClick(_ sender: UIButton) {
        if passField.isSecureTextEntry == true {
            passField.isSecureTextEntry = false
            sender.setImage(UIImage(named: "login_password_show.png"), for: .normal)
        }
        else {
            passField.isSecureTextEntry = true
            sender.setImage(UIImage(named: "login_password_hide.png"), for: .normal)
        }
    }
    
    @IBAction func registerClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = "LOGIN_Register_Button".localized()
        vc.webUrlString = "https://sawgrow.com/erp/register-new-account"
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func forgetClick(_ sender: UIButton) {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "ResetPassword")
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func signInClick(_ sender: UIButton) {
        loadLogin()
    }
    
    func loadLogin() {
        let parameters:Parameters = ["username":emailField.text!, "password":passField.text!]
        loadRequest(method:.post, apiName:"auth/login", authorization:false, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS LOGIN\(json)")
                // use `value` here
                let accessToken = json["data"][0]["access_token"]
                print("ACCESSTOKEN \(accessToken)")
                
                UserDefaults.standard.set("\(accessToken)", forKey: "access_token")
                
                self.pushToNextViewController()
            }
        }
    }
    
    func pushToNextViewController() {
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "NewPasscode") //as? EnterPasscode
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    /*
    func loadLogin() {
        loadingHUD()
        
        let headers: HTTPHeaders = [
            //"Authorization": "Basic VXNlcm5hbWU6UGFzc3dvcmQ=",
            "Accept": "application/json"
        ]

        let param = ["username":emailField.text, "password":passField.text]
        
        AF.request("https://dev.sawgrow.com/api/v1/auth/login",
                   method: .post,
                   parameters: param,
                   headers: headers).responseJSON { response in
                    debugPrint(response)
                    
                    switch response.result {
                    case .success:
                        if let json = response.data {
                            do{
                                let data = try JSON(data: json)
                                
                                let status = data["status"]
                                let message = data["message"]
                                print("DATA PARSED: \(status): \(message)")
                            }
                            catch{
                                print("JSON Error")
                            }
                        }
                    case .failure(let error):
                        print(error)
                    }
                   }
    }
     */
    
}//end ViewController
