//
//  EDocDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EDocDetail: UIViewController, UITextViewDelegate {
    
    var detailID:String?
    var detailJSON : JSON?
    
    var edocType:edocType? = .salary_cert
    var isHead:Bool?
    
    var detailRow:Int?
    
    var emptyReason:String = "-"
    
    let remarkStr = "APPROVE_DETAIL_Default_Reject_Reason".localized()
    
    var setColor: Bool = true
    
    let alertService = AlertService()
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet var pdfBtn: UIButton!
    
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

        print("EDOC DETAIL")
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        myTableView.contentInset = UIEdgeInsets(top: 25, left: 0, bottom: 25, right: 0)
        
        //self.hideKeyboardWhenTappedAround()
        
        pdfBtn.isHidden = true
        
        loadDetail(withLoadingHUD: true)
    }
    
    func loadDetail(withLoadingHUD:Bool) {
        let parameters:Parameters = ["noti_id":detailID!]
        var url:String = ""
        var key:String = ""
        
        switch edocType {
        case .work_cert,.salary_cert:
            url = "edocument/getempcerdetail"
            key = "empcer"
            
        case .reimburse:
            url = "reimburse/getreimbursedetail"
            key = "reimburse"
        
        default:
            break
        }
        print(parameters)
        loadRequest(method:.get, apiName:url, authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS EDOC DETAIL\(json)")
                
                self.detailJSON = json["data"][0][key][0]
                self.myTableView.reloadData()
                
                if (self.edocType == .salary_cert || self.edocType == .work_cert) && self.detailJSON!["status"].stringValue == "Approved" {
                    self.pdfBtn.isHidden = false
                } else {
                    self.pdfBtn.isHidden = true
                }
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
        
        let headCell = (myTableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
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
    
    @IBAction func viewPDF(_ sender: UIButton) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocWeb") as! EDocWeb
        vc.edocType = edocType
        vc.edocJSON = detailJSON
        vc.titleString = ""
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension EDocDetail: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailJSON != nil) {
            switch edocType {
            case .work_cert,.salary_cert:
                return 3
                
            case .reimburse:
                if detailJSON!["status_code"].stringValue == "3" {//Rejected,Cancel
                    return 6
                }
                else {
                    return 7
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
        let reasonCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Reason", for: indexPath) as! LeaveDetail_Cell
        let processCell = tableView.dequeueReusableCell(withIdentifier: "Process_Cell", for: indexPath) as! LeaveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        switch edocType {
        case .work_cert,.salary_cert:
            switch indexPath.row {
            case 0://User Cell
                cell = userCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["empname"].stringValue
                cell.cellPosition.text = cellArray["empposition"].stringValue
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1://Leave Type
                cell = standardCell
                cell.cellTitle.text = "EDOC_DETAIL_Type".localized()
                cell.cellDescription.text = cellArray[requestNameKey()].stringValue
                
            case 2://Head Cell
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
                
                cell.cellBtnAccept.addTarget(self, action: #selector(acceptClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status"].stringValue == "Pending" {
                    cell.cellBtnStackView.isHidden = false
                    
                    if isHead! {
                        cell.cellReason.isHidden = false
                        cell.cellReason.isUserInteractionEnabled = true
                        cell.cellBtnAccept.isHidden = false
                        cell.cellBtnReject.isHidden = false
                        cell.cellBtnCancel.isHidden = true
                    }
                    else {
                        cell.cellReason.isHidden = true
                        cell.cellBtnAccept.isHidden = true
                        cell.cellBtnReject.isHidden = true
                        cell.cellBtnCancel.isHidden = false
                    }
                }
                else if detailJSON!["status"].stringValue == "Rejected" {
                    cell.cellReason.isHidden = false
                    cell.cellReason.isUserInteractionEnabled = false
                    cell.cellReason.text = detailJSON!["reason"].stringValue
                    cell.cellBtnStackView.isHidden = true
                }
                else{//Approved, Cancel
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                }
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
                }
                cell.separatorInset = hideSeperator
                
            default:
                break
            }
            
        case .reimburse:
            var indexAdd = 0
            if detailJSON!["status_code"].stringValue == "3" {
                indexAdd = -1
            }
            else{
                indexAdd = 0
            }
            
            switch indexPath.row {
            case 0+indexAdd://Process Cell
                cell = processCell
                
                cell.cellCircle1.isHidden = true
                cell.cellCircle2.isHidden = true
                cell.cellCircle3.isHidden = true
                
                cell.cellImage1.isHidden = true
                cell.cellImage2.isHidden = true
                cell.cellImage3.isHidden = true
                
                cell.cellCircle2.backgroundColor = .textGray
                cell.cellCircle3.backgroundColor = .textGray
                
                cell.cellLine1.backgroundColor = .textGray
                cell.cellLine2.backgroundColor = .textGray
                
                switch detailJSON!["status_code"].stringValue {
                case "1"://Pending
                    cell.cellImage1.isHidden = false
                    cell.cellCircle2.isHidden = false
                    cell.cellCircle3.isHidden = false
                    
                case "2"://Approved
                    cell.cellCircle1.isHidden = false
                    cell.cellCircle1.backgroundColor = .themeColor
                    cell.cellLine1.backgroundColor = .themeColor
                    
                    cell.cellCircle2.isHidden = false
                    cell.cellCircle2.backgroundColor = .themeColor
                    cell.cellLine2.backgroundColor = .themeColor
                    
                    cell.cellImage3.isHidden = false
                    
                default: //Checking = "4" or other
                    cell.cellCircle1.isHidden = false
                    cell.cellCircle1.backgroundColor = .themeColor
                    cell.cellLine1.backgroundColor = .themeColor
                    
                    cell.cellImage2.isHidden = false
                    cell.cellCircle3.isHidden = false
                }
                
                DispatchQueue.main.async {
                    cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                }
                
            case 1+indexAdd://User Cell
                cell = userCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["empname"].stringValue
                cell.cellPosition.text = cellArray["empposition"].stringValue
                
                if detailJSON!["status_code"].stringValue == "3" {
                    DispatchQueue.main.async {
                        cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
                    }
                }
                
            case 2+indexAdd://Type
                cell = standardCell
                cell.cellTitle.text = "EDOC_DETAIL_Type".localized()
                cell.cellDescription.text = cellArray[requestNameKey()].stringValue
                
            case 3+indexAdd://Request Date
                cell = standardCell
                cell.cellTitle.text = "ATTENDANCE_DETAIL_Date".localized()
                cell.cellDescription.text = cellArray["request_date"].stringValue
                
            case 4+indexAdd://Amount
                cell = standardCell
                cell.cellTitle.text = "REIMBURSE_DETAIL_Amount_Field".localized()
                cell.cellDescription.text = cellArray["amount"].stringValue
                
            case 5+indexAdd://Reason
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
                    cell.cellImage.sd_setImage(with: URL(string:urlStr), placeholderImage: UIImage(named: ""))
                    cell.cellImage.isHidden = false
                }
                else{
                    cell.cellImage.image = nil
                    cell.cellImage.isHidden = true
                }
                
            case 6+indexAdd://Head Cell
                cell = headCell
                cell.cellImage.sd_setImage(with: URL(string:cellArray["head_approve_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                cell.cellName.text = cellArray["head_approve_name"].stringValue
                cell.cellPosition.text = cellArray["head_approve_position"].stringValue
                
                cell.cellStatus.text = cellArray["status_text"].stringValue
                cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
                
                cell.cellReason.delegate = self
                cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
                cell.cellReason.text = remarkStr
                cell.cellReason.textColor = UIColor.lightGray
                
                cell.cellBtnAccept.addTarget(self, action: #selector(acceptClick(_:)), for: .touchUpInside)
                cell.cellBtnReject.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                cell.cellBtnCancel.addTarget(self, action: #selector(cancelClick(_:)), for: .touchUpInside)
                
                if detailJSON!["status_code"].stringValue == "2" {//Approve
                    cell.cellReason.isHidden = true
                    cell.cellBtnStackView.isHidden = true
                }
                else if detailJSON!["status_code"].stringValue == "3" {//Rejected
                    cell.cellReason.isHidden = false
                    cell.cellReason.isUserInteractionEnabled = false
                    cell.cellReason.text = detailJSON!["reason"].stringValue
                    cell.cellBtnStackView.isHidden = true
                }
                else{//"1"(Pending) & "4...9"
                    cell.cellBtnStackView.isHidden = false
                    
                    if isHead! {
                        cell.cellReason.isHidden = false
                        cell.cellReason.isUserInteractionEnabled = true
                        cell.cellBtnAccept.isHidden = false
                        cell.cellBtnReject.isHidden = false
                        cell.cellBtnCancel.isHidden = true
                    }
                    else {
                        cell.cellReason.isHidden = true
                        cell.cellBtnAccept.isHidden = true
                        cell.cellBtnReject.isHidden = true
                        cell.cellBtnCancel.isHidden = false
                    }
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

extension EDocDetail: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        //var cell = (tableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
        //cell.menuImage.setImageColor(color: .themeColor)
        //cell.menuTitle.textColor = .themeColor
    }
    
    @IBAction func acceptClick(_ sender: UIButton) {
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
        
        let alertMain = alertService.alertMain(title: "APPROVE_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .buttonGreen)
        {
            let headCell = (self.myTableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
            
            if self.edocType == .work_cert || self.edocType == .salary_cert {
                self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:"2", reason: headCell.cellReason.text)
            }
            else if self.edocType == .reimburse {
                self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:self.detailJSON!["approve_next_status"].stringValue, reason: headCell.cellReason.text)
            }
        }
        present(alertMain, animated: true)
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
        //let cellArray = self.detailJSON![indexPath.item]
        
        var alertTitle = String()
        if isHead! {
            alertTitle = "APPROVE_Reject_Confirm".localized()
        } else {
            alertTitle = "LEAVE_DETAIL_Confirm_Cancel".localized()
        }
        
        let alertMain = alertService.alertMain(title: alertTitle, buttonTitle: "Confirm".localized(), buttonColor: .buttonRed)
        {
            var reason:String
            if self.isHead! {
                let headCell = (self.myTableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
                reason = headCell.cellReason.text
            } else {
                reason = "LEAVE_Cancel_Employee".localized()
            }
            self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:"3", reason: reason)
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
        
        print("Request ID = \(requestID) \nSTATUS = \(statusID)\nREMARK = \(descriptionStr) \n")
        
        var url:String = ""
        
        switch edocType {
        case .work_cert,.salary_cert:
            url = "edocument/setempcerstatus"
            
        case .reimburse:
            url = "reimburse/setreimbursestatus"
        
        default:
            break
        }
        
        let parameters:Parameters = ["request_id":requestID,
                                     "status":statusID,//1=pending, 2=approve, 3=cancel,reject
                                     "reason":descriptionStr
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS WARNING ACCEPT\(json)")

                self.submitSuccess()
                self.loadDetail(withLoadingHUD: false)
                self.myTableView.reloadData()
            }
        }
    }
}


