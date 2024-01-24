//
//  MoreMenu.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 17/5/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class MoreMenu: UIViewController {
    
    var moreJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadMenu()
    }
    
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
        print("MORE MENU")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadMenu() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getmoremenu", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS MORE MENU\(json)")
                
                self.moreJSON = json["data"][0]["reportmenu"]
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension MoreMenu: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        //return 1
        if (moreJSON != nil) {
            return moreJSON!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
//        if (moreJSON != nil) {
//            return moreJSON!.count
//        }
//        else{
//            return 0
//        }
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "ReportMenu_Header", for: indexPath) as? DirectoryHeader_Cell
        {
            let cellArray = self.moreJSON![indexPath.section]
            headerCell.cellTitleAlphabet.text = cellArray[menuNameKey()].stringValue
            
            return headerCell
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.moreJSON![indexPath.section]
        
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

extension MoreMenu: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 30)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 10, left: 0, bottom: 30, right: 0)
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

extension MoreMenu: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = self.moreJSON![indexPath.section]
        
        switch cellArray["menu_key_id"].stringValue {
        case "MORE_EDOCUMENT":
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocMenu") as! EDocMenu
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "MORE_WARNING":
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "Warning") as! Warning
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "MORE_WARNING_HEAD":
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHead") as! WarningHead
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "MORE_REPORT":
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportMenu") as! ReportMenu
            self.navigationController!.pushViewController(vc, animated: true)
            
        default:
            break
        }
        
//        let cellArray = self.leaveJSON![indexPath.item]
//        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Profile") as! Profile
//        vc.userID = cellArray["user_id"].stringValue
//        self.navigationController!.pushViewController(vc, animated: true)
    }
}

