//
//  NotificationAll.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class NotificationAll: UIViewController {
    
    var notiJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadNoti(withLoadingHUD: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.tabBarController?.setStatusBarColor()
            self.tabBarController?.tabBar.tintColor = UIColor.customThemeColor()
            headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("NOTIFICATION")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadNoti(withLoadingHUD:Bool) {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getnotification", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS NOTI\(json)")
                
                self.notiJSON = json["data"]["notification"]
                
                let badgeNo = json["data"]["countnoti"].stringValue
                if badgeNo == "0" {
                    self.tabBarController!.tabBar.items!.last!.badgeValue = nil
                }
                else{
                    self.tabBarController!.tabBar.items!.last!.badgeValue = badgeNo
                }
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension NotificationAll: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (notiJSON != nil) {
            return notiJSON!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NotificationHeader_Cell", for: indexPath) as? NotificationHeader_Cell
        {
            headerCell.cellBtnReadAll.addTarget(self, action: #selector(readAllClick(_:)), for: .touchUpInside)
            headerCell.cellBtnReadAll.backgroundColor = UIColor.themeColor
            
            return headerCell
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.notiJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Notification_Cell", for: indexPath) as! Notification_Cell
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage1.sd_setImage(with: URL(string:cellArray["icon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellImage2.sd_setImage(with: URL(string:cellArray["icon2"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellTitle.text = cellArray["title"].stringValue
        cell.cellDescription.text = cellArray["description"].stringValue
        cell.cellTime.text = cellArray["sentdate"].stringValue
        cell.backgroundColor = self.colorFromRGB(rgbString: cellArray["background"].stringValue)
        
        if cellArray["flag"].stringValue == "1" {
            cell.cellImage2.isHidden = true
            cell.cellswapIcon.isHidden = true
        }
        else {
            cell.cellImage2.isHidden = false
            cell.cellswapIcon.isHidden = false
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension NotificationAll: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 50)
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

extension NotificationAll: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.notiJSON![indexPath.item]
        
        loadRead(header:cellArray["header"].stringValue, date:cellArray["date"].stringValue, noti_id:cellArray["noti_id"].stringValue, linkUrl:cellArray["link_url"].stringValue, linkTitle:cellArray["title"].stringValue, withLoadingHUD: false)
    }
    
    func loadRead(header:String ,date:String, noti_id:String, linkUrl:String, linkTitle:String, withLoadingHUD:Bool) {
        
        var parameters:Parameters = [:]
        
        if header == "All" {
            parameters = ["header":header]
        }
        else {
            parameters = ["header":header,
                          "date":date
            ]
        }
        //print(parameters)

        loadRequest(method:.post, apiName:"auth/setreadnotification", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS READ NOTI\(json)")

                if linkUrl != "" {
                    let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
                    vc.titleString = linkTitle
                    vc.webUrlString = linkUrl
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else {
                    switch header {
                    case "holiday":
                        let vc = self.tabBarController?.viewControllers![3] as! CalendarList
                        vc.goToDate = self.appDateFromString(dateStr: date, format: "yyyy-MM-dd")
                        self.tabBarController?.selectedIndex = 3
                        
                    case "leave" :
                        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Leave") as! Leave
                        vc.leaveTab = .history
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "attendance" :
                        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Attendance") as! Attendance
                        vc.attendanceTab = .history
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "ot" :
                        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OT") as! OT
                        vc.otTab = .history
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "leave_head","attendance_head","ot_head" :
                        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveDetail") as! ApproveDetail
                        vc.detailID = noti_id
                        if header == "leave_head" {
                            vc.approveType = .leave
                        } else if header == "attendance_head" {
                            vc.approveType = .attendance
                        } else if header == "ot_head" {
                            vc.approveType = .ot
                        }
                        
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "warning","warning_head" :
                        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningDetail") as! WarningDetail
                        vc.detailID = noti_id
                        if header == "warning_head" {
                            vc.warningTab = .history
                        } else {
                            vc.warningTab = .status
                        }
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "empcer","empcer_head" :
                        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocDetail") as! EDocDetail
                        vc.detailID = noti_id
                        if header == "empcer_head" {
                            vc.isHead = true
                        } else {
                            vc.isHead = false
                        }
                        self.navigationController!.pushViewController(vc, animated: true)
                        
                    case "sticker" :
                        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "MissionHistory") as! MissionHistory
                        self.navigationController!.pushViewController(vc, animated: true)
                        
    //                case "shift":
    //                    break
                        
                    default:
                        self.loadNoti(withLoadingHUD: false)
                    }
                }
            }
        }
    }
    
    @IBAction func readAllClick(_ sender: UIButton) {
        
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
            
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "NOTIFICATION_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadRead(header:"All", date: "", noti_id: "", linkUrl: "", linkTitle: "", withLoadingHUD: true)
        }))
        alert.actions.last?.titleTextColor = .themeColor
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
}

