//
//  OTManual.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 15/11/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class OTManual: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var dateFromCalendar:Date?
    
    var typeJSON:JSON?
    var headJSON:JSON?
    
    var selectedTypeID:String = ""
    var selectedHour:String = ""
    var selectedHeadID:String = ""
    
    let remarkStr = "ATTENDANCE_Note".localized()
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var typeIcon: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!

    @IBOutlet weak var startIcon: UIButton!
    @IBOutlet weak var startField: UITextField!
    @IBOutlet weak var startBtn: UIButton!
    
    @IBOutlet weak var hourIcon: UIButton!
    @IBOutlet weak var hourField: UITextField!
    @IBOutlet weak var hourBtn: UIButton!
    
    @IBOutlet weak var endIcon: UIButton!
    @IBOutlet weak var endField: UITextField!
    @IBOutlet weak var endBtn: UIButton!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var headField: UITextField!
    @IBOutlet weak var headBtn: UIButton!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    var hourPicker: UIPickerView! = UIPickerView()
    var headPicker: UIPickerView! = UIPickerView()
    
    var startPicker: UIDatePicker! = UIDatePicker()
    var endPicker: UIDatePicker! = UIDatePicker()
    
    var hourArray = [String]()
    
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
        print("OT MANUAL")
        
        for i in 0..<24 {
            let hour:Double = Double(i)
            hourArray.append(String(hour+0.5))
            hourArray.append(String(hour+1))
        }
        
        typeField.delegate = self
        startField.delegate = self
        hourField.delegate = self
        endField.delegate = self
        remarkText.delegate = self
        headField.delegate = self
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        datePickerSetup(picker: startPicker)
        startField.inputView = startPicker
        
        pickerSetup(picker: hourPicker)
        hourField.inputView = hourPicker
        
        datePickerSetup(picker: endPicker)
        endField.inputView = endPicker
        
        pickerSetup(picker: headPicker)
        headField.inputView = headPicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.delegate = self
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        endField.isUserInteractionEnabled = false
        
        loadOT()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //typeField.becomeFirstResponder()
    }
    
    func loadOT() {
        let parameters:Parameters = [:]
        
        loadRequest(method:.get, apiName:"attendance/gettimeottype", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS OT\(json)")
                
                self.typeJSON = json["data"]["ot_type"]
                self.headJSON = json["data"]["head"]
                
                self.typePicker.reloadAllComponents()
                self.headPicker.reloadAllComponents()
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
        else if textField == hourField && hourField.text == "" {
            selectPicker(hourPicker, didSelectRow: 0)
        }
        else if textField == endField && endField.text == "" {
            datePickerChanged(picker: endPicker)
        }
        else if textField == headField && headField.text == "" {
            selectPicker(headPicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if typeField.text == "" || startField.text == "" || hourField.text == "" || endField.text == "" || headField.text == "" {
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
        
        picker.datePickerMode = .dateAndTime
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
        let selectDate = appStringFromDate(date: picker.date, format: "dd MMM yyyy HH:mm")
        var endDate = picker.date.addingTimeInterval(TimeInterval(1.0))//Add day diff 1 second
        
        if picker == startPicker {
            startField.text = selectDate
            startIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            
            if selectedHour != "" {
                let addTime = Double(selectedHour)!*60*60
                endDate = startPicker.date.addingTimeInterval(TimeInterval(addTime))
            }
            
            let selectEndDate = appStringFromDate(date: endDate, format: "dd MMM yyyy HH:mm")
            endField.text = selectEndDate
            endIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            endPicker.date = endDate
        }
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        case 2://start date
            startField.becomeFirstResponder()
            
        case 3://hour
            hourField.becomeFirstResponder()
            
        case 4://end date
            endField.becomeFirstResponder()
            
        case 5://head
            headField.becomeFirstResponder()
            
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
        
        alert.title = "OT_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        let startDate = dateAndTimeToServerString(date: startPicker.date)
        let endDate = dateAndTimeToServerString(date: endPicker.date)
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        
        let parameters:Parameters = ["type":selectedTypeID ,
                                     "timein":startDate ,
                                     "total_hours":selectedHour ,
                                     "timeout":endDate ,
                                     "remark":descriptionStr ,
                                     "head_id":selectedHeadID
        ]
        print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/settimeot_manual", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS OT REQUEST\(json)")

                self.submitSuccess()
                self.clearForm()
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                    self.popBackToHistoryTab()
                }
            }
        }
    }
    
    func popBackToHistoryTab ()
    {
        //Pop to OT history tab
        for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: OT.self) {
                        let vc = controller as! OT
                        vc.historyBtn.sendActions(for: .touchUpInside)
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
        }
    }
    
    func clearForm() {
        typeJSON = nil
        headJSON = nil
        
        selectedTypeID = ""
        typeField.text = ""
        typeIcon.setImage(UIImage(named: "form_type_off"), for: .normal)
        
        startField.text = ""
        startPicker.date = Date()
        startIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        selectedHour = ""
        hourField.text = ""
        hourIcon.setImage(UIImage(named: "form_time_off"), for: .normal)
        
        endField.text = ""
        endPicker.date = Date()
        endIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        selectedHeadID = ""
        headField.text = ""
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        submitBtn.disableBtn()
    }
}

// MARK: - Picker Datasource
extension OTManual: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && typeJSON != nil {
            return typeJSON!.count
        }
        else if pickerView == hourPicker {
            return hourArray.count
        }
        else if pickerView == headPicker && headJSON != nil {
            return headJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePicker && typeJSON!.count > 0{
            return typeJSON![row]["name"].stringValue
        }
        else if pickerView == hourPicker && hourArray.count > 0{
            return hourArray[row]
        }
        else if pickerView == headPicker && headJSON!.count > 0{
            return "\(headJSON![row]["first_name"].stringValue) \(headJSON![row]["last_name"].stringValue)"
        }
        else{
            return ""
        }
    }
}

// MARK: - Picker Delegate
extension OTManual: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["name"].stringValue
            typeIcon.setImage(UIImage(named: "form_type_on"), for: .normal)
            selectedTypeID = typeJSON![row]["id"].stringValue
        }
        else if pickerView == hourPicker {
            hourField.text = "\(hourArray[row]) "+"OT_Hour".localized()
            hourIcon.setImage(UIImage(named: "form_time_on"), for: .normal)
            selectedHour = hourArray[row]
            datePickerChanged(picker: startPicker)
        }
        else if pickerView == headPicker {
            headField.text = "\(headJSON![row]["first_name"].stringValue) \(headJSON![row]["last_name"].stringValue)"
            selectedHeadID = headJSON![row]["user_id"].stringValue
        }
    }
}

