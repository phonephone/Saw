//
//  EditProfile.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/2/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EditProfile: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var editJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var textFieldStack: UIStackView!
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var headerTitle: UILabel!
    
    var birthDayField: UITextField!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var birthDatePicker: UIDatePicker! = UIDatePicker()
    
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
        print("EDIT PROFILE")
        
        self.view.setNeedsLayout()
        self.view.layoutIfNeeded()
        
        myScrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
        
        datePickerSetup(picker: birthDatePicker)
//        birthDayField.inputView = birthDatePicker
        
        self.hideKeyboardWhenTappedAround()
        
        for i in 0...editJSON!.count-1 {
            
            let cellArray = editJSON![i]
            
            let editView = EditTemplate()
            editView.widthAnchor.constraint(equalToConstant: self.view.frame.width).isActive = true
            
            if cellArray["key_id"].stringValue == "is_show_birthday" {
                editView.commonInit(template: .switchOnOff)
                editView.heightAnchor.constraint(equalToConstant: 50.0).isActive = true
                editView.editSwitch.tag = i
                editView.editSwitch.addTarget(self, action: #selector(switchValueDidChange(_:)), for: .valueChanged)
            }
            else {
                editView.commonInit(template: .textField)
                editView.heightAnchor.constraint(equalToConstant: 70.0).isActive = true
                
                editView.editTextField.delegate = self
                editView.editTextField.tag = i
                editView.editTextField.addTarget(self, action: #selector(textFieldDidChange(textField:)), for: .editingChanged)
            }
            editView.editTitle.text = cellArray["label"].stringValue
            
            switch cellArray["key_id"].stringValue {
            case "date_of_birth":
                birthDayField = editView.editTextField
                birthDayField.tag = editView.editTextField.tag
                birthDayField.inputView = birthDatePicker
                //birthDayField.delegate = self
                
                let birthDayStr = cellArray["value"].stringValue
                if birthDayStr == "" {
                    birthDatePicker.date = Date()
                    birthDayField.text = ""
                }
                else
                {
                    birthDatePicker.date = appDateFromServerString(dateStr: cellArray["value"].stringValue)!
                    birthDayField.text = appStringFromDate(date: birthDatePicker.date, format:DateFormatter.appDateFormatStr)
                }
                
            case "contact_number":
                editView.editTextField.text = cellArray["value"].stringValue
                editView.editTextField.keyboardType = .phonePad
                
            case "id_no":
                editView.editTextField.text = cellArray["value"].stringValue
                editView.editTextField.keyboardType = .numberPad
                
            case "is_show_birthday":
                editView.editSwitch.isOn = cellArray["value"].boolValue
            
            default:
                editView.editTextField.text = cellArray["value"].stringValue
                editView.editTextField.keyboardType = .default
            }
            
            //textFieldStack.addArrangedSubview(textFieldView)
            textFieldStack.insertArrangedSubview(editView, at: i)
        }
        
        submitBtn.disableBtn()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == birthDayField && birthDayField.text == "" {
            datePickerChanged(picker: birthDatePicker)
        }
    }
    
    @objc final private func textFieldDidChange(textField: UITextField) {
        var cellArray = editJSON![textField.tag]
        
        switch cellArray["key_id"].stringValue {
        case "date_of_birth":
            let dateString = dateToServerString(date: birthDatePicker.date)
            cellArray["value"] = JSON(dateString)
        
        default:
            cellArray["value"] = JSON(textField.text!)
        }
        
        print(cellArray)
        editJSON![textField.tag] = cellArray
        
        submitBtn.enableBtn()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let cellArray = editJSON![textField.tag]
        
        switch cellArray["key_id"].stringValue {
        case "contact_number":
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 10
        
        case "id_no":
            guard let textFieldText = textField.text,
                    let rangeOfTextToReplace = Range(range, in: textFieldText) else {
                        return false
                }
                let substringToReplace = textFieldText[rangeOfTextToReplace]
                let count = textFieldText.count - substringToReplace.count + string.count
                return count <= 13
            
        default:
            return true
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    func datePickerSetup(picker:UIDatePicker) {
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "Formatter_Locale".localized())
        //picker.minimumDate = Date()
        picker.calendar = Calendar(identifier: .gregorian)
        picker.date = Date()
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        
        picker.setValue(false, forKey: "highlightsToday")
        picker.setValue(UIColor.white, forKeyPath: "backgroundColor")
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        let selectDate = appStringFromDate(date: picker.date, format:DateFormatter.appDateFormatStr)
        
        if picker == birthDatePicker {
            birthDayField.text = selectDate
            
            var cellArray = editJSON![birthDayField.tag]
            let dateString = dateToServerString(date: birthDatePicker.date)
            cellArray["value"] = JSON(dateString)
            
            print(cellArray)
            editJSON![birthDayField.tag] = cellArray
            
            submitBtn.enableBtn()
        }
    }
    
    @objc final private func switchValueDidChange(_ sender: UISwitch) {
        var cellArray = editJSON![sender.tag]
        if sender.isOn{//กดเปิด
            sender.setOn(true, animated: true)
            cellArray["value"] = JSON("1")
        }
        else{//กดปิด
            sender.setOn(false, animated: true)
            cellArray["value"] = JSON("0")
        }
        
        print(cellArray)
        editJSON![sender.tag] = cellArray
        
        submitBtn.enableBtn()
     }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "PROFILE_Edit_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        let parameters:Parameters = ["editable":editJSON!]
        print(parameters)
        
        loadRequest(method:.post, apiName:"auth/setprofile", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS EDIT PROFILE\(json)")

                self.submitSuccess()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    self.navigationController!.popViewController(animated: true)
                }
            }
        }
    }
}
