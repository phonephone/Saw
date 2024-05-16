//
//  LeaveRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 28/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class LeaveRequest: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var dateFromCalendar:Date?
    
    var leaveJSON:JSON?
    var headJSON:JSON?
    
    var selectedTypeID:String = ""
    var selectedHalfDay:String = "0"
    var selectedHeadID:String = ""
    
    let remarkStr = "LEAVE_Reason".localized()
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    @IBOutlet weak var typeIcon: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var fullDayBtn: UIButton!
    @IBOutlet weak var halfDayBtn: UIButton!
    
    @IBOutlet weak var halfView: UIView!
    @IBOutlet weak var halfDayBtn1: UIButton!
    @IBOutlet weak var halfDayBtn2: UIButton!
    @IBOutlet weak var hourBtn: UIButton!
    
    @IBOutlet weak var timeStack: UIStackView!
    @IBOutlet weak var startTimeIcon: UIButton!
    @IBOutlet weak var startTimeField: UITextField!
    @IBOutlet weak var endTimeIcon: UIButton!
    @IBOutlet weak var endTimeField: UITextField!
    
    @IBOutlet weak var startIcon: UIButton!
    @IBOutlet weak var startField: UITextField!
    
    @IBOutlet weak var endIcon: UIButton!
    @IBOutlet weak var endField: UITextField!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var headField: UITextField!
    @IBOutlet weak var headBtn: UIButton!
    
    @IBOutlet weak var uploadImage: UIImageView!
    @IBOutlet weak var uploadLabel: UILabel!
    @IBOutlet weak var addBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    var headPicker: UIPickerView! = UIPickerView()
    
    var startPicker: UIDatePicker! = UIDatePicker()
    var endPicker: UIDatePicker! = UIDatePicker()
    
    var startTimePicker: UIDatePicker! = UIDatePicker()
    var endTimePicker: UIDatePicker! = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LEAVE REQUEST")
        
        myScrollView.contentInset = UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0)
        
        typeField.delegate = self
        startField.delegate = self
        endField.delegate = self
        startTimeField.delegate = self
        endTimeField.delegate = self
        remarkText.delegate = self
        headField.delegate = self
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        datePickerSetup(picker: startPicker)
        startField.inputView = startPicker
        
        datePickerSetup(picker: endPicker)
        endField.inputView = endPicker
        
        timePickerSetup(picker: startTimePicker)
        startTimeField.inputView = startTimePicker
        
        timePickerSetup(picker: endTimePicker)
        endTimeField.inputView = endTimePicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        pickerSetup(picker: headPicker)
        headField.inputView = headPicker
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        if dateFromCalendar != nil//Come From Calendar
        {
            let calendarDate = appStringFromDate(date: dateFromCalendar!, format: DateFormatter.appDateFormatStr)
            startField.text = calendarDate
            startIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            startPicker.date = dateFromCalendar!
            endPicker.minimumDate = startPicker.date
        }
        
        clearAttachFile()
        
        loadLeave()
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    func loadLeave() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"attendance/getleavetypes", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.leaveJSON = json["data"][0]["leavetypes"]
                self.headJSON = json["data"][0]["head"]
                
                self.typePicker.reloadAllComponents()
                self.headPicker.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
        else if textField == headField && headField.text == "" {
            selectPicker(headPicker, didSelectRow: 0)
        }
        else if textField == startField && startField.text == "" {
            datePickerChanged(picker: startPicker)
        }
        else if textField == endField && endField.text == "" {
            datePickerChanged(picker: endPicker)
        }
        else if textField == startTimeField && startTimeField.text == "" {
            timePickerChanged(picker: startTimePicker)
        }
        else if textField == endTimeField && endTimeField.text == "" {
            timePickerChanged(picker: endTimePicker)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkForm()
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        case 2://head
            headField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func dayClick(_ sender: UIButton) {
        halfView.isHidden = true
        fullDayBtn.segmentOff()
        halfDayBtn.segmentOff()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            selectedHalfDay = "0"
            halfView.isHidden = true
            clearTime()
            
        case 2:
            selectedHalfDay = "1"
            halfView.isHidden = false
            halfDayBtn1.segmentOn()
            halfDayBtn2.segmentOff()
            hourBtn.segmentOff()
        
        default:
            break
        }
        checkForm()
    }
    
    @IBAction func halfClick(_ sender: UIButton) {
        halfDayBtn1.segmentOff()
        halfDayBtn2.segmentOff()
        hourBtn.segmentOff()
        clearTime()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            selectedHalfDay = "1"
        case 2:
            selectedHalfDay = "2"
        case 3:
            selectedHalfDay = "3"
            timeStack.isHidden = false
            
        default:
            break
        }
        checkForm()
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
        let totalDay = daysBetween(start: startPicker.date, end: endPicker.date)
        
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        let dateFormat = "dd/MM/yyyy"
        let startDate = appStringFromDate(date: startPicker.date, format: dateFormat)
        let endDate = appStringFromDate(date: endPicker.date, format: dateFormat)
        
        switch selectedHalfDay {
        case "0"://Full Day
            if startDate == endDate {
                alert.title = "\("LEAVE_Confirm".localized())\n\(startDate)\n(\(totalDay) \("Day".localized()))"
            }
            else {
                alert.title = "\("LEAVE_Confirm".localized())\n\(startDate) - \(endDate)\n(\(totalDay) \("Day".localized()))"
            }
            
        case "1"://1st Half
            alert.title = "\("LEAVE_Confirm".localized())\n\(startDate)\n(\("LEAVE_Half_Date".localized()), \("LEAVE_Half_Date1".localized()))"
            
        case "2"://2nd Half
            alert.title = "\("LEAVE_Confirm".localized())\n\(startDate)\n(\("LEAVE_Half_Date".localized()), \("LEAVE_Half_Date2".localized()))"
            
        case "3"://Hour
            alert.title = "\("LEAVE_Confirm".localized())\n\(startDate)\n(\(startTimeField.text!) - \(endTimeField.text!))"
            
        default:
            break
        }
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
        var endDate = dateToServerString(date: endPicker.date)
        if selectedHalfDay != "0" {
            endDate = startDate
        }
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")
        
        var parameters:Parameters = ["leave_type":selectedTypeID ,
                                     "start_date":startDate ,//gps, qr
                                     "end_date":endDate ,//in, update, out
                                     "reason":descriptionStr ,
                                     "leave_half_day":selectedHalfDay,
                                     "head_id":selectedHeadID
        ]
        if selectedHalfDay == "3" {//Hour
            parameters.updateValue(startTimeField.text!, forKey: "time_in")
            parameters.updateValue(endTimeField.text!, forKey: "time_out")
        }
        if uploadImage.image != nil {
            let base64Image = uploadImage.image!.convertImageToBase64String()
            parameters.updateValue(base64Image, forKey: "image")
        }
        print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/setleaves", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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
        
        endField.text = ""
        endPicker.date = Date()
        endIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        selectedHalfDay = "0"
        fullDayBtn.segmentOn()
        
        halfDayBtn.segmentOff()
        halfView.isHidden = true
        halfDayBtn1.segmentOff()
        halfDayBtn2.segmentOff()
        hourBtn.segmentOff()
        clearTime()
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        selectedHeadID = ""
        headField.text = ""
        
        clearAttachFile()
        
        submitBtn.disableBtn()
    }
    
    func clearTime() {
        timeStack.isHidden = true
        startTimeField.text = ""
        startTimePicker.date = Date()
        startTimeIcon.setImage(UIImage(named: "form_time_off"), for: .normal)
        
        endTimeField.text = ""
        endTimePicker.date = Date()
        endTimeIcon.setImage(UIImage(named: "form_time_off"), for: .normal)
    }
    
    func checkForm() {
        if typeField.text == "" || startField.text == "" || endField.text == "" || headField.text == "" {
            
            submitBtn.disableBtn()
        }
        else{
            if selectedHalfDay == "3" {
                if startTimeField.text == "" || endTimeField.text == "" {
                    submitBtn.disableBtn()
                }
                else {
                    submitBtn.enableBtn()
                }
            }
            else {
                submitBtn.enableBtn()
            }
        }
    }
}

