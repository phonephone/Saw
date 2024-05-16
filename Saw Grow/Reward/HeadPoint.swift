//
//  HeadPoint.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class HeadPoint: UIViewController, UITextFieldDelegate {
    
    var allJSON:JSON?
    
    var directoryAllJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadTeam()
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
        directoryCollectionView.delegate = self
        directoryCollectionView.dataSource = self
        directoryCollectionView.backgroundColor = .clear
        directoryCollectionView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 15, right: 0)
        
        searchField.delegate = self
        searchField.addTarget(self, action: #selector(self.textFieldDidChange(_:)),
                                  for: .editingChanged)
    }
    
    func loadTeam() {
        let parameters:Parameters = ["group":"myteam"]
        loadRequest(method:.get, apiName:"reward/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS DIRECTORY\(json)")
                
                self.allJSON = json["data"][0]["profile"]
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
            self.directoryAllJSON = self.allJSON
        }
        else{
            let filteredAllJSON = self.allJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText);
            })
            self.directoryAllJSON = JSON(filteredAllJSON)
        }
        directoryCollectionView.reloadData()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension HeadPoint: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (directoryAllJSON != nil) {
            return directoryAllJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Directory_Cell", for: indexPath) as! Directory_Cell
        let cellArray = self.directoryAllJSON![indexPath.item]
        
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        
        if cellArray["sendstatus"] == "0" {
            cell.cellBtnStar.isHidden = true
        }
        else{
            cell.cellBtnStar.isHidden = false
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension HeadPoint: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width-40 , height:60)
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

extension HeadPoint: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "SendSticker") as! SendSticker
        
        let cellArray = self.directoryAllJSON![indexPath.item]
        if cellArray["sendstatus"] == "0" {
            if cellArray["remain"] != "0" {
                vc.receiverJSON = self.directoryAllJSON![indexPath.item]
                self.navigationController!.pushViewController(vc, animated: true)
            }
            else{
                ProgressHUD.showError(cellArray["remaintext"].stringValue)
            }
        }
        else{
            ProgressHUD.showError("Already Sent Gift")
        }
    }
}
