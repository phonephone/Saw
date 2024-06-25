//
//  OTRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 12/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class OTRequest: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var dateFromCalendar:Date?
    
    var otJSON:JSON?
    
    var selectedOT:[String] = []
    
    var firstTime = true
    
    let alertService = AlertService()

    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OT REQUEST")
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        myDatePicker.notificationName = .request
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:myDatePicker.notificationName, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        
        clearForm()
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTime {
            monthYearField.becomeFirstResponder()
            firstTime = false
        }
    }
    
    func loadOT(monthYear:Date) {
        let monthYearStr = monthAndYearToServerString(date: monthYear)
        let parameters:Parameters = ["ym":monthYearStr]
        
        loadRequest(method:.get, apiName:"attendance/gettimeot", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.otJSON = json["data"]["timesheet"]
                self.myCollectionView.reloadData()
                
                if self.otJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                }
                else{
                    self.showErrorNoData()
                }
            }
        }
    }
    
    @objc func myDateChanged(notification:Notification){
        clearForm()
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromServerString(dateStr: (userInfo?["date"]) as! String)!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: DateFormatter.appMonthYearFormatStr)
        monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        loadOT(monthYear: mySelectedDate)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == monthYearField && monthYearField.text == "" {
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://month & year
            monthYearField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @IBAction func manualClick(_ sender: UIButton) {
        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OTManual") as! OTManual
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        let alertMain = alertService.alertMain(title: "OT_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .themeColor)
        {
            self.loadSubmit()
        }
        present(alertMain, animated: true)
    }
    
    func loadSubmit() {
        print(selectedOT)
        var selectID = ""
        for i in 0..<selectedOT.count {
            if i == 0{
                selectID = selectedOT[i]
            }
            else{
                selectID += "," + selectedOT[i]
            }
        }
        print(selectID)
         
        let parameters:Parameters = ["id":selectID
        ]
        //print(parameters)

        loadRequest(method:.post, apiName:"attendance/settimeot", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS OT\(json)")

                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        otJSON = nil
        
        selectedOT.removeAll()
        
        monthYearField.text = ""
        //monthYearPicker.date = Date()
        monthYearIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        myCollectionView.reloadData()
        
        submitBtn.disableBtn()
    }
}

// MARK: - UICollectionViewDataSource

extension OTRequest: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (otJSON != nil) {
            return otJSON!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

//        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NotificationHeader_Cell", for: indexPath) as? NotificationHeader_Cell
//        {
//            headerCell.cellBtnReadAll.addTarget(self, action: #selector(readAllClick(_:)), for: .touchUpInside)
//
//            return headerCell
//        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.otJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"OTRequest_Cell", for: indexPath) as! OTRequest_Cell
        
        //cell.layer.cornerRadius = 15
        
        cell.cellDate.text = cellArray["datestr"].stringValue
        cell.cellTime.text = cellArray["desc"].stringValue
        cell.cellHour.text = cellArray["count"].stringValue
        cell.cellBtnCheckbox.addTarget(self, action: #selector(checkboxClick(_:)), for: .touchUpInside)
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension OTRequest: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width
        //let viewHeight = collectionView.frame.height
        return CGSize(width: viewWidth , height:88)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegate

extension OTRequest: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        updateCheckbox(indexPath: indexPath)
    }
    
    @IBAction func checkboxClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myCollectionView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        updateCheckbox(indexPath: indexPath)
    }
    
    func updateCheckbox(indexPath: IndexPath) {
        let cellArray = self.otJSON![indexPath.item]
        let id = cellArray["id"].stringValue
        
        let cell = myCollectionView.cellForItem(at: indexPath) as! OTRequest_Cell
        
        if let index = selectedOT.firstIndex(of: id) {
            selectedOT.remove(at: index)
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
        }
        else {
            selectedOT += [id]
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
        }
        
        if selectedOT.count > 0 {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
}
