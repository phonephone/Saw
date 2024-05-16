//
//  MoodReport.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 1/4/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import FSCalendar
import Localize_Swift

class MoodReport: UIViewController {
    
    var calendarJSON:JSON?
    var goToDate:Date?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var calendarMainView: UIView!
    @IBOutlet weak var myCarlendar: FSCalendar!
    @IBOutlet weak var monthLabel: UILabel!
    
    private var currentPage: Date?
    private lazy var today: Date = {
        return Date()
    }()
    
    @IBOutlet weak var mytableView: UITableView!
    var isScrolling = false
    var firstTime = true
    
    let datesWithEvent = ["2024-03-30", "2024-03-31", "2024-04-01", "2024-04-02", "2024-04-04", "2024-04-05", "2024-04-08", "2024-04-09", "2024-04-12", "2024-04-13", "2024-04-14", "2024-04-15"]
    let datesWithMultipleEvents = ["2024-04-01", "2024-04-30"]
    
    let shortMonthYearFormat = "MMM yyyy"
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myCarlendar.today = Date()
        loadCalendar(monthYear: myCarlendar.currentPage,scrollToDate: firstTime)
        //myCarlendar.select(today, scrollToDate: true)
    }
    
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
        
        print("MOOD REPORT")
        calendarMainView.layer.cornerRadius = 15.0
        calendarMainView.layer.masksToBounds = true
        
        myCarlendar.customizeMoodCalenderAppearance()
        myCarlendar.delegate = self
        myCarlendar.dataSource = self
        myCarlendar.locale = Locale(identifier: "CALENDAR_Language".localized())
        myCarlendar.placeholderType = .none //Hide date not in current month
        
        mytableView.delegate = self
        mytableView.dataSource = self
        
        monthLabel.text = appStringFromDate(date: Date(), format: shortMonthYearFormat)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //scrollToDate(date: Date())
        if goToDate != nil
        {
            currentPage = goToDate
            myCarlendar.setCurrentPage(goToDate!, animated: true)
            myCarlendar.select(goToDate, scrollToDate: false)
            loadCalendar(monthYear: myCarlendar.currentPage,scrollToDate: true)
            
            goToDate = nil
        }
    }
    
    func loadCalendar(monthYear:Date, scrollToDate:Bool) {
        
        firstTime = false
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
                
                if self.myCarlendar.selectedDate != nil && scrollToDate == true
                {
                    self.scrollToDate(date: self.myCarlendar.selectedDate!)
                }
                else if scrollToDate == true
                {
                    self.scrollToDate(date: Date())
                }
            }
        }
    }
    
    @IBAction func prevMonth(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: false)
    }
    
    @IBAction func nextMonth(_ sender: UIButton) {
        self.moveCurrentPage(moveUp: true)
    }
    
    private func moveCurrentPage(moveUp: Bool) {
        mytableView.isHidden = true
        
        let calendar = Calendar.current
        var dateComponents = DateComponents()
        dateComponents.month = moveUp ? 1 : -1
        
        self.currentPage = calendar.date(byAdding: dateComponents, to: self.currentPage ?? self.today)
        self.myCarlendar.setCurrentPage(self.currentPage!, animated: true)
        
        loadCalendar(monthYear: currentPage!, scrollToDate: false)
        let indexPath:IndexPath = IndexPath(row: 0, section: 0)
        if mytableView.numberOfSections > 0
        {
            mytableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
    }
    
    func scrollToDate(date: Date)
    {
        let day = Calendar.current.component(.day, from: date)
        
        if day <= mytableView.numberOfSections
        {
            let indexPath:IndexPath = IndexPath(row: 0, section: day-1)
            mytableView.scrollToRow(at: indexPath, at: .top, animated: true)
        }
        else{
            showErrorNoData()
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


// MARK: - FSCalendar

extension FSCalendar {
    func customizeMoodCalenderAppearance() {
        //        self.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        
        self.appearance.headerDateFormat = "MMM yyyy"
        
        self.appearance.headerTitleFont      = UIFont.Kanit_Medium(ofSize: 18)
        self.appearance.weekdayFont          = UIFont.Kanit_Regular(ofSize: 15)
        self.appearance.titleFont            = UIFont.Kanit_Regular(ofSize: 17)
        self.appearance.eventOffset = CGPoint(x: 0, y: 3)
        
        //        self.appearance.headerTitleColor     = Colors.NavTitleColor
        //        self.appearance.weekdayTextColor     = Colors.topTabBarSelectedColor
        //        self.appearance.eventDefaultColor    = Colors.NavTitleColor
        //self.appearance.selectionColor       = UIColor.customThemeColor()
        //        self.appearance.titleSelectionColor  = Colors.NavTitleColor
        //self.appearance.todayColor           = UIColor.lightGray
        //        self.appearance.todaySelectionColor  = Colors.purpleColor
        //
        //        self.appearance.headerMinimumDissolvedAlpha = 0.0 // Hide Left Right Month Name
    }
}

// MARK: - FSCalendarDelegateAppearance
extension MoodReport: FSCalendarDelegateAppearance {
    // MARK: - Default
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.orange
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
//        let dateString = DateFormatter.serverFormatter.string(from: date)
//        if self.datesWithMultipleEvents.contains(dateString) {
//            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
//        }
        return [.clear]//[.blue, .green]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.white
        }
        return nil
    }
    
    // MARK: - Selected
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.orange
        }
        return .themeColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventSelectionColorsFor date: Date) -> [UIColor]? {
        return [.clear]//[.blue, .green]
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleSelectionColorFor date: Date) -> UIColor? {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        if self.datesWithEvent.contains(dateString) {
            return UIColor.white
        }
        return .white
    }
}

