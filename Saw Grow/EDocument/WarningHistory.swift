//
//  WarningHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class WarningHistory: UIViewController  {
    
    var warningTab:warningTab?
    var warningJSON:JSON?
    
    let alertService = AlertService()
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadWarning(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WARNING HISTORY")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadWarning(withLoadingHUD:Bool) {
        
        var parameters:Parameters = [:]
        if warningTab == .status {
            parameters = ["group":"status"]
        }
        else if warningTab == .history {
            parameters = ["group":"history"]
        }
        loadRequest(method:.get, apiName:"edocument/getwarninglist", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS WARNING HISTORY\(json)")
                
                self.warningJSON = json["data"][0]["warning"]
                
                self.myCollectionView.reloadData()
                
                if self.warningJSON!.count > 0
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

extension WarningHistory: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (warningJSON != nil) {
            return warningJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.warningJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"WarningHistory_Cell", for: indexPath) as! LeaveHistory_Cell
        
        cell.layer.cornerRadius = 15
        
        if warningTab == .status {
            cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = "WARNING_HISTORY_Title".localized()
            
        }
        else if warningTab == .history {
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = cellArray["empname"].stringValue
        }
        
        cell.cellTitle.text = cellArray[requestNameKey()].stringValue
        cell.cellDate.text = "\("Receive_Date".localized()) \(cellArray["senddate"].stringValue)"
        cell.cellStatus.text = cellArray["status_text"].stringValue
        cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        let countNo = cellArray["count"].stringValue
        if countNo == "" {
            cell.cellCountBg.isHidden = true
        } else{
            cell.cellCountBg.isHidden = false
            cell.cellCount.text = countNo
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension WarningHistory: UICollectionViewDelegateFlowLayout {

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

extension WarningHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.warningJSON![indexPath.item]
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
    }
    
    func pushToDetail(detailID:String) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningDetail") as! WarningDetail
        vc.warningTab = warningTab
        vc.detailID = detailID
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
        
        let cellArray = self.warningJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "Confirm_Delete".localized(), buttonTitle: "Delete".localized(), buttonColor: .buttonRed)
        {
            self.loadDelete(leaveID:cellArray["leaveid"].stringValue)
        }
        present(alertMain, animated: true)
    }
    
    func loadDelete(leaveID:String) {
        
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")

        let parameters:Parameters = ["leave_id":leaveID ,
                                     "status":"3" ,//3=cancel,reject
                                     "remarks":"LEAVE_Cancel_Employee".localized()
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/setleavesstatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")
                
                self.submitSuccess()
                self.loadWarning(withLoadingHUD: false)
            }
        }
    }
}
