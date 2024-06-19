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
    
    var calendarJSON:JSON?
    var setColor: Bool = true
    
    var firstTime = true
    
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
    
    func loadCalendar(monthYear:Date) {
        let monthYearStr = monthAndYearToServerString(date: monthYear)
        let parameters:Parameters = ["ym":monthYearStr]
        
        loadRequest(method:.get, apiName:"attendance/gettimesheets", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS CALENDAR\(json)")
                
                self.calendarJSON = json["data"]["timesheet"]
                if self.calendarJSON?.count == 0
                {
                    self.showErrorNoData()
                }
                else{
                    ProgressHUD.dismiss()
                }
                
                //self.myCarlendar.reloadData()
                self.mytableView.isHidden = false
                self.mytableView.reloadData()
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
        
        let dateArray = self.calendarJSON![indexPath.section]
        let cellArray = dateArray["event"][indexPath.row]
        
        let dateSection = appDateFromServerString(dateStr: dateArray["date"].stringValue)!
        
        let dateStr = appStringFromDate(date: dateSection, format: "dd")
        let weekDayStr = appStringFromDate(date: dateSection, format: "EE")
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Report", for: indexPath) as! CalendarCell_Report
        
        cell.cellDate.text = dateStr
        cell.cellWeekDay.text = weekDayStr

//        cell.cellHourTitle.text = cellArray["xxx"].stringValue
//        
//        cell.cellStatusTitle.text = cellArray["xxx"].stringValue
//        cell.cellStatusTitle.textColor = colorFromRGB(rgbString: cellArray["color"].stringValue)
//        
//        cell.cellCheckInTime.text = cellArray["xxx"].stringValue
//        cell.cellCheckInTime.textColor = colorFromRGB(rgbString: cellArray["color"].stringValue)
//        
//        cell.cellUpdateTime.text = cellArray["xxx"].stringValue
//        cell.cellUpdateTime.textColor = colorFromRGB(rgbString: cellArray["color"].stringValue)
//        
//        cell.cellCheckOutTime.text = cellArray["xxx"].stringValue
//        cell.cellCheckOutTime.textColor = colorFromRGB(rgbString: cellArray["color"].stringValue)
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ReportCalendar: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.section)")
    }
}


