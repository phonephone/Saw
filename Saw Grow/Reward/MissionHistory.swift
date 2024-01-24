//
//  MissionHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class MissionHistory: UIViewController, UITextFieldDelegate {
    
    var historyJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    @IBOutlet weak var thisMonthLabel: UILabel!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    var firstTime = true
    
    @IBOutlet var popupView: UIView!
    @IBOutlet weak var popupTitle: UILabel!
    @IBOutlet weak var popupPic: UIImageView!
    @IBOutlet weak var popupPoint: UILabel!
    @IBOutlet weak var popupName: UILabel!
    @IBOutlet weak var popupDescription: UILabel!
    @IBOutlet weak var popupXBtn: UIButton!
    
    var blurView : UIVisualEffectView!
    
//    var monthYearPicker: UIDatePicker! = UIDatePicker()
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    
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
        
        print("MISSION HISTORY")
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:.dateChanged, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
//        datePickerSetup(picker: monthYearPicker)
//        monthYearPicker.maximumDate = Date()
//        monthYearField.inputView = monthYearPicker
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        
        self.hideKeyboardWhenTappedAround()
        
        thisMonthLabel.text = ""
        
        blurView = blurViewSetup()
        
        let popupWidth = self.view.bounds.width*0.9
        let popupHeight = popupWidth*1.2
        popupView.frame = CGRect(x: (self.view.bounds.width-popupWidth)/2, y: (self.view.bounds.height-popupHeight)/2, width: popupWidth, height: popupHeight)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if firstTime {
            monthYearField.becomeFirstResponder()
            firstTime = false
        }
    }
    
    func loadHistory(monthYear:Date) {
        //let monthYearStr = appStringFromDate(date: monthYearPicker.date, format: "yyyy-MM")
        let monthYearStr = appStringFromDate(date: monthYear, format: "yyyy-MM")
        let parameters:Parameters = ["ym":monthYearStr]
        //print(parameters)
        
        loadRequest(method:.get, apiName:"reward/getrewardlog", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HISTORY\(json)")

                self.historyJSON = json["data"][0]["rewardlog"]

                self.myCollectionView.reloadData()

                if self.historyJSON!.count > 0
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
        thisMonthLabel.text = appStringFromDate(date: mySelectedDate, format: "MMMM")
        loadHistory(monthYear: mySelectedDate)
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == monthYearField && monthYearField.text == "" {
            //datePickerChanged(picker: monthYearPicker)
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
    }
    
//    func datePickerSetup(picker:UIDatePicker) {
//        if #available(iOS 13.4, *) {
//            picker.preferredDatePickerStyle = .wheels
//        } else {
//            // Fallback on earlier versions
//        }
//
//        picker.datePickerMode = .date
//
//        // For 24 Hrs
//        picker.locale = Locale(identifier: "en_GB")
//
//        //For 12 Hrs
//        //picker.locale = Locale(identifier: "en_US")
//
//        //picker.minimumDate = Date()
//        picker.date = Date()
//        picker.addTarget(self, action: #selector(datePickerChanged(picker:)), for: .valueChanged)
//
//        picker.setValue(false, forKey: "highlightsToday")
//        picker.setValue(UIColor.white, forKeyPath: "backgroundColor")
//        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
//    }
//
//    @objc func datePickerChanged(picker: UIDatePicker) {
//        if picker == monthYearPicker {
//            clearForm()
//            let selectDate = appStringFromDate(date: picker.date, format: "MMMM yyyy")
//            monthYearField.text = selectDate
//            monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
//            loadHistory()
//        }
//    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://month & year
            monthYearField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    func clearForm() {
        historyJSON = nil
        
        monthYearField.text = ""
        //monthYearPicker.date = Date()
        monthYearIcon.setImage(UIImage(named: "form_date_off"), for: .normal)
        
        myCollectionView.reloadData()
    }
    
    @IBAction func popupClose(_ sender: UIButton) {
        popOut(popupView: popupView)
        popOut(popupView: blurView)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension MissionHistory: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (historyJSON != nil) {
            return historyJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.historyJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MissionHistory_Cell", for: indexPath) as! MissionHistory_Cell
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage1.sd_setImage(with: URL(string:cellArray["icon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitle.text = cellArray["name"].stringValue
        cell.cellDescription.text = cellArray["desc"].stringValue
        cell.cellTime.text = cellArray["date"].stringValue
        cell.cellPoint.text = cellArray["point"].stringValue
        cell.cellPoint.textColor = self.colorFromRGB(rgbString: cellArray["color"].stringValue)
        
        if cellArray["icon"].stringValue == cellArray["icon2"].stringValue {
            cell.cellImage2.image = nil
        }
        else {
            cell.cellImage2.sd_setImage(with: URL(string:cellArray["icon2"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension MissionHistory: UICollectionViewDelegateFlowLayout {

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

extension MissionHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.historyJSON![indexPath.item]
        
        popupPic.sd_setImage(with: URL(string:cellArray["sticker_url"].stringValue), placeholderImage: UIImage(named: ""))
        popupTitle.text = cellArray["send_header"].stringValue
        popupPoint.text = cellArray["send_point"].stringValue
        popupName.text = cellArray["send_text"].stringValue
        popupDescription.text = cellArray["remark"].stringValue
        popIn(popupView: self.blurView)
        popIn(popupView: self.popupView)
    }
}
