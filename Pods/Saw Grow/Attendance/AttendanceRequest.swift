//
//  AttendanceRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 22/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class AttendanceRequest: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var dateFromCalendar:Date?
    
    var attendanceJSON:JSON?
    var headJSON:JSON?
    
    var selectedType:String = ""
    var selectedDate:String = ""
    var selectedClockTime:String = ""
    var selectedAdjustTime:String = ""
    
    let remarkStr = "ATTENDANCE_Note".localized()

    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var dateIcon: UIButton!
    @IBOutlet weak var dateField: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    
    @IBOutlet weak var normalTimeField: UITextField!
    @IBOutlet weak var realTimeField: UITextField!
    
    @IBOutlet weak var adjustTimeIcon: UIButton!
    @IBOutlet weak var adjustTimeField: UITextField!
    @IBOutlet weak var adjustTimeBtn: UIButton!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    var datePicker: UIPickerView! = UIPickerView()
    var adjustTimePicker: UIDatePicker! = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ATTENDANCE REQUEST")
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:.dateChanged, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        dateField.delegate = self
        normalTimeField.delegate = self
        realTimeField.delegate = self
        adjustTimeField.delegate = self
        remarkText.delegate = self
        
        pickerSetup(picker: datePicker)
        dateField.inputView = datePicker
        
        datePickerSetup(picker: adjustTimePicker)
        adjustTimePicker.datePickerMode = .time
        adjustTimeField.inputView = adjustTimePicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        dateField.isUserInteractionEnabled = false
        adjustTimeField.isUserInteractionEnabled = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        monthYearField.becomeFirstResponder()
    }
    
    func loadAttendance(monthYear:Date) {
        let monthYearStr = appStringFromDate(date: monthYear, format: "yyyy-MM")
        let parameters:Parameters = ["ym":monthYearStr]
        
        loadRequest(method:.get, apiName:"attendance/gettimerequest", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.attendanceJSON = json["data"]["timesheet"]
                self.headJSON = json["data"]["head"]
                
                if self.attendanceJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                    self.dateField.isUserInteractionEnabled = true
                    self.selectPicker(self.datePicker, didSelectRow: 0)
                    self.adjustTimeField.isUserInteractionEnabled = true
                }
                else{
                    self.showErrorNoData()
                    self.dateField.isUserInteractionEnabled = false
                    self.adjustTimeField.isUserInteractionEnabled = false
                }
                self.datePicker.reloadAllComponents()
            }
        }
    }
    
    @objc func myDateChanged(notification:Notification){
        clearForm()
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromString(dateStr: (userInfo?["date"]) as! String, format: "yyyy-MM-dd")!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
        monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        loadAttendance(monthYear: mySelectedDate)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == monthYearField && monthYearField.text == "" {
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
        else if textField == dateField && dateField.text == "" {
            selectPicker(datePicker, didSelectRow: 0)
        }
        else if textField == adjustTimeField && adjustTimeField.text == "" {
            datePickerChanged(picker: adjustTimePicker)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if monthYearField.text == "" || dateField.text == "" || adjustTimeField.text == "" {
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
        picker.setValue(UIColor.themeColor, forKeyPath: "textColor")
    }
    
    func datePickerSetup(picker:UIDatePicker) {
        if #available(iOS 13.4, *) {
            picker.preferredDatePickerStyle = .wheels
        } else {
            // Fallback on earlier versions
        }
        
        picker.datePickerMode = .date
        
        // For 24 Hrs
        picker.locale = Locale(identifier: "en_GB")

        //For 12 Hrs
        //picker.locale = Locale(identifier: "en_US")
        
        //picker.minimumDate = Date()
        picker.date = Date()
        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
        
        picker.setValue(false, forKey: "highlightsToday")
        picker.setValue(UIColor.white, forKeyPath: "backgroundColor")
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @objc func datePickerChanged(picker: UIDatePicker) {
        if picker == adjustTimePicker {
            let selectTime = appStringFromDate(date: picker.date, format: "HH:mm")
            adjustTimeField.text = selectTime
            adjustTimeIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
        }
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://month & year
            monthYearField.becomeFirstResponder()
            
        case 2://date
            dateField.becomeFirstResponder()
            
        case 3://adjust time
            adjustTimeField.becomeFirstResponder()
            
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
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "ATTENDANCE_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        
        selectedAdjustTime = appStringFromDate(date: adjustTimePicker.date, format: "HH:mm")
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        //print("TYPE =\(selectedType) \nDATE =\(selectedDate) \nCLOCKTIME =\(selectedClockTime) \nTIME =\(selectedAdjustTime) \nREMARK =\(descriptionStr) \nSTATUS = 1 \n")

        let parameters:Parameters = ["type":selectedType ,
                                     "date":selectedDate ,
                                     "clocktime":selectedClockTime ,
                                     "time":selectedAdjustTime ,
                                     "reason":descriptionStr ,
                                     "status":"1"
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/settimerequest", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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
        attendanceJSON = nil
        
        selectedType = ""
        selectedDate = ""
        selectedClockTime = ""
        selectedAdjustTime = ""
        
        monthYearField.text = ""
        //monthYearPicker.date = Date()
        monthYearIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        dateField.text = ""
        datePicker.reloadAllComponents()
        dateIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        normalTimeField.text = ""
        realTimeField.text = ""
        
        adjustTimeField.text = ""
        adjustTimePicker.date = Date()
        adjustTimeIcon.setImage(UIImage(named: "form_time_off"), for: .normal)
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        submitBtn.disableBtn()
    }
}

// MARK: - Picker Datasource
extension AttendanceRequest: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == datePicker && attendanceJSON != nil {
            return attendanceJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        
        var componentView: UIView!
        var pickerLabel: UILabel!
        var pickerLabel2: UILabel!
        
        if view == nil {
            let space = 20.0
            let rowHeight = datePicker.rowSize(forComponent: 0).height
            let rowWidth = pickerView.frame.size.width - (space*2)
            
            componentView = UIView(frame: CGRect(x: space, y: 0, width: rowWidth, height: rowHeight))
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rowWidth/2, height: rowHeight))
            pickerLabel2 = UILabel(frame: CGRect(x: rowWidth/2, y: 0, width: rowWidth/2, height: rowHeight))
            
            componentView.addSubview(pickerLabel)
            componentView.addSubview(pickerLabel2)
        }
        
        // title
        let myTitle = NSAttributedString(string: attendanceJSON![row]["datestr"].stringValue, attributes: [NSAttributedString.Key.font:UIFont.Roboto_Regular(ofSize: 20) ,NSAttributedString.Key.foregroundColor:UIColor.textDarkGray])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .left
        
        // subtitle
        let mySubtitle = NSAttributedString(string: "(\(attendanceJSON![row]["desc"].stringValue))", attributes: [NSAttributedString.Key.font:UIFont.Roboto_Regular(ofSize: 20) ,NSAttributedString.Key.foregroundColor:UIColor.themeColor])
        pickerLabel2.attributedText = mySubtitle
        pickerLabel2.textAlignment = .right
        
        return componentView
    }
}

// MARK: - Picker Delegate
extension AttendanceRequest: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == datePicker {
            
            let cellArray = self.attendanceJSON![row]
            selectedType = cellArray["type"].stringValue
            selectedDate = cellArray["date"].stringValue
            selectedClockTime = cellArray["clocktime"].stringValue
            
            dateField.text = "\(cellArray["datestr"].stringValue) (\(cellArray["desc"].stringValue))"
            dateIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            normalTimeField.text = cellArray["defaulttime"].stringValue
            realTimeField.text = cellArray["clocktime"].stringValue
            
            adjustTimeIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
            adjustTimeField.text = cellArray["defaulttime"].stringValue
            adjustTimePicker.date = appDateFromString(dateStr: adjustTimeField.text!, format: "HH:mm")!
            
            adjustTimeField.isUserInteractionEnabled = true
        }
    }
}
