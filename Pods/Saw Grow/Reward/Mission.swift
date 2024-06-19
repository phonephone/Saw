//
//  Mission.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class Mission: UIViewController, UITextFieldDelegate {
    
    var routineJSON:JSON?
    var missionJSON:JSON?
    
    @IBOutlet weak var routinePointLabel: UILabel!
    @IBOutlet weak var missionPointLabel: UILabel!
    
    @IBOutlet weak var routineCollectionView: UICollectionView!
    @IBOutlet weak var missionCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadMission()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("MISSION")
        
        // CollectionView
        routineCollectionView.delegate = self
        routineCollectionView.dataSource = self
        routineCollectionView.backgroundColor = .clear
        routineCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        missionCollectionView.delegate = self
        missionCollectionView.dataSource = self
        missionCollectionView.backgroundColor = .clear
        missionCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
    }
    
    func loadMission() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"reward/getmission", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS DIRECTORY\(json)")
                
                self.routineJSON = json["data"][0]["head"]
                self.missionJSON = json["data"][0]["list"]
                
                self.routineCollectionView.reloadData()
                self.missionCollectionView.reloadData()
                
                self.routinePointLabel.text = "\(json["data"][0]["head_point"].stringValue) \("REWARD_Point".localized())"
                self.missionPointLabel.text = "\(json["data"][0]["reward_point"].stringValue) \("REWARD_Point".localized())"
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension Mission: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if routineJSON != nil {
            if collectionView.tag == 1 {
                return routineJSON!.count
            }
            else{
                return missionJSON!.count
            }
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = MissionCell()
        
        let cellArray : JSON
        
        if collectionView.tag == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Routine_Cell", for: indexPath) as! MissionCell
            cellArray = self.routineJSON![indexPath.item]
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Mission_Cell", for: indexPath) as! MissionCell
            cellArray = self.missionJSON![indexPath.item]
        }
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["icon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitle.text = cellArray["name"].stringValue
        cell.cellPoint.text = cellArray["rewardpoint"].stringValue
        //cell.backgroundColor = colorFromRGB(rgbString: cellArray["background"].stringValue)
        
        if cellArray["status"] == "0" {
            cell.cellPointBg.backgroundColor = .lightGray.withAlphaComponent(0.2)
            cell.cellPoint.textColor = .textDarkGray
        }
        else{
            cell.cellPointBg.backgroundColor = .buttonGreen
            cell.cellPoint.textColor = .white
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension Mission: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {
            return CGSize(width: 110 , height:collectionView.frame.height)
        }
        else{
            return CGSize(width: collectionView.frame.width-40 , height:90)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        if collectionView.tag == 1 {
            return 20
        }
        else{
            return 15
        }
    }
}

// MARK: - UICollectionViewDelegate

extension Mission: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
    }
}

