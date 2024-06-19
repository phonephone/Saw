//
//  DirectoryFavorite.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 17/11/2564 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class DirectoryFavorite: UIViewController, UITextFieldDelegate {
    
    var favoriteJSON:JSON?
    var allJSON:JSON?
    var directoryJSON:JSON?
    var directoryAllJSON:JSON?
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("FAVORITE")
        
        loadFavorite()
        
        // CollectionView
        directoryCollectionView.delegate = self
        directoryCollectionView.dataSource = self
        directoryCollectionView.backgroundColor = .clear
        directoryCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        //let layout = self.directoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout
        //layout?.sectionHeadersPinToVisibleBounds = true
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func loadFavorite() {
        let parameters:Parameters = ["group":"favorite"]
        loadRequest(method:.get, apiName:"auth/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS A-Z\(json)")
                
                self.favoriteJSON = json["data"][0]["profile"]
                self.directoryJSON = self.favoriteJSON
                
                self.allJSON = json["data"][0]["all"]
                self.directoryAllJSON = self.allJSON
                
                self.directoryCollectionView.reloadData()
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
            self.directoryJSON = self.favoriteJSON
            self.directoryAllJSON = self.allJSON
        }
        else{
            let filteredJSON = self.favoriteJSON!.arrayValue.filter({ (json) -> Bool in
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
        directoryCollectionView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension DirectoryFavorite: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (directoryJSON != nil) {
            if section == 0 {
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
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DirectoryHeader_Cell", for: indexPath) as? DirectoryHeader_Cell
        {
            if indexPath.section == 0 {
                headerCell.cellTitleAlphabet.text = "DIRECTORY_FAVORITE_Table_Header1".localized()
            }
            else{
                headerCell.cellTitleAlphabet.text = "DIRECTORY_FAVORITE_Table_Header2".localized()
            }
            return headerCell
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Directory_Cell", for: indexPath) as! Directory_Cell
        
        let cellArray : JSON
        
        if indexPath.section == 0 {
            cellArray = self.directoryJSON![indexPath.item]
            cell.cellBtnStar.setImage(UIImage(named: "directory_star_on"), for: .normal)
        }
        else{
            cellArray = self.directoryAllJSON![indexPath.item]
            
            if cellArray["favoritestaus"] == "1" {
                cell.cellBtnStar.setImage(UIImage(named: "directory_star_on"), for: .normal)
            }
            else{
                cell.cellBtnStar.setImage(UIImage(named: "directory_star_off"), for: .normal)
            }
        }
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        cell.cellBtnStar.isHidden = false
        cell.cellBtnStar.addTarget(self, action: #selector(starClick(_:)), for: .touchUpInside)
        
        if cellArray["myaccount"] == "1" {
            cell.cellBtnStar.isHidden = true
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension DirectoryFavorite: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 50)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        if section == 0 {
            return UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
        }
        else{
            return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width
        //let viewHeight = collectionView.frame.height
        
        return CGSize(width: viewWidth , height:60)
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

extension DirectoryFavorite: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray : JSON
        
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
        
        if indexPath.section == 0 {
            cellArray = self.directoryJSON![indexPath.item]
            vc.userID = cellArray["user_id"].stringValue
        }
        else{
            cellArray = self.directoryAllJSON![indexPath.item]
            vc.userID = cellArray["user_id"].stringValue
        }
        vc.whoMode = .Other
        
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func starClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = directoryCollectionView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        print("Star \(indexPath.section) - \(indexPath.item)")
        
        if indexPath.section == 0 {
            let cellArray = self.directoryJSON![indexPath.item]
            editFavorite(action: "delete", userID:cellArray["user_id"].stringValue)
        }
        else{
            //sender.setImage(UIImage(named: "directory_star_on"), for: .normal)
            let cellArray = self.directoryAllJSON![indexPath.item]
            
            if cellArray["favoritestaus"] == "1" {
                editFavorite(action: "delete", userID:cellArray["user_id"].stringValue)
            }
            else{
                editFavorite(action: "add", userID:cellArray["user_id"].stringValue)
            }
        }
    }
    
    func editFavorite(action:String, userID:String) {
        
        let parameters:Parameters = ["uid":userID, "action":action]
        loadRequest(method:.post, apiName:"auth/setuserfavorite", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS A-Z\(json)")
                
                self.favoriteJSON = json["data"][0]["profile"]
                self.directoryJSON = self.favoriteJSON
                
                self.allJSON = json["data"][0]["all"]
                self.directoryAllJSON = self.allJSON
                
                self.filterJSON(searchText: self.searchField.text!)
                
                self.directoryCollectionView.reloadData()
            }
        }
    }
}
