//
//  ApproveRequest.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ApproveRequest: UIViewController, UITextFieldDelegate {
    
    var approveType:approveType?
    var approveJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadApprove(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("APPROVE REQUEST")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadApprove(withLoadingHUD:Bool) {
        
        var parameters:Parameters = [:]
        var url:String = ""
        var arrayName:String = ""
        
        switch approveType {
        case .leave:
            url = "workflow/getapproval"
            parameters = ["type":"leave",
                          "group":"request"]
            arrayName = "approval"
        case .attendance:
            url = "workflow/getapproval"
            parameters = ["type":"timerequest",
                          "group":"request"]
            arrayName = "approval"
        case .ot:
            url = "workflow/getapproval"
            parameters = ["type":"timeot",
                          "group":"request"]
            arrayName = "approval"
        case .shift:
            url = "attendance/gettimeswapstatus"
            parameters = ["group":"approve"]
            arrayName = "timeswap"
            
        case .edocument:
            url = "edocument/getempcerlist"
            parameters = ["group":"request"]
            arrayName = "empcer"
            
        case .reimburse:
            url = "reimburse/getreimburselist"
            parameters = ["group":"request"]
            arrayName = "reimburse"
        
        default:
            break
        }
        
        loadRequest(method:.get, apiName:url, authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS APPROVE\(json)")
                
                self.approveJSON = json["data"][0][arrayName]
                self.myCollectionView.reloadData()
                
                if self.approveJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                }
                else{
                    self.showErrorNoData()
                }
            }
        }
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension ApproveRequest: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (approveJSON != nil) {
            return approveJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.approveJSON![indexPath.item]
        
        var cell = Approve_Cell()
        if approveType == .shift {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Approve_Swap_Cell", for: indexPath) as! Approve_Cell
        }
        else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Approve_Cell", for: indexPath) as! Approve_Cell
        }
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["statusurl"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        switch approveType {
        case .leave:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellApproveType.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
        case .attendance:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellApproveType.text = cellArray["type"].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
        case .ot:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellApproveType.text = cellArray["desc"].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
        case .edocument:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellApproveType.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = cellArray["senddate"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
        case .shift:
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellImage2.sd_setImage(with: URL(string:cellArray["to_empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = "\(cellArray["empname"].stringValue) \("SWAP_Response_Title".localized()) \(cellArray["empname"].stringValue)"
            cell.cellDate.text = "\("Sent_Date".localized())  \(cellArray["sentdate"].stringValue)"
            cell.cellRemark.text = "\("SWAP_Note".localized()) : \(cellArray["reason"].stringValue)"
            
            cell.cellStatus.text = cellArray["status"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            cell.cellBtnApprove.isHidden = true
            cell.cellBtnReject.isHidden = true
            
        case .reimburse:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellApproveType.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = "\("Sent_Date".localized())  \(cellArray["senddate"].stringValue)"
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        default:
            break
        }
        
        cell.cellBtnApprove.addTarget(self, action: #selector(approveClick(_:)), for: .touchUpInside)
        cell.cellBtnReject.addTarget(self, action: #selector(rejectClick(_:)), for: .touchUpInside)
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ApproveRequest: UICollectionViewDelegateFlowLayout {

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
        
        if approveType == .shift {
            return CGSize(width: viewWidth , height:160)
        }
        else {
            return CGSize(width: viewWidth , height:88)
        }
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

extension ApproveRequest: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.approveJSON![indexPath.item]
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
    }
    
    func pushToDetail(detailID:String) {
        if approveType == .edocument {
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocDetail") as! EDocDetail
            //vc.edocType = .salary_cert
            vc.detailID = detailID
            vc.isHead = true
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else if approveType == .reimburse {
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocDetail") as! EDocDetail
            vc.edocType = .reimburse
            vc.detailID = detailID
            vc.isHead = true
            self.navigationController!.pushViewController(vc, animated: true)
        }
        else{
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveDetail") as! ApproveDetail
            vc.approveType = approveType
            vc.detailID = detailID
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
    
    @IBAction func approveClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            return
        }
        guard let indexPath = myCollectionView.indexPath(for: cell) else {
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = self.approveJSON![indexPath.item]
        
        var alert = UIAlertController()
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.title = "APPROVE_Confirm".localized()
        //alert.message = "plaes make sure before..."
        
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        
        alert.addAction(UIAlertAction(title: "APPROVE_Approve".localized(), style: .default, handler: { action in
            if self.approveType == .ot {
                self.loadAction(requestID: cellArray["request_id"].stringValue, statusID:"1", reason:"")
            }
            else if self.approveType == .reimburse {
                self.loadAction(requestID: cellArray["request_id"].stringValue, statusID:cellArray["approve_next_status"].stringValue, reason:"")
            }
            else{
                self.loadAction(requestID: cellArray["request_id"].stringValue, statusID:"2", reason:"")
            }
        }))
        alert.actions.last?.titleTextColor = .buttonGreen
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    @IBAction func rejectClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            return
        }
        guard let indexPath = myCollectionView.indexPath(for: cell) else {
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = self.approveJSON![indexPath.item]
        
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
        
//        var alert = UIAlertController()
//        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
//        alert.title = "Confirm Reject"
//
//        alert.addTextField() { reasonTextField in
//            reasonTextField.placeholder = "Enter some reason"
//            reasonTextField.textColor = .textDarkGray
//            reasonTextField.font = UIFont.Roboto_Regular(ofSize: 16)
//        }
//
//        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: { action in
//
//        }))
//
//        alert.addAction(UIAlertAction(title: "Reject", style: .default, handler: { action in
//            if
//                let textFields = alert.textFields,
//                let firstField = textFields.first,
//                let result = firstField.text
//            {
//                print("REASON \(result)")
//            }
//            //self.loadDelete(leaveID:cellArray["leaveid"].stringValue)
//        }))
//        alert.actions.last?.titleTextColor = .buttonRed
//        alert.setColorAndFont()
//
//        self.present(alert, animated: true)
    }
    
    func loadAction(requestID:String, statusID:String, reason:String) {
        
        //print("Request ID = \(requestID) \nSTATUS = \(statusID) \nREMARK = \(reason) \n")

        var parameters:Parameters = [:]
        var url:String = ""
        
        switch approveType {
        case .leave:
            url = "attendance/setleavesstatus"
            parameters = ["leave_id":requestID ,
                          "status":statusID ,//1=pending, 2=approve, 3=cancel,reject
                          "remarks":reason]
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
            url = ""
            
        case .edocument:
            url = "edocument/setempcerstatus"
            parameters = ["request_id":requestID,
                          "status":statusID]
            
        case .reimburse:
            url = "reimburse/setreimbursestatus"
            parameters = ["request_id":requestID,
                          "status":statusID]
        default:
            break
        }

        loadRequest(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS APPROVE\(json)")

                self.submitSuccess()
                self.loadApprove(withLoadingHUD: false)
            }
        }
    }
}
