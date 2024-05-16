//
//  Reward.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Reward: UIViewController, UIScrollViewDelegate {
    
    var menuJSON:JSON?
    var promotionJSON:JSON?
    var discountJSON:JSON?
    var profileJSON:JSON?
    
    var isSuperAdmin:Bool?
    var companyJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPoint: UILabel!
    
    @IBOutlet weak var recommendStack: UIStackView!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var menuCollectionView: UICollectionView!
    @IBOutlet weak var promotionCollectionView: UICollectionView!
    @IBOutlet weak var discountCollectionView: UICollectionView!

//    var menuImage: [UIImage] = [
//        UIImage(named: "reward_menu1.png")!,
//        UIImage(named: "reward_menu2.png")!,
//        UIImage(named: "reward_menu3.png")!,
//        UIImage(named: "reward_menu4.png")!
//    ]
//
//    var menuName: [String] = [
//        "Send Gift",
//        "Mission",
//        "Head Point",
//        "History"
//    ]
//
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
        loadReward()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.tabBarController?.setStatusBarColor()
            self.tabBarController?.tabBar.tintColor = UIColor.customThemeColor()
            headerView.setGradientBackground(mainPage:true)
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("REWARD")
        
        recommendStack.isHidden = true
        
        // CollectionView
        menuCollectionView.delegate = self
        menuCollectionView.dataSource = self
        
        promotionCollectionView.delegate = self
        promotionCollectionView.dataSource = self

        discountCollectionView.delegate = self
        discountCollectionView.dataSource = self
        
        myScrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
    }
    
    func loadReward() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"reward/gethome", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS REWARD\(json)")
                
                self.menuJSON = json["data"][0]["mainmenu"]
                self.promotionJSON = json["data"][0]["reward_banner"]
                //self.discountJSON = json["data"][0]["reward_footer"]
                
                self.profileJSON = json["data"][0]["profile"][0]
                
                self.isSuperAdmin = json["data"][0]["issuperadmin"].boolValue
                self.companyJSON = json["data"][0]["adminlist"]
                
                self.menuCollectionView.reloadData()
                self.promotionCollectionView.reloadData()
                //self.discountCollectionView.reloadData()
                
                self.userName.text = "\(self.profileJSON![self.firstNameKey()].stringValue) \(self.profileJSON![self.lastNameKey()].stringValue)"
                self.userPoint.text = json["data"][0]["point"].stringValue
                
                if self.promotionJSON!.count > 0 {
                    recommendStack.isHidden = false
                }
                else{
                    recommendStack.isHidden = true
                }
            }
        }
    }
    
    @IBAction func seeAllPromotion(_ sender: UIButton) {
        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardList") as! RewardList
        vc.mode = .promotion
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func seeAllDiscount(_ sender: UIButton) {
        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardList") as! RewardList
        vc.mode = .discount
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
}

// MARK: - UICollectionViewDataSource

extension Reward: UICollectionViewDataSource {
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
            if (promotionJSON != nil) {
                return promotionJSON!.count
            }
            else{
                return 0
            }
        }
        else {//Discount
            if (discountJSON != nil) {
                return discountJSON!.count
            }
            else{
                return 0
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        if collectionView.tag == 1 {//Menu
            
            let cellArray = self.menuJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"MenuCell", for: indexPath) as! CategoryCell
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            //cell.menuImage.setImageColor(color: .themeColor)
            cell.cellTitle.text = cellArray[menuNameKey()].stringValue
            
            return cell
        }
        else if collectionView.tag == 2 {//Promotion
            
            let cellArray = self.promotionJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"PromotionCell", for: indexPath) as! CategoryCell
            
            cell.setRoundAndShadow()
            cell.cellImage.sd_setImage(with: URL(string:cellArray["banner_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = cellArray["name_title"].stringValue
            cell.cellDescription.text = cellArray["desc"].stringValue
            
            return cell
        }
        else if collectionView.tag == 3 {//Discount
            
            let cellArray = self.discountJSON![indexPath.item]
            
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"DiscountCell", for: indexPath) as! CategoryCell
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["banner_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellTitle.text = cellArray["name_title"].stringValue
            cell.cellDescription.text = cellArray["desc"].stringValue
            
            return cell
        }
        else {
            return UICollectionViewCell()
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension Reward: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {//Menu
            return CGSize(width: 62 , height: collectionView.frame.height)
        }
        else if collectionView.tag == 2 {//Promotion
            return CGSize(width: 292 , height: collectionView.frame.height-8)
        }
        else if collectionView.tag == 3 {//Discount
            return CGSize(width: 173 , height: collectionView.frame.height)
        }
        else {
            return CGSize()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 4, left: 20, bottom: 4, right: 20) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 12
    }
}

// MARK: - UICollectionViewDelegate

extension Reward: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 1 {//Menu
            let cellArray = self.menuJSON![indexPath.item]
            
            switch cellArray["menu_key_id"].stringValue {
            case "REWARD_MAIN_SEND_GIFT":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "SendGift") as! SendGift
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "REWARD_MAIN_MISSION":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "Mission") as! Mission
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "REWARD_MAIN_HEAD_POINT":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "HeadPoint") as! HeadPoint
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "REWARD_MAIN_HISTORY":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "MissionHistory") as! MissionHistory
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "REWARD_MAIN_COUPON":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "Coupon") as! Coupon
                self.navigationController!.pushViewController(vc, animated: true)
                
            case "REWARD_MAIN_RANKING":
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "Ranking") as! Ranking
                vc.isSuperAdmin = isSuperAdmin
                vc.companyJSON = companyJSON
                self.navigationController!.pushViewController(vc, animated: true)
            
            default:
                break
            }
        }
        else if collectionView.tag == 2 {//Promotion
            let cellArray = self.promotionJSON![indexPath.item]
            
            if cellArray["reward_id"] == "0" {
                //Do nothing
            }
            else{
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
                vc.mode = .redeem
                vc.rewardID = cellArray["reward_id"].stringValue
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
        else if collectionView.tag == 3 {//Discount
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
            self.navigationController!.pushViewController(vc, animated: true)
        }
    }
}
