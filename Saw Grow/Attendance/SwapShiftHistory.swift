//
//  SwapShiftHistory.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 23/1/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class SwapShiftHistory: UIViewController  {
    
    var swapJSON:JSON?
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadLeave(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("SWAP RESPONSE")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
//        if let flowLayout = myCollectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
//              flowLayout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize
//            }
    }
    
    func loadLeave(withLoadingHUD:Bool) {
        let parameters:Parameters = ["group":"history"]
        loadRequest(method:.get, apiName:"attendance/gettimeswapstatus", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS HISTORY\(json)")
                
                self.swapJSON = json["data"][0]["timeswap"]
                
                self.myCollectionView.reloadData()
                
                if self.swapJSON!.count > 0
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

extension SwapShiftHistory: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (swapJSON != nil) {
            return swapJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.swapJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Swap_Cell", for: indexPath) as! Swap_Cell
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage1.sd_setImage(with: URL(string:cellArray["empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellImage2.sd_setImage(with: URL(string:cellArray["to_empphoto"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        cell.cellTitle.text = "\(cellArray["empname"].stringValue) \("SWAP_Response_Title".localized()) \(cellArray["to_empname"].stringValue)"
        cell.cellDate.text = "\("Sent_Date".localized())  \(cellArray["sentdate"].stringValue)"
        cell.cellRemark.text = "\("SWAP_Note".localized()) : \(cellArray["reason"].stringValue)"
        
        cell.cellStatus.text = cellArray["status"].stringValue
        cell.cellStatus.textColor = self.colorFromRGB(rgbString: cellArray["statuscolor"].stringValue)
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension SwapShiftHistory: UICollectionViewDelegateFlowLayout {

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
        return CGSize(width: viewWidth , height:160)
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

extension SwapShiftHistory: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        let cellArray = self.swapJSON![indexPath.item]
        pushToDetail(detailID: cellArray["noti_id"].stringValue)
    }
    
    func pushToDetail(detailID:String) {
        let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveDetail") as! LeaveDetail
        vc.mode = .shift
        vc.detailID = detailID
        self.navigationController!.pushViewController(vc, animated: true)
    }
}
