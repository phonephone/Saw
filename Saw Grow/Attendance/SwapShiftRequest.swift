//
//  SwapShiftRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 23/1/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class SwapShiftRequest: UIViewController, UITextFieldDelegate, UITextViewDelegate, PeopleDelegate {
    
    var dateFromCalendar:Date?
    var myUserID:String?
    var myName:String?
    
    var myShiftJSON:JSON?
    var otherShiftJSON:JSON?
    
    var selectedMyShiftDate:String = ""
    var selectedMyShiftTime:String = ""
    var selectedOtherID:String = ""
    var selectedOtherShiftDate:String = ""
    var selectedOtherShiftTime:String = ""
    
    let remarkStr = "SWAP_Note".localized()
    
    @IBOutlet weak var myNameField: UITextField!
    
    @IBOutlet weak var myShiftIcon: UIButton!
    @IBOutlet weak var myShiftField: UITextField!
    @IBOutlet weak var myShiftBtn: UIButton!
    
    @IBOutlet weak var otherNameIcon: UIButton!
    @IBOutlet weak var otherNameField: UITextField!
    @IBOutlet weak var otherNameBtn: UIButton!
    
    @IBOutlet weak var otherShiftIcon: UIButton!
    @IBOutlet weak var otherShiftField: UITextField!
    @IBOutlet weak var otherShiftBtn: UIButton!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    var myShiftPicker: UIPickerView! = UIPickerView()
    var otherNamePicker: UIPickerView! = UIPickerView()
    var otherShiftPicker: UIPickerView! = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SWAP REQUEST")
        
        myNameField.text = myName
        
        myShiftField.delegate = self
        otherNameField.delegate = self
        otherShiftField.delegate = self
        remarkText.delegate = self
        
        pickerSetup(picker: myShiftPicker)
        myShiftField.inputView = myShiftPicker
        
        pickerSetup(picker: otherNamePicker)
        otherNameField.inputView = otherNamePicker
        
        pickerSetup(picker: otherShiftPicker)
        otherShiftField.inputView = otherShiftPicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        myShiftField.isUserInteractionEnabled = false
        otherShiftField.isUserInteractionEnabled = false
        
        loadMyShift()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //myShiftField.becomeFirstResponder()
    }
    
    func loadMyShift() {
        let parameters:Parameters = ["q":myUserID!]

        loadRequest(method:.get, apiName:"attendance/gettimeswap", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS MY SHIFT\(json)")

                self.myShiftJSON = json["data"]["timesheet"]
                
                
                if self.myShiftJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                    self.myShiftField.isUserInteractionEnabled = true
                    self.selectPicker(self.myShiftPicker, didSelectRow: 0)
                }
                else{
                    self.showErrorNoData()
                    self.myShiftField.isUserInteractionEnabled = false
                }
                self.myShiftPicker.reloadAllComponents()
            }
        }
    }
    
    func loadOtherShift() {
        let parameters:Parameters = ["q":selectedOtherID]

        loadRequest(method:.get, apiName:"attendance/gettimeswap", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS OTHER SHIFT\(json)")

                self.otherShiftJSON = json["data"]["timesheet"]
                
                if self.otherShiftJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                    self.otherShiftField.isUserInteractionEnabled = true
                    self.selectPicker(self.otherShiftPicker, didSelectRow: 0)
                }
                else{
                    self.showErrorNoData()
                    self.otherShiftField.isUserInteractionEnabled = false
                }
                self.otherShiftPicker.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == myShiftField && myShiftField.text == "" {
            selectPicker(myShiftPicker, didSelectRow: 0)
        }
        else if textField == otherNameField {
            peopleClicked()
        }
        else if textField == otherShiftField && otherShiftField.text == "" {
            selectPicker(otherShiftPicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if myShiftField.text == "" || otherNameField.text == "" || otherShiftField.text == "" {
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
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://my shift
            myShiftField.becomeFirstResponder()
            
        case 2://other name
            peopleClicked()
            
        case 3://other field
            otherShiftField.becomeFirstResponder()
            
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
        
        alert.title = "SWAP_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        //print("MYID =\(myUserID) \nOTHERID =\(selectedOtherID) \nDATE =\(selectedMyShiftDate) \nTIME =\(selectedMyShiftTime) \nTO DATE =\(selectedOtherShiftDate) \nTO TIME =\(selectedOtherShiftTime) \nREMARK =\(descriptionStr)\n")

        let parameters:Parameters = ["user_id":myUserID! ,
                                     "to_user_id":selectedOtherID ,
                                     "date":selectedMyShiftDate ,
                                     "time":selectedMyShiftTime ,
                                     "to_date":selectedOtherShiftDate ,
                                     "to_time":selectedOtherShiftTime ,
                                     "reason":descriptionStr ,
                                     "type":"n"
        ]
        print(parameters)

        loadRequest(method:.post, apiName:"attendance/settimeswap", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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
        myShiftJSON = nil
        selectedMyShiftDate = ""
        selectedMyShiftTime = ""

        myShiftField.text = ""
        myShiftPicker.reloadAllComponents()
        myShiftIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        clearOtherName()
        clearOtherShift()
        
        submitBtn.disableBtn()
    }
    
    func clearOtherName() {
        selectedOtherID = ""
        
        otherNameField.text = ""
        otherNamePicker.reloadAllComponents()
        otherNameIcon.setImage(UIImage(named: "form_person_off"), for: .normal)
        
        otherNameField.isUserInteractionEnabled = false
    }
    
    func clearOtherShift() {
        otherShiftJSON = nil
        selectedOtherShiftDate = ""
        selectedOtherShiftTime = ""
        
        otherShiftField.text = ""
        otherShiftPicker.reloadAllComponents()
        otherShiftIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        otherShiftField.isUserInteractionEnabled = false
    }
    
    func peopleClicked() {
        otherNameField.resignFirstResponder()
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "PeopleSelector") as! PeopleSelector
        vc.delegate = self
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    func selectPeople(peopleArr: JSON) {
        selectedOtherID = peopleArr["user_id"].stringValue
        otherNameIcon.setImage(UIImage(named: "form_person_on"), for: .normal)
        otherNameField.text = "\(peopleArr[self.firstNameKey()].stringValue) \(peopleArr[self.lastNameKey()].stringValue)"
        
        clearOtherShift()
        loadOtherShift()
    }
}

// MARK: - Picker Datasource
extension SwapShiftRequest: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == myShiftPicker && myShiftJSON != nil {
            return myShiftJSON!.count
        }
        else if pickerView == otherShiftPicker && otherShiftJSON != nil {
            return otherShiftJSON!.count
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
        
        var cellArray:JSON?

        if pickerView == myShiftPicker {
            cellArray = myShiftJSON![row]
        }
        else if pickerView == otherShiftPicker {
            cellArray = otherShiftJSON![row]
        }
        
        if view == nil {
            let space = 20.0
            let rowHeight = myShiftPicker.rowSize(forComponent: 0).height
            let rowWidth = pickerView.frame.size.width - (space*2)

            componentView = UIView(frame: CGRect(x: space, y: 0, width: rowWidth, height: rowHeight))
            pickerLabel = UILabel(frame: CGRect(x: 0, y: 0, width: rowWidth/2, height: rowHeight))
            pickerLabel2 = UILabel(frame: CGRect(x: rowWidth/2, y: 0, width: rowWidth/2, height: rowHeight))

            componentView.addSubview(pickerLabel)
            componentView.addSubview(pickerLabel2)
        }

        // title
        let myTitle = NSAttributedString(string: cellArray!["datestr"].stringValue, attributes: [NSAttributedString.Key.font:UIFont.Roboto_Regular(ofSize: 20) ,NSAttributedString.Key.foregroundColor:UIColor.textDarkGray])
        pickerLabel.attributedText = myTitle
        pickerLabel.textAlignment = .left

        // subtitle
        let mySubtitle = NSAttributedString(string: "(\(cellArray!["desc"].stringValue))", attributes: [NSAttributedString.Key.font:UIFont.Roboto_Regular(ofSize: 20) ,NSAttributedString.Key.foregroundColor:UIColor.themeColor])
        pickerLabel2.attributedText = mySubtitle
        pickerLabel2.textAlignment = .right

        return componentView
    }
}

// MARK: - Picker Delegate
extension SwapShiftRequest: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == myShiftPicker {
            let cellArray = self.myShiftJSON![row]
            selectedMyShiftDate = cellArray["date"].stringValue
            selectedMyShiftTime = cellArray["desc"].stringValue
            myShiftIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            myShiftField.text = "\(cellArray["datestr"].stringValue) (\(cellArray["desc"].stringValue))"
            
            textFieldDidEndEditing(myShiftField)
            
            //clearOtherName()
            //clearOtherShift()
            //loadOtherName
        }
        else if pickerView == otherShiftPicker {
            let cellArray = self.otherShiftJSON![row]
            selectedOtherShiftDate = cellArray["date"].stringValue
            selectedOtherShiftTime = cellArray["desc"].stringValue
            otherShiftIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            otherShiftField.text = "\(cellArray["datestr"].stringValue) (\(cellArray["desc"].stringValue))"
            
            textFieldDidEndEditing(otherShiftField)
        }
        
        
    }
}

