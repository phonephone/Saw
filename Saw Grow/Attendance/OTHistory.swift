//
//  OTHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 12/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class OTHistory: UIViewController, UITextFieldDelegate {
    
    var otJSON:JSON?
    
    var firstTime = true
    
    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var thisYearLabel: UILabel!
    @IBOutlet weak var thisMonthLabel: UILabel!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("OT HISTORY")
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:.dateChanged, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        
        self.hideKeyboardWhenTappedAround()
        
        thisYearLabel.text = "-"
        thisMonthLabel.text = "-"
        self.view.endEditing(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTime {
            monthYearField.becomeFirstResponder()
            firstTime = false
        }
    }
    
    func loadOT(monthYear:Date) {
        let monthYearStr = appStringFromDate(date: monthYear, format: "yyyy-MM")
        let parameters:Parameters = ["ym":monthYearStr]
        
        loadRequest(method:.get, apiName:"attendance/gettimeotstatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.otJSON = json["data"][0]["timeot"]
                self.thisYearLabel.text = json["data"][0]["yearcount"].stringValue
                self.thisMonthLabel.text = json["data"][0]["monthcount"].stringValue
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
        mySelectedDate = appDateFromString(dateStr: (userInfo?["date"]) as! String, format: "yyyy-MM-dd")!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: "MMMM yyyy")
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
    
    func clearForm() {
        otJSON = nil
        
        monthYearField.text = ""
        //monthYearPicker.date = Date()
        monthYearIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        myCollectionView.reloadData()
    }
}

// MARK: - UICollectionViewDataSource

extension OTHistory: UICollectionViewDataSource {
    
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
        
        cell.layer.cornerRadius = 15
        
        cell.cellDate.text = cellArray["datestr"].stringValue
        cell.cellTime.text = cellArray["desc"].stringValue
        cell.cellHour.text = cellArray["total_hours"].stringValue
        cell.cellStatus.text = cellArray["status_text"].stringValue
        cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
        
        if cell.cellStatus.text == "Pending" {
            cell.cellBtnDelete.isHidden = false
        }
        else{
            cell.cellBtnDelete.isHidden = true
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension OTHistory: UICollectionViewDelegateFlowLayout {

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

extension OTHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.otJSON![indexPath.item]
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
    }
    
    func pushToDetail(detailID:String) {
        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveDetail") as! LeaveDetail
        vc.mode = .ot
        vc.detailID = detailID
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
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
        
        let cellArray = self.otJSON![indexPath.item]
        
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
            
        }))
        //alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "Confirm_Delete".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Delete".localized(), style: .default, handler: { action in
            self.loadDelete(timeRequestID:cellArray["timerequest_id"].stringValue)
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadDelete(timeRequestID:String) {
        
        let parameters:Parameters = ["time_request_id":timeRequestID ,
                                     "status":"2" ,//2=cancel,reject
                                     "remark":"LEAVE_Cancel_Employee".localized()
        ]
        print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/settimeotstatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")

                self.submitSuccess()
                self.loadOT(monthYear: self.mySelectedDate)
            }
        }
    }
}

