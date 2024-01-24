//
//  SideMenu.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 5/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class SideMenu: UIViewController {
    
    var profileJSON : JSON?
    var menuJSON:JSON?
    var footerMenuJSON:JSON?
    
    var firstTime = true
    
    var setColor: Bool = true
    
    @IBOutlet weak var bottomView: UIView!

    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    @IBOutlet weak var userPoint: UILabel!
    @IBOutlet var sideMenuTableView: UITableView!
    
    @IBOutlet weak var contactBtn: UIButton!
    @IBOutlet weak var helpBtn: UIButton!
    @IBOutlet weak var appVersion: UILabel!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadSideMenu()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//
//        if setColor {
//            self.navigationController?.setStatusBarColor()
//            bottomView.setGradientBackground(colorTop: .white, colorBottom: UIColor.customThemeColor())
//
//            setColor = false
//        }
//    }

    override func viewDidLoad() {
        super.viewDidLoad()

        print("SIDE MENU")
        //loadSideMenu()
        
        // TableView
        self.sideMenuTableView.delegate = self
        self.sideMenuTableView.dataSource = self
        self.sideMenuTableView.backgroundColor = .clear
        self.sideMenuTableView.separatorStyle = .none

        // Register TableView Cell
        self.sideMenuTableView.register(SideMenuCell.nib, forCellReuseIdentifier: SideMenuCell.identifier)

        // Update TableView with the data
        self.sideMenuTableView.reloadData()
        
        self.appVersion.text = "V \(Bundle.main.appVersionLong) (\(Bundle.main.appBuild))"
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        tapGestureRecognizer.numberOfTapsRequired = 5
        userPic.isUserInteractionEnabled = true
        userPic.addGestureRecognizer(tapGestureRecognizer)
        
        /*
         if UIDevice().userInterfaceIdiom == .phone {
         switch UIScreen.main.nativeBounds.height {
         case 1136:
         print("iPhone 5 or 5S or 5C")
         
         case 1334:
         print("iPhone 6/6S/7/8")
         
         case 1920, 2208:
         print("iPhone 6+/6S+/7+/8+")
         
         case 1792:
         print("iPhone XR/ 11 ")
         
         case 2436:
         print("iPhone X/XS/11 Pro")
         
         case 2688:
         print("iPhone XS Max/11 Pro Max")
         
         default:
         print("Unknown")
         }
         }
         */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        if firstTime && menuJSON != nil {
//            // Set Highlighted Cell
//            self.selectDefaultMenu(rowNo:0)
//            firstTime = true//true = Always Highlight Home Menu
//        }
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer){
        //let tappedImage = tapGestureRecognizer.view as! UIImageView
        logOut()
    }
    
    func loadSideMenu() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/gethome", authorization:true, showLoadingHUD:false, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS SIDE\(json)")
                
                self.profileJSON = json["data"][0]["profile"][0]
                
                self.userPic.sd_setImage(with: URL(string:json["data"][0]["company_logo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
                self.userName.text = json["data"][0]["company_name"].stringValue
//                self.userPosition.text =  self.profileJSON!["designation_name"].stringValue
//                self.userPoint.text = "\(json["data"][0]["point"].stringValue) Points"
                
                self.contactBtn.setTitle(json["data"][0]["footermenu"][0][self.menuNameKey()].stringValue, for: .normal)
                self.helpBtn.setTitle(json["data"][0]["footermenu"][1][self.menuNameKey()].stringValue, for: .normal)
            
                self.menuJSON = json["data"][0]["leftmenu"]
                self.sideMenuTableView.reloadData()
                
                self.footerMenuJSON = json["data"][0]["footermenu"]
                
                self.deselectAll(self.sideMenuTableView)
                self.selectDefaultMenu(rowNo:0)
            }
        }
    }
    
    func selectDefaultMenu(rowNo:Int) {
        DispatchQueue.main.async {
            let defaultRow = IndexPath(row:rowNo, section: 0)
            self.sideMenuTableView.selectRow(at: defaultRow, animated: false, scrollPosition: .none)
            
            let cell = (self.sideMenuTableView.cellForRow(at: defaultRow) as? SideMenuCell)!
            cell.menuImage.setImageColor(color: UIColor.customThemeColor())
            cell.menuTitle.textColor = UIColor.customThemeColor()
        }
    }
    
    @IBAction func contactUsClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = contactBtn.titleLabel?.text//"Contact Us"
        vc.webUrlString = footerMenuJSON![0]["link_url"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func helpClick(_ sender: UIButton) {
        let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Web") as! Web
        vc.titleString = helpBtn.titleLabel?.text//"Help"
        vc.webUrlString = footerMenuJSON![1]["link_url"].stringValue
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension SideMenu: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (menuJSON != nil) {
            return menuJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if UIDevice.current.hasNotch
        {//iphone X or upper
            return 55
        }
        else{
            return 50
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuCell.identifier, for: indexPath) as? SideMenuCell else { fatalError("xib doesn't exist") }

        cell.menuImage.sd_setImage(with: URL(string:self.menuJSON![indexPath.row]["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        //cell.menuImage.setImageColor(color: UIColor.customThemeColor())
        
        cell.menuTitle.text = self.menuJSON![indexPath.row][menuNameKey()].stringValue
        
        cell.menuAlert.layer.cornerRadius = cell.menuAlert.frame.size.height/2
        cell.menuAlert.layer.masksToBounds = true
        
        if self.menuJSON![indexPath.row]["menu_key_id"].stringValue == "LEFT_HEAD_APPROVAL" {
            cell.menuAlert.isHidden = false
            cell.menuAlert.text = self.menuJSON![indexPath.row]["notification"].stringValue
            
            if cell.menuAlert.text == "0" {
                cell.menuAlert.isHidden = true
            }
            else{
                cell.menuAlert.isHidden = false
            }
        }
        else{
            cell.menuAlert.isHidden = true
        }
        
        // Highlighted color
        let myHighlight = UIView()
        myHighlight.backgroundColor = UIColor.customThemeColor()
        myHighlight.backgroundColor = myHighlight.backgroundColor!.withAlphaComponent(0.2)
        myHighlight.layer.cornerRadius = 25
        cell.selectedBackgroundView = myHighlight
        return cell
    }
}

// MARK: - UITableViewDelegate

extension SideMenu: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        let cell = (tableView.cellForRow(at: indexPath) as? SideMenuCell)!
        cell.menuImage.setImageColor(color: UIColor.customThemeColor())
        cell.menuTitle.textColor = UIColor.customThemeColor()
        
        switchMenu(menuNo:indexPath.row)
    }
    
    func switchMenu(menuNo:Int) {
        self.sideMenuController!.hideMenu()
        
        switch self.menuJSON![menuNo]["menu_key_id"].stringValue {
        case "LEFT_HOME":
            if self.sideMenuController!.contentViewController is TabBar {
                self.sideMenuController!.hideMenu()
            }
            else{
                switchToHome()
            }
            //self.selectDefaultMenu(rowNo:0)
            
        case "LEFT_MY_PROFILE":
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "Profile") as! Profile
            vc.whoMode = .Me
            vc.userID = self.profileJSON!["user_id"].stringValue
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_HEAD_APPROVAL":
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveMenu") as! ApproveMenu
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_HEAD_REPORT":
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportMenu") as! ReportMenu
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_CHANGE_PASSWORD":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "ChangePassword") as! ChangePassword
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_TUTORIAL":
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "Tutorial") as! Tutorial
            vc.mode = .later
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_SWITCH_COMPANY":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "ChangeCompany") as! ChangeCompany
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_SETTING":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Setting") as! Setting
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
//        case "LEFT_NOTFICATION_SETTING":
//            deselectAll(self.sideMenuTableView)
//
        case "LEFT_TERM_OF_SERVICES":
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "TermOfService") as! TermOfService
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_PRIVACY_POLICY":
            let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "PrivacyPolicy") as! PrivacyPolicy
            vc.agreementShow = false
            self.navigationController!.pushViewController(vc, animated: true)
            deselectAll(self.sideMenuTableView)
            
        case "LEFT_LOGOUT":
            logOut()
            
        default:
            showComingSoon()
        }
    }
    
    func deselectAll(_ tableView: UITableView) {
        for i in 0..<menuJSON!.count {
            tableView.deselectRow(at: IndexPath(row: i, section: 0), animated: true)
            
            if let cell = (tableView.cellForRow(at: IndexPath(row: i, section: 0)) as? SideMenuCell) {
                cell.menuImage.image = cell.menuImage.image!.withRenderingMode(.alwaysOriginal)
                cell.menuTitle.textColor = .textDarkGray
            }
        }
    }
}
