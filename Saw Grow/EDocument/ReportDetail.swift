//
//  ReportDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 18/6/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ReportDetail: UIViewController {
    
    var detailID:String?
    var detailJSON : JSON?
    
    var reportType:actionType?
    
    var emptyReason:String = "-"
    
    let alertService = AlertService()
    
    @IBOutlet var myTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REPORT DETAIL")
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        let tableviewInset = UIEdgeInsets(top: 20, left: 0, bottom: -30, right: 0)
        myTableView.contentInset = tableviewInset
        myTableView.verticalScrollIndicatorInsets = tableviewInset
        
        myTableView.showsVerticalScrollIndicator = false
        
        //loadDetail(withLoadingHUD: true)
    }
    
    func loadDetail(withLoadingHUD:Bool) {
        let parameters:Parameters = ["noti_id":detailID!]
        var url:String = ""
        var key:String = ""
        
        switch reportType {
        case .checkIn:
            url = "edocument/xxx"
            key = "empcer"
        case .update:
            url = "edocument/xxx"
            key = "empcer"
        case .checkOut:
            url = "edocument/xxx"
            key = "empcer"
            
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
                print("SUCCESS REPORT DETAIL\(json)")
                
                self.detailJSON = json["data"][0][key][0]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension ReportDetail: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (detailJSON != nil) {
            return detailJSON!.count
        }
        else{
            return 5
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (detailJSON != nil) {
            return 4
        }
        else{
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0//.leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    {
        let headerCell = UIView()
        //headerCell.backgroundColor = .red
        return headerCell
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView?
    {
        let footerCell = UIView()
        //footerCell.backgroundColor = .blue
        return footerCell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = LeaveDetail_Cell()
        
        let standardCell = tableView.dequeueReusableCell(withIdentifier: "ReportDetail_Standard", for: indexPath) as! LeaveDetail_Cell
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "ReportDetail_Image", for: indexPath) as! LeaveDetail_Cell
        let actionCell = tableView.dequeueReusableCell(withIdentifier: "ReportDetail_Action", for: indexPath) as! LeaveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        //let cellArray = self.detailJSON!
        
        switch indexPath.row {
        case 0://Time Cell
            cell = standardCell
            cell.cellTitle2.isHidden = false
            //            cell.cellTitle.text = cellArray["xxx"].stringValue
            //            cell.cellTitle2.text = cellArray["xxx"].stringValue
            //            cell.cellDescription.text = cellArray["xxx"].stringValue
            
            DispatchQueue.main.async {
                cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
            }
            
        case 1://Attach Cell
            cell = imageCell
            //            cell.cellTitle.text = cellArray["xxx"].stringValue
            //            cell.cellDescription.text = emptyReason
            //
            
            //            if cellArray["image"].stringValue == "" {
            //                cell.cellDescription.isHidden = false
            //                cell.cellImage.isHidden = true
            //            }
            //            else{
            //                cell.cellImage.sd_setImage(with: URL(string:cellArray["xxx"].stringValue), placeholderImage: nil)
            cell.cellDescription.isHidden = true
            //                cell.cellImage.isHidden = false
            cell.cellImage.addTapGesture {
                let alertImage = self.alertService.alertImageWithText(image: cell.cellImage.image)
                {print("Done Clicked")}
                self.present(alertImage, animated: true)
            }
            //            }
            
        case 2://Note Cell
            cell = standardCell
            cell.cellTitle2.isHidden = true
            cell.cellTitle.text = "Note"//cellArray["xxx"].stringValue
            cell.cellDescription.text = "Test Report Description Test Report Description Test Report Description Test Report Description"//cellArray["xxx"].stringValue
            //            if cell.cellDescription.text == "" {
            //                cell.cellDescription.text = emptyReason
            //            }
            
        case 3://Location Cell
            cell = actionCell
            cell.cellTitle.text = "Location"//cellArray["xxx"].stringValue
            cell.cellBtnAction.addTarget(self, action: #selector(locationClick(_:)), for: .touchUpInside)
            cell.cellDescription.text = "Test Report Description Test Report Description Test Report Description Test Report Description"//cellArray["xxx"].stringValue
            
            
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

extension ReportDetail: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
    }
    
    @IBAction func imageClick(_ sender: UIButton) {
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
        print("Action \(indexPath.section) - \(indexPath.item)")
        //let cellArray = self.detailJSON![indexPath.item]
        
        
    }
    
    @IBAction func locationClick(_ sender: UIButton) {
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
        print("Action \(indexPath.section) - \(indexPath.item)")
        //let cellArray = self.detailJSON![indexPath.item]
        
        let alertMap = alertService.alertMap(title: "144/102 Kubon 27 Bangkok Bangkok 10220 Thailand", lat: "13.805997", long: "100.618")
        {
            print("Done Clicked")
        }
        present(alertMap, animated: true)
    }
}



