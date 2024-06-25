//
//  EDocRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/6/2565 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EDocRequest: UIViewController, UITextFieldDelegate {
    
    var edocJSON:JSON?
    
    var edocType:edocType?
    
    var dateFromCalendar:Date?
    
    let alertService = AlertService()

    @IBOutlet weak var monthYearView: UIView!
    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var languageView: UIView!
    @IBOutlet weak var languageIcon: UIButton!
    @IBOutlet weak var languageField: UITextField!
    @IBOutlet weak var languageBtn: UIButton!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    var languagePicker: UIPickerView! = UIPickerView()
    let languageArray = ["Thai".localized(),"English".localized()]
    var selectedLanguage: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EDOC REQUEST")
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        myDatePicker.notificationName = .request
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:myDatePicker.notificationName, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        languageField.delegate = self
        
        pickerSetup(picker: languagePicker)
        languageField.inputView = languagePicker
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        
        if edocType == .work_cert {
            monthYearView.isHidden = true
        }
        else if edocType == .salary_cert {
            monthYearView.isHidden = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //monthYearField.becomeFirstResponder()
    }
    
    @objc func myDateChanged(notification:Notification){
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromServerString(dateStr: (userInfo?["date"]) as! String)!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: DateFormatter.appMonthYearFormatStr)
        monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == monthYearField && monthYearField.text == "" {
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
        else if textField == languageField && languageField.text == "" {
            selectPicker(languagePicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if edocType == .work_cert && languageField.text != "" {
            submitBtn.enableBtn()
        }
        else if edocType == .salary_cert && languageField.text != "" {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://month & year
            monthYearField.becomeFirstResponder()
            
        case 2://date
            languageField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        let alertMain = alertService.alertMain(title: "EDOC_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .themeColor)
        {
            self.loadSubmit()
        }
        present(alertMain, animated: true)
    }
    
    func loadSubmit() {
        //mySelectedDate
        
        var parameters:Parameters = ["lang":selectedLanguage]
        if edocType == .work_cert {
            parameters.updateValue("empcer", forKey: "type")
        }
        else if edocType == .salary_cert {
            parameters.updateValue("empsalary", forKey: "type")
        }
        print(parameters)

        loadRequest(method:.post, apiName:"edocument/setempcer", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS EDOC REQUEST\(json)")
                
                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        monthYearField.text = ""
        //monthYearPicker.date = Date()
        monthYearIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        selectedLanguage = ""
        languageField.text = ""
        languagePicker.reloadAllComponents()
        languageIcon.setImage(UIImage(named: "form_language_off"), for: .normal)
        
        submitBtn.disableBtn()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - Picker Datasource
extension EDocRequest: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == languagePicker {
            return languageArray.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == languagePicker {
            return languageArray[row]
        }
        return nil
    }
}

// MARK: - Picker Delegate
extension EDocRequest: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == languagePicker {
            if row == 0 {
                selectedLanguage = "TH"
            }
            else{
                selectedLanguage = "EN"
            }
            languageField.text = languageArray[row]
            languageIcon.setImage(UIImage(named: "form_language_on"), for: .normal)
        }
    }
}

