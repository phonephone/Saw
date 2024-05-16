//
//  ProbationResult.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ProbationResult: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var typeJSON:JSON?
    
    var edocName:String?
    var selectedPersonJSON:JSON?
    var scoreArray:[Int]?
    
    var selectedPass:String = ""
    var selectedTypeID:String = ""
    
    let remarkStr = "PROBATION_Note".localized()
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    
    @IBOutlet weak var failBtn: UIButton!
    @IBOutlet weak var passBtn: UIButton!
    
    @IBOutlet weak var typeView: UIView!
    @IBOutlet weak var typeIcon: UIButton!
    @IBOutlet weak var typeField: UITextField!
    @IBOutlet weak var typeBtn: UIButton!
    
    @IBOutlet weak var remarkText: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var typePicker: UIPickerView! = UIPickerView()
    
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
        print("PROBATION RESULT")
        
        headTitle.text = edocName
        
        scoreLabel.text = "\(scoreArray!.reduce(0, +))/\(scoreArray!.count*5)"
        
        typeField.delegate = self
        remarkText.delegate = self
        
        pickerSetup(picker: typePicker)
        typeField.inputView = typePicker
        
        //remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        typeView.isHidden = true
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == typeField && typeField.text == "" {
            selectPicker(typePicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        checkAll()
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://type
            typeField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func passClick(_ sender: UIButton) {
        clearForm()
        
        setSegmentBtn(button: sender)
        
        switch sender.tag {
        case 0://FAIL
            selectedPass = "1"
            typeView.isHidden = false
            
        case 1://PASS
            selectedPass = "2"
            typeView.isHidden = true
            
        default:
            break
        }
        checkAll()
    }
    
    func setSegmentBtn(button: UIButton) {
        if button.tag == 0 {//FAIL
            button.segmentOn(color: .buttonRed)
        }
        if button.tag == 1 {//PASS
            button.segmentOn(color: .buttonGreen)
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
        checkAll()
        
        return true
    }
    
    func checkAll() {
        if selectedPass == "1" {//FAIL
            if selectedTypeID == "" || remarkText.text == remarkStr {
                submitBtn.disableBtn()
            }
            else {
                submitBtn.enableBtn()
            }
        }
        else if selectedPass == "2" {//PASS
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
    
    func clearForm() {
        selectedPass = ""
        selectedTypeID = ""
        
        failBtn.segmentOff()
        passBtn.segmentOff()
        
        typeField.text = ""
        //typeIcon.setImage(UIImage(named: "form_warning"), for: .normal)
        
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        
        submitBtn.disableBtn()
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
        
        alert.title = "PROBATION_Confirm".localized()
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
        let scoreStrArray = scoreArray.map(String.init)

        var parameters:Parameters = ["user_id":selectedPersonJSON!["user_id"].stringValue ,
                                     "evaluate":scoreStrArray! ,
                                     "status":selectedPass ,//1 = fail, 2 = pass
                                     "remark_id":selectedTypeID,
                                     "reason":descriptionStr
        ]
        print(parameters)

        loadRequest(method:.post, apiName:"edocument/setprobation", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SUBMIT PROBATION\(json)")

                self.submitSuccess()
                self.clearForm()
            }
        }
        
        //Pop to EDOC history tab
        for controller in self.navigationController!.viewControllers as Array {
                    if controller.isKind(of: EDoc.self) {
                        let vc = controller as! EDoc
                        vc.historyBtn.sendActions(for: .touchUpInside)
                        self.navigationController!.popToViewController(controller, animated: true)
                        break
                    }
        }
        
        //navigationController?.popToViewController(ofClass: EDoc.self)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - Picker Datasource
extension ProbationResult: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == typePicker && typeJSON!.count > 0{
            return typeJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == typePicker && typeJSON!.count > 0{
            return typeJSON![row]["name"].stringValue
        }
        else{
            return ""
        }
    }
}

// MARK: - Picker Delegate
extension ProbationResult: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == typePicker {
            typeField.text = typeJSON![row]["name"].stringValue
            //typeIcon.setImage(UIImage(named: "form_type_on"), for: .normal)
            selectedTypeID = typeJSON![row]["id"].stringValue
        }
    }
}

