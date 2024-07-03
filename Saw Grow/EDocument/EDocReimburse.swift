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
    
    let alertService = AlertService()
    
    var uploadFileURL:URL? = nil
    
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
                //ProgressHUD.dismiss()
                
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
        let selectDate = appStringFromDate(date: picker.date, format: DateFormatter.appDateFormatStr)
        
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
            AttachmentHandler.shared.showImageAndFileActionSheet(vc: self, allowEdit: false)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                /* get your image here */
                self.uploadImage.image = image
                self.uploadImage.isHidden = false
                self.uploadLabel.text = "image.jpg"
                self.addBtn.isHidden = true
                self.deleteBtn.isHidden = false
            }
            AttachmentHandler.shared.filePickedBlock = { (fileURLPath) in
                /* get your file URL path here */
                //print(fileURL)
                let fileData = NSData(contentsOf: fileURLPath)
                print(fileData!.count)
                print(fileData!.count.byteSize)
                
                let fileSizeLimit = 2000000//2 MB
                if fileData!.count > fileSizeLimit {
                    let alertTitle = "\("Upload_File_Limit".localized()) (\(fileSizeLimit.byteSize))"
                    let alertOK = self.alertService.alertOK(title: alertTitle, buttonColor: .buttonRed)
                    {
                    }
                    self.present(alertOK, animated: true)
                }
                else {
                    self.uploadFileURL = fileURLPath
                    
                    let fullName = fileURLPath.lastPathComponent
                    if fullName.count > 30 {
                        let shortName = fullName.replacingOccurrences(of: fullName.dropFirst(12).dropLast(12), with: "...")
                        self.uploadLabel.text = shortName
                    }
                    else {
                        self.uploadLabel.text = fullName
                    }
                    self.uploadImage.isHidden = true
                    
                    self.addBtn.isHidden = true
                    self.deleteBtn.isHidden = false
                }
            }
        }
    }
    
    @IBAction func attachmentDelete(_ sender: UIButton) {
        clearAttachFile()
    }
    
    func clearAttachFile() {
        uploadImage.image = nil
        uploadImage.isHidden = true
        uploadLabel.text = "Upload_File".localized()
        addBtn.isHidden = false
        deleteBtn.isHidden = true
        
        uploadFileURL = nil
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        let alertMain = alertService.alertMain(title: "REIMBURSE_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .themeColor)
        {
            self.loadSubmit()
        }
        present(alertMain, animated: true)
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
        if uploadFileURL != nil {
            let fileData = NSData(contentsOf: uploadFileURL!)
            let base64PDF = fileData!.base64EncodedString(options: .endLineWithLineFeed)
            //print(base64PDF.count)
            parameters.updateValue(base64PDF, forKey: "pdf")
        }
        //print(parameters)
        
        loadRequest(method:.post, apiName:"reimburse/setreimburse", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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
