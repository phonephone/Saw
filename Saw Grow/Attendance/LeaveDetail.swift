//
//  LeaveDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

enum detailType {
    case leave
    case attendance
    case ot
    case shift
}

class LeaveDetail: UIViewController {
    
    var mode:detailType?
    var detailID:String?
    var detailJSON : JSON?
    
    var emptyReason:String = "-"
    
    var setColor: Bool = true
    
    let alertService = AlertService()
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var myTableView: UITableView!

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

        print("LEAVE DETAIL")
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        myTableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        
        //self.hideKeyboardWhenTappedAround()
        
        switch mode {
        case .leave:
            headerTitle.text = "LEAVE_DETAIL_Header".localized()
        case .attendance:
            headerTitle.text = "ATTENDANCE_DETAIL_Header".localized()
        case .ot:
            headerTitle.text = "OT_DETAIL_Header".localized()
        case .shift:
            headerTitle.text = "SWAP_DETAIL_Header".localized()
        
        default:
            break
        }
        
        loadDetail(withLoadingHUD: true)
    }
    
    func loadDetail(withLoadingHUD:Bool) {
        let parameters:Parameters = ["noti_id":detailID!]
        var url:String = ""
        var arrayName:String = ""
        
        if mode == .shift {
            url = "attendance/gettimeswapdetail"
            arrayName = "timeswap"
        }
        else {
            url = "workflow/getapprovaldetail"
            arrayName = "approvaldetail"
        }
        
        loadRequest(method:.get, apiName:url, authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS LEAVE DETAIL\(json)")
                
                self.detailJSON = json["data"][0][arrayName][0]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension LeaveDetail: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailJSON != nil) {
            switch mode {
            case .leave:
                if detailJSON!["status_id"].stringValue == "3" || detailJSON!["status_id"].stringValue == "4" {//Pending , Cancel
                    return 8
                }
                else {
                    return 7
                }
            case .attendance:
                if detailJSON!["status_id"].stringValue == "3" || detailJSON!["status_id"].stringValue == "4" {//Pending , Cancel
                    return 7
                }
                else {
                    return 6
                }
            case .ot:
                if detailJSON!["status_id"].stringValue == "3" || detailJSON!["status_id"].stringValue == "4" {//Pending , Cancel
                    return 7
                }
                else {
                    return 6
                }
            case .shift:
                if detailJSON!["status_id"].stringValue == "3" || detailJSON!["status_id"].stringValue == "4" {//Pending , Cancel
                    return 5
                }
                else {
                    return 4
                }
            
            default:
                return 0
            }
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = self.detailJSON!
        var cell = LeaveDetail_Cell()
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_User", for: indexPath) as! LeaveDetail_Cell
        let standardCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Standard", for: indexPath) as! LeaveDetail_Cell
        let headCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Head", for: indexPath) as! LeaveDetail_Cell
        let doubleCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_DoubleColumn", for: indexPath) as! LeaveDetail_Cell
        let reasonCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Reason", for: indexPath) as! LeaveDetail_Cell
        let swapCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Shift", for: indexPath) as! LeaveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        switch mode {
        case .leave:
            
            switch indexPath.row {
            case 0://User Cell
                cell = userCell
                cell.cellTitle.text = "\("Sent_Date".localized()) \(cellArray["sentdate"].stringValue)"
                cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["empname"].stringValue
                cell.cellPosition.text = cellArray["empposition"].stringValue
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1://Leave Type
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Leave_Type".localized()
                cell.cellDescription.text = cellArray[requestNameKey()].stringValue
                
            case 2://Duration
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Duration".localized()
                cell.cellDescription.text = cellArray["date"].stringValue
                
            case 3://Total
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Total".localized()
                cell.cellDescription.text = cellArray["countday"].stringValue
                
            case 4://Reason
                cell = reasonCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reason".localized()
                if cellArray["reason"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["reason"].stringValue
                }
                
                let urlStr = cellArray["image_path"].stringValue
                if urlStr != "" {
                    cell.cellImage.sd_setImage(with: URL(string:urlStr), placeholderImage: nil)
                    cell.cellImage.isHidden = false
                    cell.cellImage.addTapGesture {
                        let alertImage = self.alertService.alertImageWithText(image: cell.cellImage.image)
                        {print("Done Clicked")}
                        self.present(alertImage, animated: true)
                    }
                }
                else{
                    cell.cellImage.image = nil
                    cell.cellImage.isHidden = true
                }
                
            case 5://Sent Date
                cell = standardCell
                cell.cellTitle.text = "Sent_Date".localized()
                cell.cellDescription.text = cellArray["sentdate"].stringValue
                
            case 6://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["headname"].stringValue
                cell.cellPosition.text = cellArray["headposition"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnWithdraw.addTarget(self, action: #selector(withdrawClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" {//Pending
                    cell.cellBtnStackView.isHidden = false
                    cell.cellBtnCancel.isHidden = false
                    cell.cellBtnWithdraw.isHidden = true
                    cell.cellBtnAccept.isHidden = true
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else if detailJSON!["status_id"].stringValue == "2" {//Approved
                    cell.cellBtnStackView.isHidden = false
                    cell.cellBtnCancel.isHidden = true
                    cell.cellBtnWithdraw.isHidden = false
                    cell.cellBtnAccept.isHidden = true
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{//3,4 = Rejected,Cancel
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue != "3" {//Rejected
                        DispatchQueue.main.async {
                            cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                        }
                    }
                }
                
            case 7://Reject Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reject_Reason".localized()
                if cellArray["remark"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["remark"].stringValue
                }
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                }
                cell.separatorInset = hideSeperator
            default:
                break
            }
            //end .leave
            
        case .attendance:
            switch indexPath.row {
            case 0://User Cell
                cell = userCell
                cell.cellTitle.text = "\("Sent_Date".localized()) \(cellArray["sentdate"].stringValue)"
                cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["empname"].stringValue
                cell.cellPosition.text = cellArray["empposition"].stringValue
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1://Date
                cell = standardCell
                cell.cellTitle.text = "ATTENDANCE_DETAIL_Date".localized()
                cell.cellDescription.text = cellArray["date"].stringValue
                
            case 2://Type
                cell = standardCell
                cell.cellTitle.text = "ATTENDANCE_DETAIL_Attendance_Type".localized()
                cell.cellDescription.text = cellArray["desc"].stringValue
                
            case 3://Time
                cell = doubleCell
                cell.cellTitle.text = "ATTENDANCE_DETAIL_Attendance_Time".localized()
                if cellArray["clocktime"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["clocktime"].stringValue
                }
                
                cell.cellTitle2.text = "ATTENDANCE_DETAIL_Change_to".localized()
                cell.cellDescription2.text = cellArray["time"].stringValue
                
            case 4://Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reason".localized()
                if cellArray["reason"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["reason"].stringValue
                }
                
            case 5://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["headname"].stringValue
                cell.cellPosition.text = cellArray["headposition"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnWithdraw.addTarget(self, action: #selector(withdrawClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" {//Pending
                    cell.cellBtnStackView.isHidden = false
                    cell.cellBtnCancel.isHidden = false
                    cell.cellBtnWithdraw.isHidden = true
                    cell.cellBtnAccept.isHidden = true
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{//2,3,4 = Approved, Rejected, Cancel
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue == "2" {//Approved
                        DispatchQueue.main.async {
                            cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                        }
                        cell.separatorInset = hideSeperator
                    }
                }
                
            case 6://Reject Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reject_Reason".localized()
                if cellArray["remark"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["remark"].stringValue
                }
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                }
                cell.separatorInset = hideSeperator
            default:
                break
            }
            //end .attendance
            
        case .ot:
            switch indexPath.row {
            case 0://User Cell
                cell = userCell
                cell.cellTitle.text = "\("Sent_Date".localized()) \(cellArray["sentdate"].stringValue)"
                cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["empname"].stringValue
                cell.cellPosition.text = cellArray["empposition"].stringValue
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1://Date
                cell = standardCell
                cell.cellTitle.text = "OT_DETAIL_Date".localized()
                cell.cellDescription.text = cellArray["date"].stringValue
                
            case 2://Time
                cell = standardCell
                cell.cellTitle.text = "OT_DETAIL_Time".localized()
                cell.cellDescription.text = cellArray["desc"].stringValue
                
            case 3://Total Hour
                cell = standardCell
                cell.cellTitle.text = "OT_Total".localized()
                cell.cellDescription.text = cellArray["total_hours"].stringValue
                
            case 4://Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reason".localized()
                if cellArray["reason"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["reason"].stringValue
                }
                
            case 5://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["headname"].stringValue
                cell.cellPosition.text = cellArray["headposition"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnWithdraw.addTarget(self, action: #selector(withdrawClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" {//Pending
                    cell.cellBtnStackView.isHidden = false
                    cell.cellBtnCancel.isHidden = false
                    cell.cellBtnWithdraw.isHidden = true
                    cell.cellBtnAccept.isHidden = true
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{//2,3,4 = Approved, Rejected, Cancel
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue == "2" {//Approved
                        DispatchQueue.main.async {
                            cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                        }
                        cell.separatorInset = hideSeperator
                    }
                }
                
            case 6://Reject Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reject_Reason".localized()
                if cellArray["remark"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["remark"].stringValue
                }
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                }
                cell.separatorInset = hideSeperator
            default:
                break
            }
            //end .ot
            
        case .shift:
            switch indexPath.row {
            case 0://Swap Cell
                cell = swapCell
                cell.cellTitle.text = "\("Sent_Date".localized()) \(cellArray["sentdate"].stringValue)"
                cell.cellImage1.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName1.text = cellArray["empname"].stringValue
                cell.cellDate1.text = cellArray["date"].stringValue
                cell.cellTime1.text = cellArray["time"].stringValue
                
                cell.cellImage2.sd_setImage(with: URL(string:cellArray["to_empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName2.text = cellArray["to_empname"].stringValue
                cell.cellDate2.text = cellArray["to_date"].stringValue
                cell.cellTime2.text = cellArray["to_time"].stringValue
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1://Date
                cell = standardCell
                cell.cellTitle.text = "SWAP_DETAIL_Date".localized()
                cell.cellDescription.text = cellArray["sentdate"].stringValue
                
//            case 2://Time
//                cell = standardCell
//                cell.cellTitle.text = "SWAP_DETAIL_Time".localized()
//                cell.cellDescription.text = cellArray["date"].stringValue
                
            case 2://Reason
                cell = standardCell
                cell.cellTitle.text = "LEAVE_DETAIL_Reason".localized()
                if cellArray["reason"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["reason"].stringValue
                }
                
            case 3://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["headname"].stringValue
                cell.cellPosition.text = cellArray["headposition"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnAccept.addTarget(self, action: #selector(acceptClick(_:)), for: .touchUpInside)
                //cell.cellBtnWithdraw.addTarget(self, action: #selector(withdrawClick(_:)), for: .touchUpInside)
                
                
                
                if detailJSON!["is_requester"].stringValue == "1" {
                    if detailJSON!["status_code"].stringValue == "0" || detailJSON!["status_code"].stringValue == "1" {
                        cell.cellBtnStackView.isHidden = false
                        cell.cellBtnCancel.isHidden = false
                        cell.cellBtnWithdraw.isHidden = true
                        cell.cellBtnAccept.isHidden = true
                    }
                    else {
                        cell.cellBtnStackView.isHidden = true
                    }
                }
                else if detailJSON!["status_code"].stringValue == "0" {//Pending Response
                    cell.cellBtnStackView.isHidden = false
                    cell.cellBtnCancel.isHidden = false
                    cell.cellBtnWithdraw.isHidden = true
                    cell.cellBtnAccept.isHidden = false
                }
                else{//Cancel, Rejected
                    cell.cellBtnStackView.isHidden = true
                }
                
                if detailJSON!["status_id"].stringValue != "3" {//Rejected
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                
            case 4://Reject Reason
                cell = standardCell
                cell.cellTitle.text = "SWAP_Note".localized()
                if cellArray["remark"].stringValue == "" {
                    cell.cellDescription.text = emptyReason
                }
                else{
                    cell.cellDescription.text = cellArray["remark"].stringValue
                }
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                }
                cell.separatorInset = hideSeperator
            default:
                break
            }
        
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension LeaveDetail: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        //var cell = (tableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
        //cell.menuImage.setImageColor(color: .themeColor)
        //cell.menuTitle.textColor = .themeColor
    }
    
    @IBAction func cancelClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        let cellArray = self.detailJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "LEAVE_DETAIL_Confirm_Cancel".localized(), buttonTitle: "Confirm".localized(), buttonColor: .buttonRed)
        {
            if self.mode == .shift {
                self.loadAction(requestID: self.detailJSON!["timerequest_id"].stringValue, statusID:"4", reason:"LEAVE_Cancel_Employee".localized(), iswithdraw:"0")
            }else{
                self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:self.detailJSON!["cancel_status_id"].stringValue, reason:"LEAVE_Cancel_Employee".localized(), iswithdraw:"0")
            }
        }
        present(alertMain, animated: true)
    }
    
    @IBAction func withdrawClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        //let cellArray = self.detailJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "LEAVE_DETAIL_Confirm_Withdraw".localized(), buttonTitle: "LEAVE_DETAIL_Withdraw".localized(), buttonColor: .buttonRed)
        {
            self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:self.detailJSON!["cancel_status_id"].stringValue, reason:"LEAVE_DETAIL_Withdraw".localized(), iswithdraw:"1")
        }
        present(alertMain, animated: true)
    }
    
    @IBAction func acceptClick(_ sender: UIButton) {//Shift Accept Response
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        //let cellArray = self.detailJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "LEAVE_DETAIL_Confirm_Accept".localized(), buttonTitle: "LEAVE_DETAIL_Accept".localized(), buttonColor: .buttonGreen)
        {
            self.loadAction(requestID: self.detailJSON!["timerequest_id"].stringValue, statusID:"1", reason:"", iswithdraw:"0")
        }
        present(alertMain, animated: true)
    }
    
    func loadAction(requestID:String, statusID:String, reason:String ,iswithdraw:String) {
        
        print("Request ID = \(requestID) \nSTATUS = \(statusID) \nREMARK = \(reason) \nisWITHDRAW = \(iswithdraw) \n")

        var parameters:Parameters = [:]
        var url:String = ""
        
        switch mode {
        case .leave:
            url = "attendance/setleavesstatus"
            parameters = ["leave_id":requestID ,
                          "status":statusID ,//1=pending, 2=approve, 3=cancel,reject
                          "remarks":reason ,
                          "iswithdraw":iswithdraw]
        case .attendance:
            url = "attendance/settimerequeststatus"
            parameters = ["request_id":requestID ,
                          "status":statusID ,//1=pending, 2=approve, 3=cancel,reject
                          "remark":reason]
        case .ot:
            url = "attendance/settimeotstatus"
            parameters = ["time_request_id":requestID ,
                          "status":statusID ,//0=pending, 1=approve, 2=cancel,reject
                          "remark":reason]
        case .shift:
            url = "attendance/settimeswapstatus"
            parameters = ["timerequest_id":requestID ,
                          "status":statusID ,//0=pending response, 1=pending, 2=approve, 3=cancel,reject
                          "remark":reason]
        
        default:
            break
        }
        print(parameters)
        loadRequest(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS CANCEL OR WITHDRAW\(json)")

                self.submitSuccess()
                if (self.mode == .shift) {
                    //self.loadShiftDetail(withLoadingHUD: false)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
                        self.navigationController!.popViewController(animated: true)
                    }
                }
                else {
                    self.loadDetail(withLoadingHUD: false)
                }
            }
        }
    }
}
