//
//  EDocReimburse.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 10/8/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EDocReimburse: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var reimburseJSON:JSON?
    
    var selectedTypeID:String = ""
    
    let remarkStr = "LEAVE_Reason".localized()
    
    @IBOutlet weak var typeIcon: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var startIcon: UIButton!
    @IBOutlet weak var startField: UITextField!
    
    @IBOutlet weak var amountIcon: UIButton!
    @IBOutlet weak var amountField: UITextField!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    
    var startPicker: UIDatePicker! = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("REIMBURSE REQUEST")
        
        
        typeField.delegate = self
        startField.delegate = self
        amountField.delegate = self
        remarkText.delegate = self
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        datePickerSetup(picker: startPicker)
        startField.inputView = startPicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        clearAttachFile()
        
        loadReimburse()
    }
    
    func loadReimburse() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"reimburse/getreimbursetypes", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.reimburseJSON = json["data"][0]["reimbursetypes"]
                
                self.typePicker.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
        else if textField == startField && startField.text == "" {
            datePickerChanged(picker: startPicker)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if typeField.text == "" || startField.text == "" || amountField.text == "" {
            submitBtn.disableBtn()
        }
        else{
            submitBtn.enableBtn()
        }
        
        if amountField.text == "" {
            amountIcon.setImage(UIImage(named: "form_money_off"), for: .normal)
        }
        else{
            amountIcon.setImage(UIImage(named: "form_money_on"), for: .normal)
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
        let selectDate = appStringFromDate(date: picker.date, format: "dd MMM yyyy")
        
        if picker == startPicker {
            startField.text = selectDate
            startIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        }
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        case 2://head
            startField.becomeFirstResponder()
            
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
    
    @IBAction func attachmentAdd(_ sender: UIButton) {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: false)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                self.uploadImage.image = image
                self.uploadImage.isHidden = false
                self.uploadLabel.text = "image.jpg"
                self.addBtn.isHidden = true
                self.deleteBtn.isHidden = false
            }
        }
    }
    
    @IBAction func attachmentDelete(_ sender: UIButton) {
        clearAttachFile()
    }
    
    func clearAttachFile() {
        self.uploadImage.image = nil
        self.uploadImage.isHidden = true
        self.uploadLabel.text = "CHECKIN_Upload".localized()
        self.addBtn.isHidden = false
        self.deleteBtn.isHidden = true
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
        
        alert.title = "REIMBURSE_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        let startDate = dateToServerString(date: startPicker.date)
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")

        var parameters:Parameters = ["document_type_id":selectedTypeID ,
                                     "selectdate":startDate ,
                                     "amount":amountField.text! ,
                                     "reason":descriptionStr
        ]
        if uploadImage.image != nil {
            let base64Image = uploadImage.image!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "image")
        }
        //print(parameters)
        
        loadRequest(method:.post, apiName:"reimburse/setreimburse", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REQUEST\(json)")

                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        selectedTypeID = ""
        typeField.text = ""
        typeIcon.setImage(UIImage(named: "form_type_off"), for: .normal)
        
        startField.text = ""
        startPicker.date = Date()
        startIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        amountField.text = ""
        amountIcon.setImage(UIImage(named: "form_money_off"), for: .normal)
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearAttachFile()
        
        submitBtn.disableBtn()
    }
}

// MARK: - Picker Datasource
extension EDocReimburse: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && reimburseJSON!.count > 0{
            return reimburseJSON!.count
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
        
        if pickerView == typePicker && reimburseJSON!.count > 0{
            pickerLabel?.text = reimburseJSON![row]["name"].stringValue
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
extension EDocReimburse: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = reimburseJSON![row]["name"].stringValue
            typeIcon.setImage(UIImage(named: "form_type_on"), for: .normal)
            selectedTypeID = reimburseJSON![row]["id"].stringValue
        }
    }
}
