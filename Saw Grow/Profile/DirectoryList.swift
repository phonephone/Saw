//
//  DirectoryList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 16/11/2564 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD

enum dataMode {
   case AtoZ
   case Favorite
   case Myteam
}

enum displayType {
   case List
   case Thumbnail
}

class DirectoryList: UIViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
    
    var mode:dataMode = .AtoZ
    var type:displayType = .List
    var editingList: Bool = false
    
    var atozJSON:JSON?
    var favoriteJSON:JSON?
    var myteamJSON:JSON?
    var allJSON:JSON?
    var directoryJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var sideMenuBtn: UIButton!
    @IBOutlet weak var btnAtoZ: MyButton!
    @IBOutlet weak var btnFavorite: MyButton!
    @IBOutlet weak var btnMyTeam: MyButton!
    
    @IBOutlet weak var searchField: UITextField!
    @IBOutlet weak var btnList: UIButton!
    @IBOutlet weak var btnThumbnail: UIButton!
    
    @IBOutlet weak var directoryCollectionView: UICollectionView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadDirectory()
        searchField.text = ""
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
        
        print("DIRECTORY")
        
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
        
        btnAtoZ.segmentOn()
    }
    
    func loadDirectory() {
        if mode == .AtoZ {
            let parameters:Parameters = [:]
            loadRequest(method:.get, apiName:"auth/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
                switch result {
                case .failure(let error):
                    print(error)
                    
                case .success(let responseObject):
                    let json = JSON(responseObject)
                    print("SUCCESS A-Z\(json)")
                    
                    self.allJSON = json["data"][0]["profile"]
                    self.directoryJSON = self.allJSON
                    
                    self.directoryCollectionView.reloadData()
                }
            }
        }
        else if mode == .Favorite {
            let parameters:Parameters = ["group":"favorite"]
            loadRequest(method:.get, apiName:"auth/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
                switch result {
                case .failure(let error):
                    print(error)
                    
                case .success(let responseObject):
                    let json = JSON(responseObject)
                    //print("SUCCESS Favorite\(json)")
                    
                    self.allJSON = json["data"][0]["profile"]
                    self.directoryJSON = self.allJSON
                    
                    self.directoryCollectionView.reloadData()
                }
            }
        }
        else if mode == .Myteam {
            let parameters:Parameters = ["group":"myteam"]
            loadRequest(method:.get, apiName:"auth/getdirectory", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
                switch result {
                case .failure(let error):
                    print(error)
                    
                case .success(let responseObject):
                    let json = JSON(responseObject)
                    //print("SUCCESS MyTeam\(json)")
                    
                    self.allJSON = json["data"][0]["profile"]
                    self.directoryJSON = self.allJSON
                    
                    self.directoryCollectionView.reloadData()
                }
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
            self.directoryJSON = self.allJSON
        }
        else{
            let filteredJSON = self.allJSON!.arrayValue.filter({ (json) -> Bool in
                return json["first_name"].stringValue.containsIgnoringCase(searchText)||json["last_name"].stringValue.containsIgnoringCase(searchText)||json["first_name_en"].stringValue.containsIgnoringCase(searchText)||json["last_name_en"].stringValue.containsIgnoringCase(searchText)||json["designation_name"].stringValue.containsIgnoringCase(searchText);
            })
            self.directoryJSON = JSON(filteredJSON)
            
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
    
    @IBAction func segmentSelect(_ sender: UIButton) {
        
        editingList = false
        searchField.text = ""
        
        if sender.tag == 1 {//A-Z, Favorite ,My Team
            clearSegmentBtn(button: btnAtoZ)
            clearSegmentBtn(button: btnFavorite)
            clearSegmentBtn(button: btnMyTeam)
        }
        else if sender.tag == 2 {//List , Thumbnail
            clearSegmentBtn(button: btnList)
            clearSegmentBtn(button: btnThumbnail)
        }
        
        switch sender {
        case btnAtoZ:
            sender.segmentOn()
            mode = .AtoZ
            loadDirectory()
            
        case btnFavorite:
            sender.segmentOn()
            mode = .Favorite
            loadDirectory()
            
        case btnMyTeam:
            sender.segmentOn()
            mode = .Myteam
            loadDirectory()
        
        case btnList:
            btnList.setImage(UIImage(named: "directory_list_on"), for: .normal)
            type = .List
            directoryCollectionView.reloadData()
            
        case btnThumbnail:
            btnThumbnail.setImage(UIImage(named: "directory_thumbnail_on"), for: .normal)
            type = .Thumbnail
            directoryCollectionView.reloadData()
        
        default:
            break
        }
    }
    
    func clearSegmentBtn(button: UIButton) {
        if button.tag == 1 {
            button.segmentOff()
        }
        else if button.tag == 2 {
            btnList.setImage(UIImage(named: "directory_list_off"), for: .normal)
            btnThumbnail.setImage(UIImage(named: "directory_thumbnail_off"), for: .normal)
        }
    }
    
    @IBAction func leftMenuShow(_ sender: UIButton) {
        self.sideMenuController!.revealMenu()
    }
    
}//end ViewController

// MARK: - UICollectionViewDataSource

extension DirectoryList: UICollectionViewDataSource {
    
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
            if mode == .Favorite {
                headerCell.cellTitleAlphabet.isHidden = true
                if editingList {
                    headerCell.cellBtnAdd.isHidden = true
                    headerCell.cellBtnEdit.isHidden = true
                    headerCell.cellBtnDone.isHidden = false
                }
                else
                {
                    headerCell.cellBtnAdd.isHidden = false
                    headerCell.cellBtnEdit.isHidden = false
                    headerCell.cellBtnDone.isHidden = true
                }
            }
            else
            {
                headerCell.cellBtnAdd.isHidden = true
                headerCell.cellTitleAlphabet.isHidden = false
                headerCell.cellBtnEdit.isHidden = true
                headerCell.cellBtnDone.isHidden = true
                headerCell.cellTitleAlphabet.text = "A"
            }
            headerCell.cellBtnAdd.addTarget(self, action: #selector(addClick(_:)), for: .touchUpInside)
            headerCell.cellBtnEdit.addTarget(self, action: #selector(editClick(_:)), for: .touchUpInside)
            headerCell.cellBtnDone.addTarget(self, action: #selector(doneClick(_:)), for: .touchUpInside)
            
            return headerCell
        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.directoryJSON![indexPath.item]
        
        if type == .List {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"DirectoryList_Cell", for: indexPath) as! Directory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellStatus.backgroundColor = colorFromRGB(rgbString: cellArray["empstatuscolor"].stringValue)
            
            cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
            cell.cellTitlePosition.text = cellArray["designation_name"].stringValue
            cell.cellTitleStatus.text = cellArray["empstatusdetail"].stringValue
            cell.cellTitleStatus.textColor = colorFromRGB(rgbString: cellArray["empstatuscolor"].stringValue)
            
            if editingList {
                cell.cellBtnCall.isHidden = true
                cell.cellBtnEmail.isHidden = true
                cell.cellBtnDelete.isHidden = false
            }
            else{
                cell.cellBtnCall.isHidden = false
                cell.cellBtnEmail.isHidden = false
                cell.cellBtnDelete.isHidden = true
            }
            
            cell.cellBtnCall.addTarget(self, action: #selector(callClick(_:)), for: .touchUpInside)
            cell.cellBtnEmail.addTarget(self, action: #selector(emailClick(_:)), for: .touchUpInside)
            cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
            
            if cellArray["myaccount"] == "1" {
                cell.cellBtnCall.isHidden = true
                cell.cellBtnEmail.isHidden = true
            }
            
            if cellArray["isicon"] == "1" {
                let color = colorFromRGB(rgbString: cellArray["icon_color"].stringValue)//UIColor.textPointGold
                cell.cellImage.borderColor = color
                cell.cellImage.borderWidth = 3
                
                cell.contentView.backgroundColor = colorFromRGB(rgbString: cellArray["background"].stringValue)//color.withAlphaComponent(0.2)
                cell.cellBtnCall.backgroundColor = color
                cell.cellBtnEmail.backgroundColor = color
                
                cell.cellIcon.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: nil)
                cell.cellIcon.isHidden = false
            }
            else{
                cell.cellImage.borderColor = .clear
                cell.cellImage.borderWidth = 0
                
                cell.contentView.backgroundColor = .white
                cell.cellBtnCall.backgroundColor = .themeColor
                cell.cellBtnEmail.backgroundColor = .themeColor
                
                cell.cellIcon.isHidden = true
            }
            
            return cell
        }
        else//Thumbnail
        {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"DirectoryThumb_Cell", for: indexPath) as! Directory_Cell
            
            cell.layer.cornerRadius = 15
            
            cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            cell.cellStatus.backgroundColor = colorFromRGB(rgbString: cellArray["empstatuscolor"].stringValue)
            
            cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
            cell.cellTitlePosition.text = cellArray["designation_name"].stringValue
            //cell.cellTitleStatus.text = cellArray["empstatusdetail"].stringValue
            //cell.cellTitleStatus.textColor = colorFromRGB(rgbString: cellArray["empstatuscolor"].stringValue)
            
            if editingList {
                cell.cellBtnCall.isHidden = true
                cell.cellBtnEmail.isHidden = true
                cell.cellBtnDelete.isHidden = false
            }
            else{
                cell.cellBtnCall.isHidden = false
                cell.cellBtnEmail.isHidden = false
                cell.cellBtnDelete.isHidden = true
            }
            
            cell.cellBtnCall.addTarget(self, action: #selector(callClick(_:)), for: .touchUpInside)
            cell.cellBtnEmail.addTarget(self, action: #selector(emailClick(_:)), for: .touchUpInside)
            cell.cellBtnDelete.addTarget(self, action: #selector(deleteClick(_:)), for: .touchUpInside)
            
            if cellArray["myaccount"] == "1" {
                cell.cellBtnCall.isHidden = true
                cell.cellBtnEmail.isHidden = true
            }
            
            if cellArray["isicon"] == "1" {
                
                let color = colorFromRGB(rgbString: cellArray["icon_color"].stringValue)//UIColor.textPointGold
                cell.cellImage.borderColor = color
                cell.cellImage.borderWidth = 3
                
                cell.contentView.backgroundColor = colorFromRGB(rgbString: cellArray["background"].stringValue)//color.withAlphaComponent(0.2)
                cell.cellBtnCall.backgroundColor = color
                cell.cellBtnEmail.backgroundColor = color
                
                cell.cellIcon.sd_setImage(with: URL(string:cellArray["icon_url"].stringValue), placeholderImage: nil)
                cell.cellIcon.isHidden = false
            }
            else{
                cell.cellImage.borderColor = .clear
                cell.cellImage.borderWidth = 0
                
                cell.contentView.backgroundColor = .white
                cell.cellBtnCall.backgroundColor = .themeColor
                cell.cellBtnEmail.backgroundColor = .themeColor
                
                cell.cellIcon.isHidden = true
            }
            
            return cell
        }
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension DirectoryList: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        if mode == .Favorite {
            return CGSize(width: collectionView.frame.width, height: 50)
        }
        else
        {
            return CGSize(width: collectionView.frame.width, height: 0)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width
        //let viewHeight = collectionView.frame.height
        
        if type == .List {
            return CGSize(width: viewWidth , height:88)
        }
        else{//Announcement
            return CGSize(width: (viewWidth/2)-10 , height:190)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        if type == .List {
            return 0
        }
        else{//Announcement
            return 10
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegate

extension DirectoryList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        editingList = false
        
        let cellArray = self.directoryJSON![indexPath.item]
        
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
        if cellArray["myaccount"] == "1" {
            vc.whoMode = .Me
        }
        else{
            vc.whoMode = .Other
        }
        vc.userID = cellArray["user_id"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func addClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "DirectoryFavorite") as! DirectoryFavorite
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func editClick(_ sender: UIButton) {
        editingList = true
        directoryCollectionView.reloadData()
    }
    
    @IBAction func doneClick(_ sender: UIButton) {
        editingList = false
        directoryCollectionView.reloadData()
    }
    
    @IBAction func callClick(_ sender: UIButton) {
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
        print("Call \(indexPath.item)")
        
        let cellArray = self.directoryJSON![indexPath.item]
        
        let phoneNumber = cellArray["contact_number"].stringValue
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: phoneNumber, style: .default , handler:{ (UIAlertAction)in
            if let callUrl = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(callUrl) {
                        UIApplication.shared.open(callUrl)
                    }
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
            
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        //uncomment for iPad Support
        //alert.popoverPresentationController?.sourceView = self.view
        
        self.present(alert, animated: true, completion: {
            //print("Show Action Sheet completion block")
        })
    }
    
    @IBAction func emailClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        let cell = (superview as? UICollectionViewCell)!
        let indexPath = directoryCollectionView.indexPath(for: cell)
        print("Email \(indexPath!.row)")
        
        let cellArray = self.directoryJSON![indexPath!.row]
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients([cellArray["email"].stringValue])
            //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

            present(mail, animated: true)
        } else {
            // show failure alert
        }
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        let cell = (superview as? UICollectionViewCell)!
        let indexPath = directoryCollectionView.indexPath(for: cell)
        print("Delete \(indexPath!.row)")
        
        let cellArray = self.directoryJSON![indexPath!.item]
        editFavorite(action: "delete", userID:cellArray["user_id"].stringValue)
    }
    
    func editFavorite(action:String, userID:String) {
        
        let parameters:Parameters = ["uid":userID, "action":action]
        loadRequest(method:.post, apiName:"auth/setuserfavorite", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS A-Z\(json)")
                
                self.allJSON = json["data"][0]["profile"]
                self.directoryJSON = self.allJSON
                
                self.filterJSON(searchText: self.searchField.text!)
                
                self.directoryCollectionView.reloadData()
            }
        }
    }
}
