//
//  CouponList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 8/2/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class CouponList: UIViewController  {
    
    var couponJSON:JSON?
    var couponTab:couponTab?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadCoupon(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MY COUPON")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
    }
    
    func loadCoupon(withLoadingHUD:Bool) {
        var parameters:Parameters = [:]//valid,used,expired
        switch couponTab {
        case .valid :
            parameters = ["type":"valid"]
        case .used:
            parameters = ["type":"used"]
        case .expired:
            parameters = ["type":"expired"]
        default:
            break
        }
        loadRequest(method:.get, apiName:"reward/getredeamlog", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS COUPON\(json)")
                
                self.couponJSON = json["data"][0]["redeamlog"]
                
                self.myCollectionView.reloadData()
                
                if self.couponJSON!.count > 0
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

extension CouponList: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (couponJSON != nil) {
            return couponJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.couponJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LeaveHistory_Cell", for: indexPath) as! LeaveHistory_Cell
        
        cell.layer.cornerRadius = 15
        cell.setRoundAndShadow()
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["icon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellTitle.text = cellArray["desc"].stringValue
        cell.cellDate.text = cellArray["valid"].stringValue
        cell.cellSentDate.text = cellArray["date"].stringValue
        
        switch couponTab {
        case .valid :
            cell.cellStatus.text = "Use now"
            cell.cellStatus.textColor = .textPointGold
            cell.backgroundColor = .white
        case .used:
            cell.cellImage.alpha = 0.6
            cell.cellStatus.text = "Used"
            cell.cellStatus.textColor = .textGray
            cell.backgroundColor = .white
        case .expired:
            cell.cellImage.alpha = 0.6
            cell.cellStatus.text = "Expired"
            cell.cellStatus.textColor = .textGray
            cell.backgroundColor = .buttonDisable
        default:
            break
        }
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension CouponList: UICollectionViewDelegateFlowLayout {    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width-8 , height:90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 20, left: 0, bottom: 20, right: 0) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UICollectionViewDelegate

extension CouponList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.couponJSON![indexPath.item]

        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
        switch couponTab {
        case .valid :
            vc.mode = .mycoupon
        case .used:
            vc.mode = .used
        case .expired:
            vc.mode = .expired
        default:
            break
        }
        vc.rewardID = cellArray["id"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
}

