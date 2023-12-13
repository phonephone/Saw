//
//  LeaveStatus.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 28/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class LeaveStatus: UIViewController, UITextFieldDelegate {
    
    var leaveJSON:JSON?
    
    @IBOutlet weak var allTitle: UILabel!
    @IBOutlet weak var allUsedLabel: UILabel!
    @IBOutlet weak var allTotalLabel: UILabel!
    @IBOutlet weak var allRemainLabel: UILabel!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("LEAVE STATUS")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        loadLeave()
    }
    
    func loadLeave() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"attendance/getleavetypes", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS LEAVE\(json)")
                
                //self.allTitle.text = json["data"][0]["leavedesc"].stringValue
                self.allRemainLabel.text = json["data"][0]["allremain"].stringValue
                self.allUsedLabel.text = json["data"][0]["allleave"].stringValue
                self.allTotalLabel.text = json["data"][0]["alltotal"].stringValue
                
                self.leaveJSON = json["data"][0]["leavetypes"]
                
                self.myCollectionView.reloadData()
            }
        }
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension LeaveStatus: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (leaveJSON != nil) {
            return leaveJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.leaveJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"LeaveStatus_Cell", for: indexPath) as! LeaveStatus_Cell
        
        cell.layer.cornerRadius = 15
        
        cell.cellTitle.text = cellArray[categoryNameKey()].stringValue
        cell.cellTotal.text = cellArray["total"].stringValue
        cell.cellRemain.text = cellArray["remain"].stringValue
        
        let useFloat = cellArray["leavecount"].floatValue
        let totalFloat = cellArray["total"].floatValue
        
        cell.cellBar.progress = useFloat/totalFloat
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension LeaveStatus: UICollectionViewDelegateFlowLayout {

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
        return CGSize(width: viewWidth , height:100)
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

extension LeaveStatus: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}