// MARK: - FSCalendarDataSource
extension MoodReport: FSCalendarDataSource {
    
//    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
//        let cell = calendar.dequeueReusableCell(withIdentifier: "cell", for: date, at: position)
//        return cell
//    }
    
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at position: FSCalendarMonthPosition) {
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        //print(dateString)
        if self.datesWithEvent.contains(dateString) {
            return 1
        }
        
        if self.datesWithMultipleEvents.contains(dateString) {
            return 2
        }
        return 0
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
        let dateString = DateFormatter.serverFormatter.string(from: date)
        print(dateString)
        if self.datesWithEvent.contains(dateString) {
            print("XXX")
            return UIColor.green
        }
        
        return nil
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
//        let dateString = DateFormatter.serverFormatter.string(from: date)
//        if self.datesWithMultipleEvents.contains(dateString) {
//            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
//        }
//        return nil
//    }
    
//    func maximumDate(for calendar: FSCalendar) -> Date {
//        return Date()
//    }
}

// MARK: - FSCalendarDelegate

extension MoodReport: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        //        let month = Calendar.current.component(.month, from: calendar.currentPage)
        //        let year = Calendar.current.component(.year, from: calendar.currentPage)
        
        monthLabel.text = appStringFromDate(date: calendar.currentPage, format: shortMonthYearFormat)
        myCarlendar.select(calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.setCurrentPage(date, animated: true)
        calendar.select(date)
        //print(appStringFromDate(date: date, format: DateFormatter.appDateFormatStr))
        scrollToDate(date: date)
        
        //        let currentPageDate = calendar.currentPage
        //        let month = Calendar.current.component(.month, from: currentPageDate)
        //        print("Did Select \(month)")
        
        //        let values = Calendar.current.dateComponents([Calendar.Component.month, Calendar.Component.year], from: myCarlendar.currentPage)
        //        let currentYear = values.year
        //        let currentMonth = values.month
        //
        //        let range = Calendar.current.range(of: Calendar.Component.day, in: Calendar.Component.month, for: myCarlendar.currentPage)
        //        let totalDays = range!.count
    }
}


