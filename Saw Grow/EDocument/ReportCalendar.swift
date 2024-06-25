//
//  ReportCalendar.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 13/6/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ReportCalendar: UIViewController, UITextFieldDelegate {
    
    var userID:String?
    var calendarJSON:JSON?
    var detailJSON : JSON?
    
    var setColor: Bool = true
    
    var firstTime = true
    var scrollToday = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var monthYearIcon: UIButton!
    @IBOutlet weak var monthYearField: UITextField!
    @IBOutlet weak var monthYearBtn: UIButton!
    
    let myDatePicker = MyDatePicker()
    var mySelectedDate = Date()
    
    @IBOutlet weak var mytableView: UITableView!
    
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
        
        print("REPORT CALENDAR")
        
        mytableView.delegate = self
        mytableView.dataSource = self
        
        myDatePicker.dataSource = myDatePicker
        myDatePicker.delegate = myDatePicker
        myDatePicker.backgroundColor = .white
        myDatePicker.buildMonthCollection(previous: 12, next: 0)
        myDatePicker.notificationName = .reportCalendar
        NotificationCenter.default.addObserver(self, selector: #selector(myDateChanged(notification:)), name:myDatePicker.notificationName, object: nil)
        
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
    
    func loadCalendar(monthYear:Date) {
        self.calendarJSON = nil
        let monthYearStr = monthAndYearToServerString(date: monthYear)
        let parameters:Parameters = ["ym":monthYearStr,
                                     "q":userID!
        ]
        print(parameters)
        loadRequest(method:.get, apiName:"report/getprofile", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS REPORT CALENDAR\(json)")
                
                self.calendarJSON = json["data"][0]["profile"]
                self.mytableView.reloadData()
                
                if self.calendarJSON?.count == 0
                {
                    self.showErrorNoData()
                    self.mytableView.isHidden = true
                }
                else{
                    ProgressHUD.dismiss()
                    self.mytableView.isHidden = false
                    
                    if self.scrollToday && self.calendarJSON?.count != 0 {//Scroll to Bottom
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: 0, section: self.calendarJSON!.count-1)
                            self.mytableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                        self.scrollToday = false
                    }
                    else {//Scroll to Top
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: 0, section: 0)
                            self.mytableView.scrollToRow(at: indexPath, at: .top, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == monthYearField && monthYearField.text == "" {
            myDatePicker.selectRow(myDatePicker.selectedMonth(), inComponent: 0, animated: true)
            myDatePicker.pickerView(myDatePicker, didSelectRow: myDatePicker.selectedRow(inComponent: 0), inComponent: 0)
        }
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://month & year
            monthYearField.becomeFirstResponder()
            
        default:
            break
        }
    }
    
    @objc func myDateChanged(notification:Notification){
        let userInfo = notification.userInfo
        mySelectedDate = appDateFromServerString(dateStr: (userInfo?["date"]) as! String)!
        monthYearField.text = appStringFromDate(date: mySelectedDate, format: DateFormatter.appMonthYearFormatStr)
        monthYearIcon.setImage(UIImage(named: "form_date_on"), for: .normal)
        loadCalendar(monthYear: mySelectedDate)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ReportCalendar: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (calendarJSON != nil) {
            return calendarJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (calendarJSON != nil) {
            return 1
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 20//.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Header") as! CalendarCell_Header
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 10
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Header") as! CalendarCell_Header
        return headerCell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (calendarJSON != nil) {
            return 88
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = self.calendarJSON![indexPath.section]
        
        let dateSection = appDateFromServerString(dateStr: cellArray["date"].stringValue)!
        
        let dateStr = appStringFromDate(date: dateSection, format: "dd")
        let weekDayStr = appStringFromDate(date: dateSection, format: "EE")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Report", for: indexPath) as! CalendarCell_Report
        
        cell.cellDate.text = dateStr
        cell.cellWeekDay.text = weekDayStr

        cell.cellHourTitle.text = cellArray["shiftname"].stringValue
        
        cell.cellStatusTitle.text = cellArray["empstatusdetail"].stringValue
        cell.cellStatusTitle.textColor = colorFromRGB(rgbString: cellArray["empstatuscolor"].stringValue)
        
        cell.cellCheckInTime.text = cellArray["checkindetail"].stringValue
        cell.cellCheckInTime.textColor = colorFromRGB(rgbString: cellArray["checkincolor"].stringValue)
        
        cell.cellUpdateTime.text = cellArray["checkupdatedetail"].stringValue
        cell.cellUpdateTime.textColor = colorFromRGB(rgbString: cellArray["checkupdatecolor"].stringValue)
        
        cell.cellCheckOutTime.text = cellArray["checkoutdetail"].stringValue
        cell.cellCheckOutTime.textColor = colorFromRGB(rgbString: cellArray["checkoutcolor"].stringValue)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ReportCalendar: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.section)")
        
        let cellArray = calendarJSON![indexPath.section]
        loadCalendarDetail(monthYearDate: cellArray["date"].stringValue)
    }
    
    func loadCalendarDetail(monthYearDate:String) {
        let parameters:Parameters = ["ymd":monthYearDate,
                                     "q":userID!
        ]
        
        loadRequest(method:.get, apiName:"report/getprofilecheckin", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CALENDAR Detail\(json)")
                
                self.pushToCalendarDetail(selectedArray: json["data"][0]["profile"][0])
                ProgressHUD.dismiss()
            }
        }
    }
    
    func pushToCalendarDetail(selectedArray:JSON) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "Report") as! Report
        vc.detailJSON = selectedArray
        self.navigationController!.pushViewController(vc, animated: true)
    }
}


