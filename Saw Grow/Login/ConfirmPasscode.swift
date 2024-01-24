//
//  ConfirmPasscode.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 4/11/2564 BE.
//

import UIKit
import ProgressHUD

class ConfirmPasscode: UIViewController, UITextFieldDelegate, MyFieldDelegate {
    
    var passcodeStr:String?
    
    @IBOutlet weak var passCode1: MyField!
    @IBOutlet weak var passCode2: MyField!
    @IBOutlet weak var passCode3: MyField!
    @IBOutlet weak var passCode4: MyField!
    @IBOutlet weak var nextBtn: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        nextBtn.disableBtn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        passCode1.becomeFirstResponder()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
        nextBtn.disableBtn()
        
        if passCode1.text?.count == 0 && passCode2.text?.count == 0 && passCode3.text?.count == 0 && passCode4.text?.count == 0 {
            passCode1.becomeFirstResponder()
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return range.location < 1
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        
        if textField == passCode1 && textField.text!.count >= 1 {
            passCode2.becomeFirstResponder()
        }
        if textField == passCode2 && textField.text!.count >= 1 {
            passCode3.becomeFirstResponder()
        }
        if textField == passCode3 && textField.text!.count >= 1 {
            passCode4.becomeFirstResponder()
        }
        if textField == passCode4 && textField.text!.count >= 1 {
            let confirmStr = "\(passCode1.text!)\(passCode2.text!)\(passCode3.text!)\(passCode4.text!)"
            if passcodeStr == confirmStr {
                print("Passcode Match")
                passCode4.resignFirstResponder()
                nextBtn.enableBtn()
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
            passCode1.becomeFirstResponder()
        }
        if textField == passCode3 && passCode3.text?.count == 0 && passCode4.text?.count == 0 {
            passCode2.becomeFirstResponder()
        }
        if textField == passCode4 && passCode4.text?.count == 0 {
            passCode3.becomeFirstResponder()
        }
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        UserDefaults.standard.set("\(passcodeStr!)", forKey: "passCode")
        
        let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Tutorial") as! Tutorial
        vc.mode = .firstTime
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}//end ViewController