// MARK: - UITableViewDataSource

extension MoodReport: UITableViewDataSource {
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
        return .leastNormalMagnitude
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
            return 60
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //print("Table Show \(indexPath.section)")
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateArray = self.calendarJSON![indexPath.section]
        let cellArray = dateArray["event"][indexPath.row]
        
        let dateSection = appDateFromServerString(dateStr: dateArray["date"].stringValue)!
        
        //let dateSection = appDateFromServerString(dateStr: dateArray["date"].stringValue)!
        let dateStr = appStringFromDate(date: dateSection, format: "dd")
        let weekDayStr = appStringFromDate(date: dateSection, format: "EE")
        
        if cellArray.isEmpty {//Nothing
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Mood", for: indexPath) as! CalendarCell_Normal
            
            cell.cellDate.text = dateStr
            cell.cellWeekDay.text = weekDayStr
            cell.cellDate.isHidden = false
            cell.cellWeekDay.isHidden = false
            
            cell.cellDot.backgroundColor = .lightGray
            cell.cellTitle.text = "-"
            cell.cellTitle.textColor = .lightGray
            cell.cellTime.text = ""
            cell.cellTime.textColor = .lightGray
            
            cell.cellRemark.isHidden = true
            cell.isUserInteractionEnabled = false
            
            return cell
        }
        else {//NORMAL
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Mood", for: indexPath) as! CalendarCell_Mood
            
            cell.cellDate.text = dateStr
            cell.cellWeekDay.text = weekDayStr
            //cell.cellDate.text = self.menuJSON![indexPath.row][menuNameKey()].stringValue
            
            if indexPath.row == 0 {//FIRST ROW
                cell.cellDate.isHidden = false
                cell.cellWeekDay.isHidden = false
            }
            else {//OTHER ROW
                cell.cellDate.isHidden = true
                cell.cellWeekDay.isHidden = true
            }
            
//            let cellColor = self.colorFromRGB(rgbString: cellArray["color"].stringValue)
            cell.cellDot.backgroundColor = .orange
            //cell.cellMoodIcon.sd_setImage(with: URL(string:cellArray["xxx"].stringValue), placeholderImage: nil)
            cell.cellMoodTitle.text = cellArray["title"].stringValue
            
            cell.cellMoodAttach.addTarget(self, action: #selector(attachClick(_:)), for: .touchUpInside)
            
            let dateString = DateFormatter.serverFormatter.string(from: dateSection)
            print(dateString)
            if self.datesWithEvent.contains(dateString) {
                cell.cellDot.isHidden = false
                cell.cellMoodBgView.isHidden = false
            }
            else {
                cell.cellDot.isHidden = true
                cell.cellMoodBgView.isHidden = true
            }
            
            return cell
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isScrolling = true
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isScrolling = false
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var firstVisibleIndexPath = IndexPath(row:0, section: 0)
        
        for i in 0..<mytableView.indexPathsForVisibleRows!.count {
            if mytableView.indexPathsForVisibleRows?[i].row == 0 {
                firstVisibleIndexPath = (mytableView.indexPathsForVisibleRows![i])
                break
            }
        }
        
        var components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: myCarlendar.currentPage)
        components.day = firstVisibleIndexPath.section+1
        
        //let date = Calendar.current.date(from: components)
        if isScrolling == true
        {
            //myCarlendar.select(date)
        }
    }
}

// MARK: - UITableViewDelegate

extension MoodReport: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        showRemark(indexPath: indexPath)
    }
    
    @IBAction func attachClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = mytableView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        
        showRemark(indexPath: indexPath)
    }
    
    func showRemark(indexPath: IndexPath) {
        let alertService = AlertService()
        let alertSlide = alertService.alertMoodReport(moodJSON: calendarJSON!) {
            
        }
        present(alertSlide, animated: true)
    }
}

