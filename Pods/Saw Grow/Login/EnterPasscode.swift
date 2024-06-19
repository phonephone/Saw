//
//  EnterPasscode.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 4/11/2564 BE.
//

import UIKit
import ProgressHUD
import LocalAuthentication

class EnterPasscode : UIViewController, UITextFieldDelegate, MyFieldDelegate {
    
    var passcodeStr:String?
    
    @IBOutlet weak var passCode1: MyField!
    @IBOutlet weak var passCode2: MyField!
    @IBOutlet weak var passCode3: MyField!
    @IBOutlet weak var passCode4: MyField!
    
    let alertService = AlertService()
    
//    override var preferredStatusBarStyle : UIStatusBarStyle {
//        return .darkContent //.default for black style
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Updater.showUpdateAlert()
        
        let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                
                let reason = "Allow login with Touch ID"

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) {
                    [weak self] success, authenticationError in

                    DispatchQueue.main.async {
                        if success {
                            print("SUCCESS")
                            self!.switchToHome()
                        } else {
                            // error
                            print("CANCLE")
                        }
                    }
                }
            } else {
                // no biometry
                print("NO BIO")
            }
        
        passCode1.delegate = self
        passCode2.delegate = self
        passCode3.delegate = self
        passCode4.delegate = self
        
        passCode1.myDelegate = self
        passCode2.myDelegate = self
        passCode3.myDelegate = self
        passCode4.myDelegate = self
        
        passCode1.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        passCode2.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        passCode3.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        passCode4.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passCode1.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        
        if passCode1.text?.count == 0 && passCode2.text?.count == 0 && passCode3.text?.count == 0 && passCode4.text?.count == 0 {
            passCode1.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 1
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == passCode1 && textField.text!.count >= 1 {
            passCode1.resignFirstResponder()
            passCode2.becomeFirstResponder()
        }
        if textField == passCode2 && textField.text!.count >= 1 {
            passCode2.resignFirstResponder()
            passCode3.becomeFirstResponder()
        }
        if textField == passCode3 && textField.text!.count >= 1 {
            passCode3.resignFirstResponder()
            passCode4.becomeFirstResponder()
        }
        if textField == passCode4 && textField.text!.count >= 1 {
            passCode4.resignFirstResponder()
            
            let confirmStr = "\(passCode1.text!)\(passCode2.text!)\(passCode3.text!)\(passCode4.text!)"
            if passcodeStr == confirmStr {
                print("Passcode Match")
                switchToHome()
            }
            else
            {
                print("Passcode Not Match")
                ProgressHUD.showFailed("Passcode Not Match")
            }
        }
    }
    
    func textFieldDidDelete(_ textField: UITextField) {
        if textField == passCode2 && passCode2.text?.count == 0 && passCode3.text?.count == 0 {
            passCode2.resignFirstResponder()
            passCode1.becomeFirstResponder()
        }
        if textField == passCode3 && passCode3.text?.count == 0 && passCode4.text?.count == 0 {
            passCode3.resignFirstResponder()
            passCode2.becomeFirstResponder()
        }
        if textField == passCode4 && passCode4.text?.count == 0 {
            passCode4.resignFirstResponder()
            passCode3.becomeFirstResponder()
        }
    }
    
    @IBAction func forgetClick(_ sender: UIButton) {
        logOut()
//        let alert = alertService.alert(title: "Can you fly?", body: "I believe I can fly,I believe I can touch the sky wowwwwwwwwwwwwwwwwwwww", buttonTitle: "Flyyy") { [weak self] in
//
//            self?.passCode1.text = ""
//
//            print("Action Tapped")
//        }
//        present(alert, animated: true)
        
//        let alertSlide = alertService.alertSlide(title: "Confirm Check Out !", slideTitle: "Swipe to Confirm"){
//            print("Slideeeeeeeeeeee")
//        }
//        present(alertSlide, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}//end ViewController
