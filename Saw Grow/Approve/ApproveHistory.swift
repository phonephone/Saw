//
//  ApproveHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ApproveHistory: UIViewController, UITextFieldDelegate {
    
    var approveType:approveType?
    var approveJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadApprove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("APPROVE HISTORY")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadApprove() {
        
        var parameters:Parameters = [:]
        var url:String = ""
        var arrayName:String = ""
        
        switch approveType {
        case .leave:
            url = "workflow/getapproval"
            parameters = ["type":"leave"
                          ,"group":"history"]
            arrayName = "approval"
        case .attendance:
            url = "workflow/getapproval"
            parameters = ["type":"timerequest"
                          ,"group":"history"]
            arrayName = "approval"
        case .ot:
            url = "workflow/getapproval"
            parameters = ["type":"timeot",
                          "group":"history"]
            arrayName = "approval"
        case .shift:
            url = "attendance/gettimeswapstatus"
            parameters = ["group":"approvehistory"]
            arrayName = "timeswap"
            
        case .edocument:
            url = "edocument/getempcerlist"
            parameters = ["group":"history"]
            arrayName = "empcer"
            
        case .reimburse:
            url = "reimburse/getreimburselist"
            parameters = ["group":"history"]
            arrayName = "reimburse"
        
        default:
            break
        }
        
        loadRequest(method:.get, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS APPROVE HISTORY\(json)")
                
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

extension ApproveHistory: UICollectionViewDataSource {
    
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
            
        case .attendance:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellApproveType.text = cellArray["type"].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            
        case .ot:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellApproveType.text = cellArray["desc"].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            
        case .edocument:
            cell.cellTitle.text = cellArray["empname"].stringValue
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellApproveType.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = cellArray["senddate"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            
        case .shift:
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellImage2.sd_setImage(with: URL(string:cellArray["to_empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = "\(cellArray["empname"].stringValue) \("SWAP_Response_Title".localized()) \(cellArray["empname"].stringValue)"
            cell.cellDate.text = "\("Sent_Date".localized())  \(cellArray["sentdate"].stringValue)"
            cell.cellRemark.text = "\("SWAP_Note".localized()) : \(cellArray["reason"].stringValue)"
            
            cell.cellStatus.text = cellArray["status"].stringValue
            
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
        
        cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ApproveHistory: UICollectionViewDelegateFlowLayout {

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

extension ApproveHistory: UICollectionViewDelegate {
    
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
}
