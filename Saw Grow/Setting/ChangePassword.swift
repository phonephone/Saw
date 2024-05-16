//
//  ChangePassword.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 4/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ChangePassword: UIViewController, UITextFieldDelegate {
    
    var passwordJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var currentPassword: UITextField!
    @IBOutlet weak var newPassword: UITextField!
    @IBOutlet weak var confirmNewPassword: UITextField!
    
    @IBOutlet weak var warningLabel1: UILabel!
    @IBOutlet weak var warningLabel2: UILabel!
    @IBOutlet weak var warningLabel3: UILabel!
    @IBOutlet weak var warningLabel4: UILabel!
    
    @IBOutlet weak var warningMatch: UILabel!
    
    var check1:Bool = false
    var check2:Bool = false
    var check3:Bool = false
    var check4:Bool = false
    
    var checkMatch:Bool = false
    
    @IBOutlet weak var submitBtn: MyButton!
    
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
        print("CHANGE PASSWORD")
        
        currentPassword.delegate = self
        newPassword.delegate = self
        confirmNewPassword.delegate = self
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
//        warningLabel1.text = "At least 8 characters"
//        warningLabel2.text = "At least one lowercase letter (a-z)"
//        warningLabel3.text = "At least one number (0-9)"
//        warningLabel4.text = "At least one special character"
//
//        warningMatch.text = "Confirm New Password not match"
        warningMatch.isHidden = true
        
        currentPassword.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        newPassword.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        confirmNewPassword.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        //Check Character Long
        if isValidPasswordWithFormat(newPassword.text!, format: "^.{8,}$") {
            warningLabel1.textColor = .buttonGreen
            check1 = true
            
            //let format = String(format: "^.{%d,}$", newPassword.text!.count)
            if confirmNewPassword.text!.count >= newPassword.text!.count {
                warningMatch.isHidden = false
            }
            else{
                warningMatch.isHidden = true
            }
        }
        else{
            warningLabel1.textColor = .buttonRed
            check1 = false
        }
        
        //Check Lowercase
        if isValidPasswordWithFormat(newPassword.text!, format: "^(?=.*[a-z]).{1,}$") {
            warningLabel2.textColor = .buttonGreen
            check2 = true
        }
        else{
            warningLabel2.textColor = .buttonRed
            check2 = false
        }
        
        //Check Numeric
        if isValidPasswordWithFormat(newPassword.text!, format: "^(?=.*[0-9]).{1,}$") {
            warningLabel3.textColor = .buttonGreen
            check3 = true
        }
        else{
            warningLabel3.textColor = .buttonRed
            check3 = false
        }
        
        //Check Special Character
        if isValidPasswordWithFormat(newPassword.text!, format: "^(?=.*[-!@#$%&*ˆ+=_(){}/|?>.<,:;~`'\"\\[\\]\\\\]).{1,}$") {
            warningLabel4.textColor = .buttonGreen
            check4 = true
        }
        else{
            warningLabel4.textColor = .buttonRed
            check4 = false
        }
        
        //Check Match
        if newPassword.text == confirmNewPassword.text {
            warningMatch.textColor = .buttonGreen
            checkMatch = true
            
            warningMatch.isHidden = true
        }
        else{
            warningMatch.textColor = .buttonRed
            checkMatch = false
        }
        
        
        if  currentPassword.text != "" && check1 == true && check2 == true && check3 == true && check4 == true && checkMatch == true {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
       
    }
    
    func isValidPasswordWithFormat(_ password: String, format:String) -> Bool {
        let passwordPred = NSPredicate(format:"SELF MATCHES %@", format)
        return passwordPred.evaluate(with: password)
    }
    
    func isValidPassword(_ password: String) -> Bool {
        let passwordRegEx = "^(?=.*[a-z])(?=.*[0-9])(?=.*[A-Z]).{8,}$"
        //(?=.*[a-z]) - Check if password contains any character from a to z
        //(?=.*[-!@#$%&*ˆ+=_(){}/|?>.<,:;~`'\"\\[\\]\\\\]) - Check if password contains any sepecial character listed in the square bracket.
        //.{6,} - Check if password is six character long
        //(?=.*[A-Z]) - Check if password contains at least one big letter.
        //(?=.*[0-9]) - Check if password contains at least one number.

        let passwordPred = NSPredicate(format:"SELF MATCHES %@", passwordRegEx)
        return passwordPred.evaluate(with: password)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadPassword()
    }
    
    func loadPassword() {
        
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")

        let parameters:Parameters = ["oldpassword":currentPassword.text! ,
                                     "password":newPassword.text!
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:"auth/changepassword", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REQUEST\(json)")
                
                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        currentPassword.text = ""
        newPassword.text = ""
        confirmNewPassword.text = ""
        
        check1 = false
        check2 = false
        check3 = false
        check4 = false
        checkMatch = false
        
        warningLabel1.textColor = .buttonRed
        warningLabel2.textColor = .buttonRed
        warningLabel3.textColor = .buttonRed
        warningLabel4.textColor = .buttonRed
        warningMatch.textColor = .buttonRed
        
        submitBtn.disableBtn()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
