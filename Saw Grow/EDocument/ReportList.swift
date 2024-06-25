//
//  ReportList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 11/4/2565 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD

class ReportList: UIViewController, UITextFieldDelegate {
    
    var reportJSON:JSON?
    var allJSON:JSON?
    
    var mode:reportType?
    
    var firstTime = true
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
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
        
        print("REPORT")
        
        // CollectionView
        directoryCollectionView.delegate = self
        directoryCollectionView.dataSource = self
        directoryCollectionView.backgroundColor = .clear
        directoryCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        //let layout = self.directoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        //layout?.sectionHeadersPinToVisibleBounds = true
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:.dateChanged, object: nil)
        
        monthYearField.delegate = self
        monthYearField.inputView = myDatePicker
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstTime {
            monthYearField.becomeFirstResponder()
            firstTime = false
        }
    }
    
    func loadReport(monthYear:Date) {
        let monthYearStr = monthAndYearToServerString(date: monthYear)
        let parameters:Parameters = ["group":"attendance",
                                     "ym":monthYearStr
        ]
        loadRequest(method:.get, apiName:"report/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS REPORT\(json)")
                
                self.allJSON = json["data"][0]["profile"]
                self.reportJSON = self.allJSON
                self.directoryCollectionView.reloadData()
            }
        }
    }
    
    @objc func myDateChanged(notification:Notification){
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromServerString(dateStr: (userInfo?["date"]) as! String)!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: DateFormatter.appMonthYearFormatStr)
        monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        loadReport(monthYear: mySelectedDate)
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        filterJSON(searchText: textField.text!)
    }
    
    func filterJSON(searchText:String) {
        if searchText == "" {
            self.reportJSON = self.allJSON
        }
        else{
            let filteredAllJSON = self.allJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText);
            })
            self.reportJSON = JSON(filteredAllJSON)
        }
        directoryCollectionView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension ReportList: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (reportJSON != nil) {
            return reportJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Directory_Cell", for: indexPath) as! Directory_Cell
        
        let cellArray = self.reportJSON![indexPath.item]
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        
        cell.cellTitlePosition.text = cellArray["designation_name"].stringValue
        
        //cell.cellBtnReport.sd_setImage(with: URL(string:cellArray["report_icon"].stringValue), for: .normal, placeholderImage: UIImage(named: "xxx"))
        cell.cellBtnReport.isHidden = false
        cell.cellBtnReport.addTarget(self, action: #selector(reportClick(_:)), for: .touchUpInside)
        
        if cellArray["myaccount"] == "1" {
            //cell.cellBtnReport.isHidden = true
        }
        
        cell.cellReportWorking.text = cellArray["workingday"].stringValue
        cell.cellReportWorking.textColor = colorFromRGB(rgbString: cellArray["workingday_color"].stringValue)
        
        cell.cellReportLate.text = cellArray["late"].stringValue
        cell.cellReportLate.textColor = colorFromRGB(rgbString: cellArray["late_color"].stringValue)
        
        cell.cellReportAbsent.text = cellArray["absent"].stringValue
        cell.cellReportAbsent.textColor = colorFromRGB(rgbString: cellArray["absent_color"].stringValue)
        
        cell.cellReportLeave.text = cellArray["leave"].stringValue
        cell.cellReportLeave.textColor = colorFromRGB(rgbString: cellArray["leave_color"].stringValue)
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ReportList: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        }
        else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width
        //let viewHeight = collectionView.frame.height
        
        return CGSize(width: viewWidth , height:140)
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

extension ReportList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = self.reportJSON![indexPath.item]
        pushToReportCalendar(selectedArray: cellArray)
    }
    
    @IBAction func reportClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = directoryCollectionView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        print("Report \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = self.reportJSON![indexPath.item]
        pushToReportCalendar(selectedArray: cellArray)
    }
    
    func pushToReportCalendar(selectedArray:JSON) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportCalendar") as! ReportCalendar
        vc.userID = selectedArray["user_id"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

