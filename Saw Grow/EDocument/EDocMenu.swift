//
//  EDocMenu.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 17/5/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum edocType {
    case work_cert
    case salary_cert
    case warning_letter
    case payslip
    case reimburse
    case probation
}

class EDocMenu: UIViewController {
    
    var edocJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMenu()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EDOCUMENT MENU")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadMenu() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getedocumentmenu", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS EDOCUMENT MENU\(json)")
                
                self.edocJSON = json["data"][0]["reportmenu"]
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension EDocMenu: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (edocJSON != nil) {
            return edocJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.edocJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"ReportMenu_Cell", for: indexPath) as! ApproveMenu_Cell
        
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

extension EDocMenu: UICollectionViewDelegateFlowLayout {

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

extension EDocMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = self.edocJSON![indexPath.item]
        
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDoc") as! EDoc
        
        switch cellArray["menu_key_id"].stringValue {
        case "EDOC_CER":
            vc.edocType = .work_cert
            vc.edocName = cellArray[menuNameKey()].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "EDOC_CER_SALARY":
            vc.edocType = .salary_cert
            vc.edocName = cellArray[menuNameKey()].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "EDOC_PAY_SLIP":
            vc.edocType = .payslip
            vc.edocName = cellArray[menuNameKey()].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "EDOC_REIM":
            vc.edocType = .reimburse
            vc.edocName = cellArray[menuNameKey()].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "EDOC_UP_QR":
            let vc2 = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocSalaryQR") as! EDocSalaryQR
            vc2.edocName = cellArray[menuNameKey()].stringValue
            self.navigationController!.pushViewController(vc2, animated: true)
            
        case "EDOC_PROBATION":
            vc.edocType = .probation
            vc.edocName = cellArray[menuNameKey()].stringValue
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
