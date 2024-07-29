//
//  WarningDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class WarningDetail: UIViewController {
    
    var warningTab:warningTab?
    var detailID:String?
    var detailJSON : JSON?
    
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

        print("WARNING DETAIL")
        
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
        loadRequest(method:.get, apiName:"edocument/getwarningdetail", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS WARNING DETAIL\(json)")
                
                self.detailJSON = json["data"][0]["warning"][0]
                self.myTableView.reloadData()
                
                if self.detailJSON!["status"].stringValue == "Accepted" {
                    self.pdfBtn.isHidden = false
                } else {
                    self.pdfBtn.isHidden = true
                }
            }
        }
    }
    
    @IBAction func viewPDF(_ sender: UIButton) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocWeb") as! EDocWeb
        vc.edocType = .warning_letter
        vc.edocJSON = detailJSON
        vc.titleString = ""
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension WarningDetail: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailJSON != nil) {
            return 4
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
        let reasonCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Reason", for: indexPath) as! LeaveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        switch indexPath.row {
        case 0://User Cell
            cell = userCell
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = cellArray["empname"].stringValue
            cell.cellPosition.text = cellArray["empposition"].stringValue
            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            DispatchQueue.main.async {
                cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
            }
            
        case 1://Leave Type
            cell = standardCell
            cell.cellTitle.text = "WARNING_DETAIL_Type".localized()
            cell.cellDescription.text = cellArray[requestNameKey()].stringValue
            
        case 2://Duration
            cell = standardCell
            cell.cellTitle.text = "WARNING_DETAIL_Duration".localized()
            cell.cellDescription.text = cellArray["date"].stringValue
            
        case 3://Reason
            cell = reasonCell
            cell.cellTitle.text = "WARNING_DETAIL_Reason".localized()
            if cellArray["reason"].stringValue == "" {
                cell.cellDescription.text = "-"
            }
            else{
                cell.cellDescription.text = cellArray["reason"].stringValue
            }
            
            if warningTab == .status && cellArray["status_id"].stringValue == "1" {//Pending
                cell.cellBtnAccept.isHidden = false
            }
            else {
                cell.cellBtnAccept.isHidden = true
            }
            
            cell.cellBtnAccept.addTarget(self, action: #selector(acceptClick(_:)), for: .touchUpInside)
            
            DispatchQueue.main.async {
                cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
            }
            cell.separatorInset = hideSeperator
            
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension WarningDetail: UITableViewDelegate {
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
        
        let alertMain = alertService.alertMain(title: "WARNING_DETAIL_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .buttonRed)
        {
            self.loadAction(requestID: self.detailJSON!["request_id"].stringValue, statusID:"2")
        }
        present(alertMain, animated: true)
    }
    
    
    func loadAction(requestID:String, statusID:String) {
        print("Request ID = \(requestID) \nSTATUS = \(statusID)\n")
        
        let parameters:Parameters = ["request_id":requestID,
                                     "status":statusID
        ]
        //print(parameters)
        
        loadRequest(method:.post, apiName:"edocument/setwarningstatus", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
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

