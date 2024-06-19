//
//  Probation.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 25/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class Probation: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var personJSON:JSON?
    var selectedPersonJSON:JSON?
    
    var edocName:String?
    var edocType:edocType?
    
    var selectedPersonID:String = ""
    
    @IBOutlet weak var nameIcon: UIButton!
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var nameBtn: UIButton!
    
    @IBOutlet weak var positionIcon: UIButton!
    @IBOutlet weak var positionField: UITextField!
    @IBOutlet weak var positionBtn: UIButton!
    
    @IBOutlet weak var startDateIcon: UIButton!
    @IBOutlet weak var startDateField: UITextField!
    @IBOutlet weak var startDateBtn: UIButton!
    
    @IBOutlet weak var requestDateIcon: UIButton!
    @IBOutlet weak var requestDateField: UITextField!
    @IBOutlet weak var requestDateBtn: UIButton!
    
    @IBOutlet weak var infoLabel1: UILabel!
    @IBOutlet weak var infoLabel2: UILabel!
    @IBOutlet weak var infoText: UITextView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    var personPicker: UIPickerView! = UIPickerView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PROBATION REQUEST")
        
        nameField.delegate = self
        positionField.delegate = self
        startDateField.delegate = self
        requestDateField.delegate = self
        
        pickerSetup(picker: personPicker)
        nameField.inputView = personPicker
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
        
        loadProbation()
    }
    
    func loadProbation() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"edocument/getemp_probation", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS PERSON\(json)")
                
                self.personJSON = json["data"][0]["emp"]
                
                self.personPicker.reloadAllComponents()
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == nameField && nameField.text == "" {
            selectPicker(personPicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if nameField.text == "" || positionField.text == "" || startDateField.text == "" || requestDateField.text == "" {
            
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
    
    func clearForm() {
        selectedPersonID = ""
        
        nameField.text = ""
        nameIcon.setImage(UIImage(named: "form_person_off"), for: .normal)
        
        positionField.text = ""
        positionIcon.setImage(UIImage(named: "form_person_off"), for: .normal)
        
        startDateField.text = ""
        startDateIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        requestDateField.text = ""
        requestDateIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        submitBtn.disableBtn()
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://person
            nameField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ProbationScore") as! ProbationScore
        vc.edocName = edocName
        vc.selectedPersonJSON = selectedPersonJSON
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

// MARK: - Picker Datasource
extension Probation: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == personPicker && personJSON!.count > 0{
            return personJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == personPicker && personJSON!.count > 0{
            return "\(personJSON![row]["first_name"].stringValue) \(personJSON![row]["last_name"].stringValue)"
        }
        else{
            return ""
        }
    }
}

// MARK: - Picker Delegate
extension Probation: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        if pickerView == personPicker {
            let cellArray = self.personJSON![row]
            
            nameField.text = "\(cellArray["first_name"].stringValue) \(cellArray["last_name"].stringValue)"
            nameIcon.setImage(UIImage(named: "form_person_on"), for: .normal)
            
            positionField.text = cellArray["designation_name"].stringValue
            positionIcon.setImage(UIImage(named: "form_person_on"), for: .normal)
            
            let joinDate = dateFromServerString(dateStr: cellArray["date_of_joining"].stringValue)
            startDateField.text = appStringFromDate(date: joinDate!, format: "d MMMM yyyy")
            startDateIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            
            requestDateField.text = appStringFromDate(date: Date(), format: "d MMMM yyyy")
            requestDateIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
            
            selectedPersonJSON = cellArray
        }
    }
}