// MARK: - Picker Datasource
extension LeaveRequest: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && leaveJSON!.count > 0{
            return leaveJSON!.count
        }
        else if pickerView == headPicker && headJSON!.count > 0{
            return headJSON!.count
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
        
        if pickerView == typePicker && leaveJSON!.count > 0{
            pickerLabel?.text = leaveJSON![row]["Category_Name".localized()].stringValue
        }
        else if pickerView == headPicker && headJSON!.count > 0{
            pickerLabel?.text = "\(headJSON![row][self.firstNameKey()].stringValue) \(headJSON![row][self.lastNameKey()].stringValue)"
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
extension LeaveRequest: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = leaveJSON![row]["Category_Name".localized()].stringValue
            typeIcon.setImage(UIImage(named: "form_type_on"), for: .normal)
            selectedTypeID = leaveJSON![row]["leavetype"].stringValue
        }
        else if pickerView == headPicker {
            headField.text = "\(headJSON![row][self.firstNameKey()].stringValue) \(headJSON![row][self.lastNameKey()].stringValue)"
            selectedHeadID = headJSON![row]["user_id"].stringValue
        }
    }
}

// MARK: - Date Date & Time
extension LeaveRequest {
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
        let endDate = picker.date.addingTimeInterval(TimeInterval(1.0))//Add day diff 1 second
        
