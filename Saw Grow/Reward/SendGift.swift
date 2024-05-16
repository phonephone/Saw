//
//  SendGift.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class SendGift: UIViewController, UITextFieldDelegate {
    
    var recommendJSON:JSON?
    var allJSON:JSON?
    
    var directoryJSON:JSON?
    var directoryAllJSON:JSON?
    
    var senderRemain = 0
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var remainLabel: UILabel!
    
    @IBOutlet weak var recommendCollectionView: UICollectionView!
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadRecommend()
        searchField.text = ""
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
        
        print("SEND GIFT")
        
        // CollectionView
        recommendCollectionView.delegate = self
        recommendCollectionView.dataSource = self
        recommendCollectionView.backgroundColor = .clear
        recommendCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        directoryCollectionView.delegate = self
        directoryCollectionView.dataSource = self
        directoryCollectionView.backgroundColor = .clear
        directoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func loadRecommend() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"reward/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS DIRECTORY\(json)")
                
                self.recommendJSON = json["data"][0]["profile"]
                self.directoryJSON = self.recommendJSON
                
                self.allJSON = json["data"][0]["all"]
                self.directoryAllJSON = self.allJSON
                
                self.recommendCollectionView.reloadData()
                self.directoryCollectionView.reloadData()
                
                senderRemain = json["data"][0]["remain"].intValue
                self.remainLabel.text = "\("STICKER_Remain".localized()) \(json["data"][0]["remain"].stringValue) \("REWARD_Point".localized())"
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchField.resignFirstResponder()
    }
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        filterJSON(searchText: textField.text!)
    }
    
    func filterJSON(searchText:String) {
        if searchText == "" {
            self.directoryJSON = self.recommendJSON
            self.directoryAllJSON = self.allJSON
        }
        else{
            let filteredJSON = self.recommendJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText);
            })
            self.directoryJSON = JSON(filteredJSON)
            
            let filteredAllJSON = self.allJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText);
            })
            self.directoryAllJSON = JSON(filteredAllJSON)
            
            /*
             self.directoryJSON = self.allJSON!.filter {item in
             if let itemId = item["id"] {
             return itemId != nil
             }
             return false
             }
             */
        }
        recommendCollectionView.reloadData()
        directoryCollectionView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension SendGift: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (directoryJSON != nil) {
            if collectionView.tag == 1 {
                return directoryJSON!.count
            }
            else{
                return directoryAllJSON!.count
            }
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        var cell = Directory_Cell()
        
        let cellArray : JSON
        
        if collectionView.tag == 1 {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Recommend_Cell", for: indexPath) as! Directory_Cell
            cellArray = self.directoryJSON![indexPath.item]
        }
        else{
            cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Directory_Cell", for: indexPath) as! Directory_Cell
            cellArray = self.directoryAllJSON![indexPath.item]
            if cellArray["sendstatus"] == "0" {
                cell.cellBtnStar.isHidden = true
            }
            else{
                cell.cellBtnStar.isHidden = false
            }
        }
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SendGift: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        if collectionView.tag == 1 {
            return CGSize(width: 75 , height:collectionView.frame.height)
        }
        else{
            return CGSize(width: collectionView.frame.width-40 , height:60)
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
            return 10
        }
    }
}

// MARK: - UICollectionViewDelegate

extension SendGift: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        var cellArray:JSON!
        if collectionView.tag == 1 {
            cellArray = self.directoryJSON![indexPath.item]
        }
        else{
            cellArray = self.directoryAllJSON![indexPath.item]
        }
        
        if senderRemain > 0 {
            if cellArray["sendstatus"] == "0" {
                if cellArray["remain"] != "0" {
                    let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "SendSticker") as! SendSticker
                    vc.receiverJSON = cellArray
                    self.navigationController!.pushViewController(vc, animated: true)
                }
                else{
                    ProgressHUD.showError(cellArray["remaintext"].stringValue)
                }
            }
            else{
                ProgressHUD.showError("STICKER_Already_Sent".localized())
            }
        }
        else{
            ProgressHUD.showError("STICKER_Reach_Max".localized())
        }
    }
}

