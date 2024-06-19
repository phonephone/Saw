//
//  ApproveMenu.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum approveType {
    case leave
    case attendance
    case shift
    case ot
    case edocument
    case reimburse
}

class ApproveMenu: UIViewController {
    
    var approveJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("APPROVE MENU")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadMenu() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"workflow/getapprovalmenu", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS APPROVE MENU\(json)")
                
                self.approveJSON = json["data"][0]["approvalmenu"]
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension ApproveMenu: UICollectionViewDataSource {
    
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
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ApproveMenu_Cell", for: indexPath) as! ApproveMenu_Cell
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellTitle.text = cellArray[menuNameKey()].stringValue
        //cell.cellImage.image = menu[indexPath.row].icon
        //cell.cellTitle.text = menu[indexPath.row].title
        
        cell.cellAlert.text = cellArray["notification"].stringValue
        cell.cellAlert .layer.cornerRadius = cell.cellAlert.frame.size.height/2
        cell.cellAlert.layer.masksToBounds = true
        
        if cell.cellAlert.text == "0" {
            cell.cellAlert.isHidden = true
        }
        else{
            cell.cellAlert.isHidden = false
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension ApproveMenu: UICollectionViewDelegateFlowLayout {

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
        return CGSize(width: (viewWidth/2)-10 , height:100)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UICollectionViewDelegate

extension ApproveMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = self.approveJSON![indexPath.item]
        
        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "Approve") as! Approve
        
        switch cellArray["menu_key_id"].stringValue {
        case "APPROVAL_LEAVE":
            vc.approveType = .leave
            self.navigationController!.pushViewController(vc, animated: true)
        case "APPROVAL_ATTENDANCE":
            vc.approveType = .attendance
            self.navigationController!.pushViewController(vc, animated: true)
        case "APPROVAL_OT":
            vc.approveType = .ot
            self.navigationController!.pushViewController(vc, animated: true)
        case "APPROVAL_EDOCUMENT":
            vc.approveType = .edocument
            self.navigationController!.pushViewController(vc, animated: true)
        case "APPROVAL_SWAP_TIME":
            vc.approveType = .shift
            self.navigationController!.pushViewController(vc, animated: true)
        case "APPROVAL_REIM":
            vc.approveType = .reimburse
            self.navigationController!.pushViewController(vc, animated: true)
            
        default:
            showComingSoon()
            break
        }
        
//        let cellArray = self.leaveJSON![indexPath.item]
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! Profile
//        vc.userID = cellArray["user_id"].stringValue
//        self.navigationController!.pushViewController(vc, animated: true)
    }
}
