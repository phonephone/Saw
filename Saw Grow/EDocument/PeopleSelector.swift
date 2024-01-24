//
//  PeopleSelector.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/6/2565 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD

class PeopleSelector: UIViewController, UITextFieldDelegate {
    
    var delegate: PeopleDelegate?
    
    var directoryJSON:JSON?
    var directoryAllJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var searchField: UITextField!
    
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
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
        
        print("PEOPLE")
        
        loadPeople()
        
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
        
        print("PEOPLE SELECTOR")
    }
    
    func loadPeople() {
        let parameters:Parameters = [:]//["group":"favorite"]
        loadRequest(method:.get, apiName:"edocument/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS A-Z\(json)")
                
                self.directoryAllJSON = json["data"][0]["profile"]
                self.directoryJSON = self.directoryAllJSON
                
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
            self.directoryJSON = self.directoryAllJSON
        }
        else{
            let filteredAllJSON = self.directoryAllJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText);
            })
            self.directoryJSON = JSON(filteredAllJSON)
            
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

extension PeopleSelector: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (directoryJSON != nil) {
            return directoryJSON!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "DirectoryHeader_Cell", for: indexPath) as? DirectoryHeader_Cell
        {
            headerCell.cellTitleAlphabet.text = "Your Favorite"
            return headerCell
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"Directory_Cell", for: indexPath) as! Directory_Cell
        
        let cellArray = self.directoryJSON![indexPath.item]
        cell.layer.cornerRadius = 15
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        
        if cellArray["myaccount"] == "1" {
            cell.cellBtnStar.isHidden = true
        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension PeopleSelector: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 40, right: 0)
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

extension PeopleSelector: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        let cellArray = self.directoryJSON![indexPath.item]
        
        delegate!.selectPeople(peopleArr: cellArray)
        self.navigationController!.popViewController(animated: true)
    }
}

