//
//  ProbationDetail.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class ProbationDetail: UIViewController, UITextViewDelegate {
    
    var detailJSON:JSON?
    var scoreJSON:JSON?
    
    var detailID:String?
    var edocName:String?
    var edocType:edocType?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
    
    @IBOutlet weak var scoreLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
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
        print("PROBATION DETAIL")
        
        headTitle.text = edocName
        
        scoreLabel.text = detailJSON!["sum"].stringValue
        
        let remark = detailJSON!["remarktext"].stringValue
        if remark == "" {
            remarkLabel.text = detailJSON!["status"].stringValue
        } else {
            remarkLabel.text = "\(detailJSON!["status"].stringValue) (\(remark))"
        }
        remarkLabel.textColor = self.colorFromRGB(rgbString: detailJSON!["statuscolor"].stringValue)
        
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        myTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        loadDetail(withLoadingHUD: true)
    }
    
    func loadDetail(withLoadingHUD:Bool) {
        let parameters:Parameters = ["noti_id":detailID!]
        print(parameters)
        loadRequest(method:.get, apiName:"edocument/getprobationdetail", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS PROBATION RESULT\(json)")
                
                self.scoreJSON = json["data"][0]["probation"][0]["evaluate"]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension ProbationDetail: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (scoreJSON != nil) {
            return scoreJSON!.count+2//Score + User&Head
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = self.detailJSON!
        let scoreArray = self.scoreJSON![indexPath.row-1]
        var cell = LeaveDetail_Cell()
        
        let userCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_User", for: indexPath) as! LeaveDetail_Cell
        let standardCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Standard", for: indexPath) as! LeaveDetail_Cell
        let headCell = tableView.dequeueReusableCell(withIdentifier: "LeaveDetail_Head", for: indexPath) as! LeaveDetail_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        switch indexPath.row {
        case 0://User Cell
            cell = userCell
            cell.cellImage.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = cellArray["empname"].stringValue
            cell.cellPosition.text = cellArray["empposition"].stringValue
//            cell.cellStatus.text = "\(cellArray["status"].stringValue)\n\(cellArray["remarktext"].stringValue)"
//            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            DispatchQueue.main.async {
                cell.cellBg.roundCorners(corners: [.topLeft,.topRight], radius: 15)
            }
            
        case scoreJSON!.count+1://Last Head Cell
            cell = headCell
            cell.cellImage.sd_setImage(with: URL(string:cellArray["headphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellName.text = cellArray["headname"].stringValue
            cell.cellPosition.text = cellArray["headposition"].stringValue
            
//            cell.cellStatus.text = cellArray["status_text"].stringValue
            cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
            
            cell.cellReason.delegate = self
            cell.cellReason.contentInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
            cell.cellReason.contentOffset = CGPoint(x: 0, y: 0)
            cell.cellReason.text = cellArray["reason"].stringValue
            //cell.cellReason.textColor = UIColor.lightGray
            
            DispatchQueue.main.async {
                cell.cellBg.roundCorners(corners: [.bottomRight,.bottomLeft], radius: 15)
            }
            cell.separatorInset = hideSeperator
            
        default://Score Cell
            cell = standardCell
            cell.cellTitle.text = "\(indexPath.row).\(scoreArray["name"].stringValue)"
            cell.cellDescription.text = "\(scoreArray["value"].stringValue) \("PROBATION_SCORE".localized())"
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProbationDetail: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
    }
}
