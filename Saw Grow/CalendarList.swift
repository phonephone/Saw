//
//  CalendarList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 15/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import FSCalendar
import Localize_Swift

class CalendarList: UIViewController {
    
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
    
    let datesWithEvent = ["2022-03-03", "2022-03-05", "2022-03-07", "2022-03-09"]
    let datesWithMultipleEvents = ["2022-03-11", "2022-03-13", "2022-03-15", "2022-03-17"]
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        myCarlendar.today = Date()
        loadCalendar(monthYear: myCarlendar.currentPage,scrollToDate: firstTime)
        //myCarlendar.select(today, scrollToDate: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.tabBarController?.setStatusBarColor()
            self.tabBarController?.tabBar.tintColor = UIColor.customThemeColor()
            headerView.setGradientBackground(mainPage:true)
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("CALENDAR")
        calendarMainView.layer.cornerRadius = 15.0
        calendarMainView.layer.masksToBounds = true
        
        myCarlendar.customizeCalenderAppearance()
        myCarlendar.delegate = self
        myCarlendar.dataSource = self
        myCarlendar.locale = Locale(identifier: "CALENDAR_Language".localized())
        myCarlendar.placeholderType = .none //Hide date not in current month
        
        mytableView.delegate = self
        mytableView.dataSource = self
        
        monthLabel.text = appStringFromDate(date: Date(), format: "MMM yyyy")
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
        let monthYearStr = appStringFromDate(date: monthYear, format: "yyyy-MM")
        let parameters:Parameters = ["ym":monthYearStr]
        