        if picker == startPicker {
            startField.text = selectDate
            startIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            
            if startPicker.date > endPicker.date {
                endField.text = selectDate
                endPicker.date = endDate
            }
            endPicker.minimumDate = endDate
        }
        else if picker == endPicker {
            endField.text = selectDate
            endIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        }
        
        checkForm()
//        print("START \(startPicker.date)")
//        print("END \(endPicker.date)")
//        let totalDay = daysBetween(start: startPicker.date, end: endPicker.date)
//        print("DIFF \(totalDay)")
    }
    
    func timePickerSetup(picker:UIDatePicker) {
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        picker.datePickerMode = .time
        picker.minuteInterval = 30
        picker.locale = Locale(identifier: "en_GB")
        //picker.minimumDate = Date()
        picker.calendar = Calendar(identifier: .gregorian)
        picker.date = Date()
        picker.addTarget(self, action: #selector(timePickerChanged(picker:)), for: .valueChanged)
        
        picker.setValue(UIColor.white, forKeyPath: "backgroundColor")
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @objc func timePickerChanged(picker: UIDatePicker) {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm"
        let selectTime = timeFormatter.string(from: picker.date)
        
        if picker == startTimePicker {
            startTimeField.text = selectTime
            startTimeIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
            
            let endTimeAddHour = picker.date.addingTimeInterval(TimeInterval(60*60))//Add 1 hour
            
            let time1 = 60*Calendar.current.component(.hour, from: startTimePicker.date) + Calendar.current.component(.minute, from: startTimePicker.date)
            let time2 =  60*Calendar.current.component(.hour, from: endTimePicker.date) + Calendar.current.component(.minute, from: endTimePicker.date)
            
            print(time1)
            print(time2)
            
            if time2 - time1 <= 30 {
                endTimeField.text = timeFormatter.string(from: endTimeAddHour)
                endTimePicker.date = endTimeAddHour
                endTimeIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
            }
            endTimePicker.minimumDate = endTimeAddHour
        }
        else if picker == endTimePicker {
            endTimeField.text = selectTime
            endTimeIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
        }
        
        checkForm()
    }
    
    func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day! + 1
    }
}
