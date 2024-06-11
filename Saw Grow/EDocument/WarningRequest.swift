//
//  WarningRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

protocol PeopleDelegate {
    func selectPeople(peopleArr: JSON)
}

class WarningRequest: UIViewController, UITextFieldDelegate, UITextViewDelegate, PeopleDelegate {
    
    var warningJSON:JSON?
    var personJSON:JSON?
    
    var selectedTypeID:String = ""
    var selectedPersonID:String = ""
    
    let remarkStr = "WARNING_REQUEST_Reason".localized()
    
    let alertService = AlertService()
    
    @IBOutlet weak var typeIcon: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var startIcon: UIButton!
    @IBOutlet weak var startField: UITextField!
    
    @IBOutlet weak var endIcon: UIButton!
    @IBOutlet weak var endField: UITextField!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var personIcon: UIButton!
    @IBOutlet weak var personField: UITextField!
    @IBOutlet weak var personBtn: UIButton!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    var personPicker: UIPickerView! = UIPickerView()
    
    var startPicker: UIDatePicker! = UIDatePicker()
    var endPicker: UIDatePicker! = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WARNING REQUEST")
        
        personField.delegate = self
        typeField.delegate = self
        startField.delegate = self
        endField.delegate = self
        remarkText.delegate = self
        
        pickerSetup(picker: personPicker)
        personField.inputView = personPicker
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        datePickerSetup(picker: startPicker)
        startField.inputView = startPicker
        
        datePickerSetup(picker: endPicker)
        endField.inputView = endPicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        loadWarning()
    }
    
    func selectPeople(peopleArr: JSON) {
//        print("Test = \(peopleArr)")
        selectedPersonID = peopleArr["user_id"].stringValue
        personIcon.setImage(UIImage(named: "form_person_on"), for: .normal)
        personField.text = "\(peopleArr[self.firstNameKey()].stringValue) \(peopleArr[self.lastNameKey()].stringValue)"
    }
    
    func loadWarning() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"edocument/getwarningtypes", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS WARNING\(json)")

                self.warningJSON = json["data"][0]["warningtypes"]
//                self.personJSON = json["data"][0]["head"]

                self.typePicker.reloadAllComponents()
//                self.personPicker.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
        else if textField == personField {// && personField.text == "" {
            //selectPicker(personPicker, didSelectRow: 0)
            personField.resignFirstResponder()
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "PeopleSelector") as! PeopleSelector
            vc.delegate = self
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if textField == startField && startField.text == "" {
            datePickerChanged(picker: startPicker)
        }
        else if textField == endField && endField.text == "" {
            datePickerChanged(picker: endPicker)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if typeField.text == "" || startField.text == "" || endField.text == "" || personField.text == ""  {
            submitBtn.disableBtn()
        }
        else{
            submitBtn.enableBtn()
        }
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
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
        
        if picker == startPicker {
            startField.text = selectDate
            startIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            
            if startPicker.date > endPicker.date {
                endField.text = selectDate
                endPicker.date = picker.date
                endIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            }
            endPicker.minimumDate = picker.date
        }
        else if picker == endPicker {
            endField.text = selectDate
            endIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        }
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        case 2://person
            personField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == remarkStr {
            textView.text = ""
            remarkText.textColor = .textDarkGray
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = remarkStr
            remarkText.textColor = UIColor.lightGray
        }
        return true
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {        
        let alertMain = alertService.alertMain(title: "WARNING_REQUEST_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .themeColor)
        {
            self.loadSubmit()
        }
        present(alertMain, animated: true)
    }
    
    func loadSubmit() {
        let startDate = dateToServerString(date: startPicker.date)
        let endDate = dateToServerString(date: endPicker.date)

        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
//        print("Person ID =\(selectedPersonID) \n TYPEID =\(selectedTypeID) \nSTART =\(startDate) \nEND =\(endDate) \nREMARK =\(descriptionStr) \n")

        let parameters:Parameters = ["uid":selectedPersonID ,
                                     "document_type_id":selectedTypeID,
                                     "fromdate":startDate ,
                                     "todate":endDate ,
                                     "reason":descriptionStr
        ]
        //print(parameters)

        loadRequest(method:.post, apiName:"edocument/setwarning", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS WARNING REQUEST\(json)")

                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        
        selectedPersonID = ""
        personField.text = ""
        personIcon.setImage(UIImage(named: "form_person_off"), for: .normal)
        
        selectedTypeID = ""
        typeField.text = ""
        typeIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        startField.text = ""
        startPicker.date = Date()
        startIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        endField.text = ""
        endPicker.date = Date()
        endIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        submitBtn.disableBtn()
    }
}

// MARK: - Picker Datasource
extension WarningRequest: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && warningJSON!.count > 0{
            return warningJSON!.count
        }
        else if pickerView == personPicker && personJSON!.count > 0{
            return personJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        var pickerLabel: UILabel? = (view as? UILabel)
        if pickerLabel == nil {
            pickerLabel = UILabel()
            pickerLabel?.font = .Kanit_Regular(ofSize: 22)
            pickerLabel?.textAlignment = .center
        }
        
        if pickerView == typePicker && warningJSON!.count > 0{
            pickerLabel?.text = warningJSON![row][nameKey()].stringValue
        }
        else if pickerView == personPicker && personJSON!.count > 0{
            pickerLabel?.text = "\(personJSON![row][self.firstNameKey()].stringValue) \(personJSON![row][self.lastNameKey()].stringValue)"
        }
        else{
            pickerLabel?.text = ""
        }
        
        pickerLabel?.textColor = .textDarkGray

        return pickerLabel!
    }
    
    /*
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePicker && leaveJSON!.count > 0{
            return leaveJSON![row]["category_name_en"].stringValue
        }
        else if pickerView == headPicker && headJSON!.count > 0{
            return "\(headJSON![row]["first_name"].stringValue) \(headJSON![row]["last_name"].stringValue)"
        }
        else{
            return ""
        }
    }
 */
}

// MARK: - Picker Delegate
extension WarningRequest: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = warningJSON![row][nameKey()].stringValue
            typeIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            selectedTypeID = warningJSON![row]["id"].stringValue
        }
        else if pickerView == personPicker {
            personField.text = "\(personJSON![row][self.firstNameKey()].stringValue) \(personJSON![row][self.lastNameKey()].stringValue)"
            personIcon.setImage(UIImage(named: "form_person_on"), for: .normal)
            selectedPersonID = personJSON![row]["user_id"].stringValue
        }
    }
}

