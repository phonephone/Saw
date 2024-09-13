//
//  ApproveDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ApproveDetail: UIViewController, UITextViewDelegate {
    
    var approveType:approveType?
    var detailID:String?
    var detailJSON : JSON?
    
    var emptyReason:String = "-"
    
    let remarkStr = "APPROVE_DETAIL_Default_Reject_Reason".localized()
    
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

        print("APPROVE DETAIL")
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        myTableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        
        //self.hideKeyboardWhenTappedAround()
        
        switch approveType {
        case .leave:
            headerTitle.text = "APPROVE_DETAIL_LEAVE_Header".localized()
        case .attendance:
            headerTitle.text = "APPROVE_DETAIL_ATTENDANCE_Header".localized()
        case .ot:
            headerTitle.text = "APPROVE_DETAIL_OT_Header".localized()
        case .shift:
            headerTitle.text = "APPROVE_DETAIL_SWAP_Header".localized()
        
        default:
            break
        }
        
        loadDetail(withLoadingHUD: true)
    }
    
    func loadDetail(withLoadingHUD:Bool) {
        let parameters:Parameters = ["noti_id":detailID!]
        var url:String = ""
        var arrayName:String = ""
        
        if approveType == .shift {
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
                print("SUCCESS APPROVE DETAIL\(json)")
                
                self.detailJSON = json["data"][0][arrayName][0]
                self.myTableView.reloadData()
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == remarkStr {
            textView.text = ""
            textView.textColor = .textDarkGray
        }
        
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        
        var superview = textView.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            return
        }
        print("textView index \(indexPath.section) - \(indexPath.item)")
        
        let headCell = (myTableView.cellForRow(at: indexPath) as? ApproveDetail_Cell)!
        if textView.text != "" {
            headCell.cellBtnReject.enableBtn()
            headCell.cellBtnReject.backgroundColor = .buttonRed
        }
        else{
            headCell.cellBtnReject.disableBtn()
        }
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = remarkStr
            textView.textColor = UIColor.lightGray
        }
        return true
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension ApproveDetail: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailJSON != nil) {
            switch approveType {
            case .leave:
                if detailJSON!["status_id"].stringValue == "3" {//Rejected
                    return 7
                }
                else {
                    return 6
                }
            case .attendance:
                if detailJSON!["status_id"].stringValue == "3" {//Rejected
                    return 7
                }
                else {
                    return 6
                }
            case .ot:
                if detailJSON!["status_id"].stringValue == "3" {//Rejected
                    return 7
                }
                else {
                    return 6
                }
            case .shift:
                if detailJSON!["status_id"].stringValue == "3" {//Rejected
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
        var cell = ApproveDetail_Cell()
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_User", for: indexPath) as! ApproveDetail_Cell
        let standardCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_Standard", for: indexPath) as! ApproveDetail_Cell
        let headCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_Head", for: indexPath) as! ApproveDetail_Cell
        let doubleCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_DoubleColumn", for: indexPath) as! ApproveDetail_Cell
        let reasonCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_Reason", for: indexPath) as! ApproveDetail_Cell
        let swapCell = tableView.dequeueReusableCell(withIdentifier: "ApproveDetail_Shift", for: indexPath) as! ApproveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        switch approveType {
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
                
            case 5://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["headname"].stringValue
                cell.cellPosition.text = cellArray["headposition"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellReason.delegate = self
                cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
                cell.cellReason.text = remarkStr
                cell.cellReason.textColor = UIColor.lightGray
                
                cell.cellBtnApprove.addTarget(self, action: #selector(approveClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" && detailJSON!["approval_match"].stringValue == "1" {//Pending
                    cell.cellReason.isHidden = false
                    cell.cellBtnStackView.isHidden = false
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue != "3" {//Rejected
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
                
                cell.cellReason.delegate = self
                cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
                cell.cellReason.text = remarkStr
                cell.cellReason.textColor = UIColor.lightGray
                
                cell.cellBtnApprove.addTarget(self, action: #selector(approveClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" && detailJSON!["approval_match"].stringValue == "1" {//Pending
                    cell.cellReason.isHidden = false
                    cell.cellBtnStackView.isHidden = false
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue != "3" {//Rejected
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
                
                cell.cellReason.delegate = self
                cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
                cell.cellReason.text = remarkStr
                cell.cellReason.textColor = UIColor.lightGray
                
                cell.cellBtnApprove.addTarget(self, action: #selector(approveClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_id"].stringValue == "1" && detailJSON!["approval_match"].stringValue == "1" {//Pending
                    cell.cellReason.isHidden = false
                    cell.cellBtnStackView.isHidden = false
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue != "3" {//Rejected
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
            case 0://User Cell
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
                
                cell.cellReason.delegate = self
                cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
                cell.cellReason.text = remarkStr
                cell.cellReason.textColor = UIColor.lightGray
                
                cell.cellBtnApprove.addTarget(self, action: #selector(approveClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_code"].stringValue == "1" {
                    cell.cellReason.isHidden = false
                    cell.cellBtnStackView.isHidden = false
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                    }
                    cell.separatorInset = hideSeperator
                }
                else{
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                    if detailJSON!["status_id"].stringValue != "3" {//Rejected
                        DispatchQueue.main.async {
                            cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                        }
                        cell.separatorInset = hideSeperator
                    }
                }
                
            case 4://Reject Reason
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
        
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ApproveDetail: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        //var cell = (tableView.cellForRow(at: indexPath) as? ApproveDetail_Cell)!
        //cell.menuImage.setImageColor(color: .themeColor)
        //cell.menuTitle.textColor = .themeColor
    }
    
    @IBAction func approveClick(_ sender: UIButton) {
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
        
        let alertMain = alertService.alertMain(title: "APPROVE_Confirm".localized(), buttonTitle: "APPROVE_Approve".localized(), buttonColor: .buttonGreen)
        {
            let headCell = (self.myTableView.cellForRow(at: indexPath) as? ApproveDetail_Cell)!
            
            if self.approveType == .shift {
                self.loadAction(requestID: self.detailJSON!["timerequest_id"].stringValue, statusID:"2", reason:headCell.cellReason.text)
            }
            else{
                self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:self.detailJSON!["next_approve_status_id"].stringValue, reason:headCell.cellReason.text)
            }
        }
        present(alertMain, animated: true)
    }
    
    @IBAction func rejectClick(_ sender: UIButton) {
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
        
        let alertMain = alertService.alertMain(title: "APPROVE_Reject_Confirm".localized(), buttonTitle: "APPROVE_Reject".localized(), buttonColor: .buttonRed)
        {
            let headCell = (self.myTableView.cellForRow(at: indexPath) as? ApproveDetail_Cell)!
            
            if self.approveType == .shift {
                self.loadAction(requestID: self.detailJSON!["timerequest_id"].stringValue, statusID:"3", reason:headCell.cellReason.text)
            }
            else{
                self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:self.detailJSON!["rejected_status_id"].stringValue, reason:headCell.cellReason.text)
            }
        }
        present(alertMain, animated: true)
    }
    
    func loadAction(requestID:String, statusID:String, reason:String) {
        
        var descriptionStr:String
        if reason == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = reason
        }
        
        //print("Request ID = \(requestID) \nSTATUS = \(statusID) \nREMARK = \(descriptionStr) \n")
        
        var parameters:Parameters = [:]
        var url:String = ""
        
        switch approveType {
        case .leave:
            url = "attendance/setleavesstatus"
            parameters = ["leave_id":requestID ,
                          "status":statusID ,//1=pending, 2=approve, 3=cancel,reject
                          "remarks":descriptionStr]
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
        
        print(url)
        print(parameters)

        loadRequest(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS APPROVE\(json)")

                self.submitSuccess()
                self.loadDetail(withLoadingHUD: false)
            }
        }
    }
}
