//
//  RewardList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 18/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum rewardMode {
    case promotion
    case discount
}

class RewardList: UIViewController, UIScrollViewDelegate {
    
    var menuJSON:JSON?
    var rewardJSON:JSON?
    
    var selectedMenu = 0
    
    var mode:rewardMode?
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var myCollectionView: UICollectionView!
    
//    var promotionImage: [UIImage] = [
//        UIImage(named: "demo_promotion1.png")!,
//        UIImage(named: "demo_promotion2.png")!,
//        UIImage(named: "demo_promotion3.png")!,
//        UIImage(named: "demo_promotion4.png")!,
//        UIImage(named: "demo_promotion5.png")!,
//    ]
//
//    var discountImage: [UIImage] = [
//        UIImage(named: "demo_discount1.png")!,
//        UIImage(named: "demo_discount2.png")!,
//        UIImage(named: "demo_discount3.png")!,
//        UIImage(named: "demo_discount4.png")!,
//    ]
//
//    var discountName: [String] = [
//        "McDonald’s",
//        "Dunkin’",
//        "Sizzler",
//        "The Coffee Club"
//    ]
//
//    var discountDescription: [String] = [
//        "ส่วนลด 30 บาท เมื่อชำระขั้นต่ำ 200 บาท",
//        "เอาใจสายหวานเมื่อซื้อ Dunkin’ 4 ชิ้น แถม 2 ",
//        "รับส่วนลด 40 บาท เมื่อชำระขั้นต่ำ 400 บาท",
//        "รับส่วนลด 20 บาท เมื่อชำระขั้นต่ำ 150 บาท"
//    ]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REWARD LIST")
        
        // CollectionView
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        //myCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        
        loadReward(categoryID:"")
    }
    
    func loadReward(categoryID:String) {
        let parameters:Parameters = ["q":categoryID]
        loadRequest(method:.get, apiName:"reward/getrewardlist", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS REWARD LIST\(json)")
                
                self.menuJSON = json["data"][0]["category"]
                self.rewardJSON = json["data"][0]["reward_banner"]
                self.menuCollectionView.reloadData()
                self.myCollectionView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension RewardList: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        
        if collectionView.tag == 1 {//Menu
            if (menuJSON != nil) {
                return menuJSON!.count
            }
            else{
                return 0
            }
        }
        if collectionView.tag == 2 {//Promotion
            if (rewardJSON != nil) {
                return rewardJSON!.count
            }
            else{
                return 0
            }
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        if collectionView.tag == 1 {//Menu
            let cellArray = self.menuJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MenuCell", for: indexPath) as! CategoryCell
            
            if indexPath.item == selectedMenu{
                cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url_alt"].stringValue), placeholderImage: UIImage(named: ""))
            }
            else{
                cell.cellImage.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: UIImage(named: ""))
            }
            //cell.menuImage.setImageColor(color: .themeColor)
            cell.cellTitle.text = cellArray["category_name"].stringValue
            
            return cell
        }
        else if collectionView.tag == 2 {//Promotion
            let cellArray = self.rewardJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PromotionCell", for: indexPath) as! CategoryCell
            cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["banner_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = cellArray["name_title"].stringValue
            cell.cellDescription.text = cellArray["desc"].stringValue
            return cell
        }
        else{
            return UICollectionViewCell()
        }
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension RewardList: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {//Menu
            return CGSize(width: 93 , height: collectionView.frame.height)
        }
        else if collectionView.tag == 2 {//Promotion
            return CGSize(width: collectionView.frame.width-8 , height: 254)
        }
        else {
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        if collectionView.tag == 1 {//Menu
            return UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20) //.zero
        }
        else {//Promotion
            return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0) //.zero
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 1 {//Menu
            return 0
        }
        else {//Promotion
            return 20
        }
    }
}

// MARK: - UICollectionViewDelegate

extension RewardList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        if collectionView.tag == 1 {//Menu
            
            selectedMenu = indexPath.item
            menuCollectionView.reloadData()
            
            let cellArray = self.menuJSON![indexPath.item]
            loadReward(categoryID:cellArray["category_id"].stringValue)
            
        }
        else if collectionView.tag == 2 {//Promotion
            let cellArray = self.rewardJSON![indexPath.item]
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
            vc.mode = .redeem
            vc.rewardID = cellArray["reward_id"].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
}

