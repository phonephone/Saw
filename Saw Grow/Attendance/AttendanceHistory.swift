//
//  AttendanceHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 22/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class AttendanceHistory: UIViewController, UITextFieldDelegate {
    
    var attendanceJSON:JSON?
    
    let alertService = AlertService()
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadAttendance(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ATTENDANCE HISTORY")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadAttendance(withLoadingHUD:Bool) {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"attendance/gettimerequeststatus", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS HISTORY\(json)")
                
                self.attendanceJSON = json["data"][0]["timerequest"]
                
                self.myCollectionView.reloadData()
                
                if self.attendanceJSON!.count > 0
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

extension AttendanceHistory: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (attendanceJSON != nil) {
            return attendanceJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.attendanceJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"AttendanceHistory_Cell", for: indexPath) as! AttendanceHistory_Cell
        
        cell.layer.cornerRadius = 15
        
        //cell.cellImage.sd_setImage(with: URL(string:cellArray["statusurl"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        //cell.cellImage.image = UIImage(named: "attendance_clock")
        cell.cellTitle.text = cellArray["date"].stringValue
        cell.cellType.text = cellArray["desc"].stringValue
        cell.cellStatus.text = cellArray["status_text"].stringValue
        cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
        
        if cell.cellStatus.text == "Pending" {
            cell.cellBtnDelete.isHidden = false
        }
        else{
            cell.cellBtnDelete.isHidden = true
        }
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension AttendanceHistory: UICollectionViewDelegateFlowLayout {

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
        return CGSize(width: viewWidth , height:80)
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

extension AttendanceHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.attendanceJSON![indexPath.item]
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
    }
    
    func pushToDetail(detailID:String) {
        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveDetail") as! LeaveDetail
        vc.mode = .attendance
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
        
        let cellArray = self.attendanceJSON![indexPath.item]
        
        let alertMain = alertService.alertMain(title: "Confirm_Delete".localized(), buttonTitle: "Delete".localized(), buttonColor: .buttonRed)
        {
            self.loadDelete(timeRequestID:cellArray["timerequest_id"].stringValue)
        }
        present(alertMain, animated: true)
    }
    
    func loadDelete(timeRequestID:String) {
        
        //print("Submit ID =\(typeID) \nSTART =\(startDate) \nEND =\(endDate) \nHALF =\(halfDay) \nREMARK =\(descriptionStr) \n")

        let parameters:Parameters = ["request_id":timeRequestID ,
                                     "status":"3" ,//3=cancel,reject
                                     "remark":"LEAVE_Cancel_Employee".localized()
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:"attendance/settimerequeststatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")

                self.submitSuccess()
                self.loadAttendance(withLoadingHUD: false)
            }
        }
    }
}

