//
//  EDocHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EDocHistory: UIViewController  {
    
    var historyJSON:JSON?
    
    var edocName:String?
    var edocType:edocType?
    
    let alertService = AlertService()
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadHistory(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EDOC HISTORY")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadHistory(withLoadingHUD:Bool) {
        var parameters:Parameters = [:]
        var url:String = ""
        var key:String = ""
        
        switch edocType {
        case .work_cert:
            parameters = ["group":"status",
                          "type":"empcer"]
            url = "edocument/getempcerlist"
            key = "empcer"
            
        case .salary_cert:
            parameters = ["group":"status",
                          "type":"empsalary"]
            url = "edocument/getempcerlist"
            key = "empcer"
            
        case .payslip:
            parameters = ["group":"history"]
            url = "edocument/getsliplist"
            key = "slip"
            
        case .reimburse:
            parameters = ["group":"status"]
            url = "reimburse/getreimburselist"
            key = "reimburse"
            
        case .probation:
            parameters = ["group":"history"]
            url = "edocument/getprobationlist"
            key = "probation"
        
        default:
            break
        }
        
        loadRequest(method:.get, apiName:url, authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS EDOC HISTORY\(json)")
                
                self.historyJSON = json["data"][0][key]
                
                self.myCollectionView.reloadData()
                
                if self.historyJSON!.count > 0
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

extension EDocHistory: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (historyJSON != nil) {
            return historyJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.historyJSON![indexPath.item]
        
        switch edocType {
        case .work_cert,.salary_cert:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"EdocHistory_Cell", for: indexPath) as! LeaveHistory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
    //        cell.cellName.text = cellArray["empname"].stringValue
            cell.cellTitle.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = "\("Sent_Date".localized()) \(cellArray["senddate"].stringValue)"
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
            
            if cellArray["status_id"].stringValue == "1" {//Pending
                cell.cellBtnDelete.isHidden = false
            }
            else{
                cell.cellBtnDelete.isHidden = true
            }
            
            return cell
            
        case .reimburse:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ReimburseHistory_Cell", for: indexPath) as! LeaveHistory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
    //        cell.cellName.text = cellArray["empname"].stringValue
            cell.cellTitle.text = cellArray[requestNameKey()].stringValue
            cell.cellTitle2.text = cellArray["amount"].stringValue
            cell.cellDate.text = "\("Sent_Date".localized()) \(cellArray["senddate"].stringValue)"
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
            
            if cellArray["status_id"].stringValue == "1" {//Pending
                cell.cellBtnDelete.isHidden = false
            }
            else{
                cell.cellBtnDelete.isHidden = true
            }
            
            return cell
            
        case .payslip:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SlipHistory_Cell", for: indexPath) as! LeaveHistory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = cellArray[requestNameKey()].stringValue
            cell.cellDate.text = "\("EDOC_SLIP_Period".localized()) \(cellArray["period"].stringValue)"
            cell.cellSentDate.text = "\("Sent_Date".localized()) \(cellArray["senddate"].stringValue)"
            
            return cell
            
        case .probation:
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ProbationHistory_Cell", for: indexPath) as! LeaveHistory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = cellArray["empname"].stringValue
            cell.cellDate.text = cellArray["date"].stringValue
            cell.cellCount.text = cellArray["sum"].stringValue
            cell.cellStatus.text = cellArray["status"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            return cell
        
        default:
            return UICollectionViewCell()
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension EDocHistory: UICollectionViewDelegateFlowLayout {

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
        return CGSize(width: viewWidth , height:88)
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

extension EDocHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.historyJSON![indexPath.item]
        
        
        switch edocType {
        case .work_cert,.salary_cert,.reimburse:
            pushToDetail(detailID: cellArray["noti_id"].stringValue)
            
        case .payslip:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocWeb") as! EDocWeb
            vc.edocType = edocType
            vc.edocJSON = cellArray
            vc.titleString = ""
            self.navigationController!.pushViewController(vc, animated: true)
            
        case .probation:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ProbationDetail") as! ProbationDetail
            vc.edocName = edocName
            vc.edocType = edocType
            vc.detailID = cellArray["noti_id"].stringValue
            vc.detailJSON = cellArray
            self.navigationController!.pushViewController(vc, animated: true)
        
        default:
            break
        }
    }
    
    func pushToDetail(detailID:String) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocDetail") as! EDocDetail
        vc.edocType = edocType
        vc.detailID = detailID
        vc.isHead = false
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myCollectionView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        
        let cellArray = self.historyJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "Confirm_Delete".localized(), buttonTitle: "Delete".localized(), buttonColor: .buttonRed)
        {
            self.loadDelete(requestID:cellArray["request_id"].stringValue)
        }
        present(alertMain, animated: true)
    }
    
    func loadDelete(requestID:String) {
        
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")
        
        var url:String = ""
        
        switch edocType {
        case .work_cert,.salary_cert:
            url = "edocument/setempcerstatus"
            
        case .reimburse:
            url = "reimburse/setreimbursestatus"
        
        default:
            break
        }

        let parameters:Parameters = ["request_id":requestID ,
                                     "status":"3" ,//3=cancel,reject
                                     "reason":"LEAVE_Cancel_Employee".localized() ,
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:url, authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")
                
                self.submitSuccess()
                self.loadHistory(withLoadingHUD: false)
            }
        }
    }
}