        loadRequest(method:.get, apiName:"attendance/gettimesheets", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
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
    
    @IBAction func addClick(_ sender: UIButton) {
        let alert = UIAlertController(title: "CALENDAR_Sheet_Request".localized(), message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "CALENDAR_Sheet_Leave".localized(), style: .default, handler: { _ in
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Leave") as! Leave
            if self.myCarlendar.selectedDate != nil
            {
                vc.dateFromCalendar = self.myCarlendar.selectedDate
            }
            else{
                vc.dateFromCalendar = Date()
            }
            self.navigationController!.pushViewController(vc, animated: true)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction.init(title: "Cancel".localized(), style: .cancel, handler: nil))
        alert.actions.last?.titleTextColor = .buttonRed
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
}


// MARK: - FSCalendar

extension FSCalendar {
    func customizeCalenderAppearance() {
        //        self.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        
        self.appearance.headerDateFormat = "MMM yyyy"
        
        self.appearance.headerTitleFont      = UIFont.Roboto_Medium(ofSize: 18)
        self.appearance.weekdayFont          = UIFont.Roboto_Regular(ofSize: 15)
        self.appearance.titleFont            = UIFont.Roboto_Regular(ofSize: 17)
        self.appearance.eventOffset = CGPoint(x: 0, y: 3)
        
        //        self.appearance.headerTitleColor     = Colors.NavTitleColor
        //        self.appearance.weekdayTextColor     = Colors.topTabBarSelectedColor
        //        self.appearance.eventDefaultColor    = Colors.NavTitleColor
        self.appearance.selectionColor       = UIColor.customThemeColor()
        //        self.appearance.titleSelectionColor  = Colors.NavTitleColor
        self.appearance.todayColor           = UIColor.lightGray
        //        self.appearance.todaySelectionColor  = Colors.purpleColor
        //
        //        self.appearance.headerMinimumDissolvedAlpha = 0.0 // Hide Left Right Month Name
    }
}

// MARK: - FSCalendarDataSource

extension CalendarList: FSCalendarDataSource {
    func calendar(_ calendar: FSCalendar, willDisplay cell: FSCalendarCell, for date: Date, at monthPosition: FSCalendarMonthPosition) {
        
//        let day = Calendar.current.component(.day, from: date)
//        print("Calendar Show \(day)")
    }
    
    
    //    func calendar(_ calendar: FSCalendar, cellFor date: Date, at position: FSCalendarMonthPosition) -> FSCalendarCell {
    //
    //        print("Show2")
    //        return FSCalendarCell()
    //    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        let dateString = self.dateFormatter2.string(from: date)
        //print(dateString)
//        if self.datesWithEvent.contains(dateString) {
//                return 1
//        }
//        if self.datesWithMultipleEvents.contains(dateString) {
//                return 3
//        }
        return 0
    }
    
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
         //Do some checks and return whatever color you want to.
         return UIColor.purple
    }

    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> [UIColor]? {
        let dateString = self.dateFormatter2.string(from: date)
        if self.datesWithMultipleEvents.contains(dateString) {
            return [UIColor.magenta, appearance.eventDefaultColor, UIColor.black]
        }
            return nil
     }
}

// MARK: - FSCalendarDelegate

extension CalendarList: FSCalendarDelegate {
    func calendarCurrentPageDidChange(_ calendar: FSCalendar) {
        
        //        let month = Calendar.current.component(.month, from: calendar.currentPage)
        //        let year = Calendar.current.component(.year, from: calendar.currentPage)
        
        monthLabel.text = appStringFromDate(date: calendar.currentPage, format: "MMM yyyy")
        myCarlendar.select(calendar.currentPage)
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        
        calendar.setCurrentPage(date, animated: true)
        calendar.select(date)
        //print(appStringFromDate(date: date, format: "dd MMM yyyy"))
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

extension CalendarList: UITableViewDataSource {
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
            if calendarJSON![section]["event"].count != 0{
                return calendarJSON![section]["event"].count
            }
            else{
                return 1
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Header") as! CalendarCell_Header
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 15
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let headerCell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Header") as! CalendarCell_Header
        return headerCell
    }

    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (calendarJSON != nil) {
            let cellArray = self.calendarJSON![indexPath.section]["event"][indexPath.row]
            if cellArray["isbackground"] == "0" {
                return 40
            }
            else{
                return 60
            }
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
        
        let dateSection = dateFromServerString(dateStr: dateArray["date"].stringValue)!
        //let dateSection = dateFromServerString(dateStr: dateArray["date"].stringValue)!
        let dateStr = appStringFromDate(date: dateSection, format: "dd")
        let weekDayStr = appStringFromDate(date: dateSection, format: "EE")
        
        if cellArray.isEmpty {//Nothing
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Normal", for: indexPath) as! CalendarCell_Normal
            
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
        else if cellArray["isbackground"] == "0" {//NORMAL
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Normal", for: indexPath) as! CalendarCell_Normal
            
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
            let cellColor = self.colorFromRGB(rgbString: cellArray["color"].stringValue)
            cell.cellDot.backgroundColor = cellColor
            cell.cellTitle.text = cellArray["title"].stringValue
            cell.cellTitle.textColor = cellColor
            cell.cellTime.text = cellArray["description"].stringValue
            cell.cellTime.textColor = cellColor
            
            cell.cellRemark.backgroundColor = cellColor
            cell.cellRemark.addTarget(self, action: #selector(remarkClick(_:)), for: .touchUpInside)
            if cellArray["remark"] == "" {
                cell.cellRemark.isHidden = true
                cell.isUserInteractionEnabled = false
            }
            else{
                cell.cellRemark.isHidden = false
                cell.isUserInteractionEnabled = true
            }
            
            return cell
        }
        else{//EVENT
            let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarCell_Event", for: indexPath) as! CalendarCell_Event
            
            cell.cellDate.text = dateStr
            cell.cellWeekDay.text = weekDayStr
            
            if indexPath.row == 0 {//FIRST ROW
                cell.cellDate.isHidden = false
                cell.cellWeekDay.isHidden = false
            }
            else {//OTHER ROW
                cell.cellDate.isHidden = true
                cell.cellWeekDay.isHidden = true
            }
            
            let cellColor = self.colorFromRGB(rgbString: cellArray["color"].stringValue)
            cell.cellTab.backgroundColor = cellColor
            cell.cellBg.layer.masksToBounds = true
            cell.cellTitle.text = cellArray["title"].stringValue
            cell.cellTitle.textColor = cellColor
            cell.cellDescription.text = cellArray["description"].stringValue
            cell.cellDescription.textColor = cellColor
            cell.cellDescription.isHidden = true
            
            let cellBgColor = self.colorFromRGB(rgbString: cellArray["bgcolor"].stringValue)
            cell.cellBg.backgroundColor = cellBgColor//cellColor.withAlphaComponent(0.3)
            
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

extension CalendarList: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        showRemark(indexPath: indexPath)
    }
    
    @IBAction func remarkClick(_ sender: UIButton) {
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
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        
        let dateArray = self.calendarJSON![indexPath.section]
        let cellArray = dateArray["event"][indexPath.row]
        alert.title = cellArray["title"].stringValue//"Remark"
        alert.message = "\n\(cellArray["remark"].stringValue)"
        alert.setColorAndFont()
        
        let urlStr = cellArray["image_path"].stringValue
        if urlStr != "" {
            let url = URL(string: cellArray["image_path"].stringValue)
            DispatchQueue.main.async { [weak self] in
                if let imageData = try? Data(contentsOf: url!) {
                    if let image = UIImage(data: imageData) {
                        
                        let uiImageAlertAction = UIAlertAction(title: "", style: .default, handler: nil)
                        let scaleSize = CGSize(width: 245, height: 245/image.size.width*image.size.height)
                        let reSizedImage = image.imageResized(to: scaleSize)
                        
                        uiImageAlertAction.setValue(reSizedImage.withRenderingMode(.alwaysOriginal), forKey: "image")
                        alert.addAction(uiImageAlertAction)
                        
                        alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { action in
                            
                        }))
                        alert.actions.last?.titleTextColor = .themeColor
                        self!.present(alert, animated: true)
                        
                    }
                }
            }
        }
        else {
            alert.addAction(UIAlertAction(title: "OK".localized(), style: .default, handler: { action in
                
            }))
            alert.actions.last?.titleTextColor = .themeColor
            self.present(alert, animated: true)
        }
        
//        let imgView = UIImageView(frame: CGRect(x: 0, y: 0, width: 100, height: 100))
//        imgView.sd_setImage(with: URL.init(string: cellArray["image_path"].stringValue)) { (image, err, type, url) in
//            print((image?.size.height)! + (image?.size.width)!)
//            
//            let uiImageAlertAction = UIAlertAction(title: "", style: .default, handler: nil)
//            let scaleSize = CGSize(width: 245, height: 245/image!.size.width*image!.size.height)
//            let reSizedImage = image?.imageResized(to: scaleSize)
//            
//            uiImageAlertAction.setValue(reSizedImage!.withRenderingMode(.alwaysOriginal), forKey: "image")
//            alert.addAction(uiImageAlertAction)
//            
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
//                
//            }))
//            alert.actions.last?.titleTextColor = .themeColor
//            
//            self.present(alert, animated: true)
//        }
    }
}
