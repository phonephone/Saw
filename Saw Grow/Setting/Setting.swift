//
//  Setting.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 8/8/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import LineSDK

class Setting: UIViewController {
    
    var settingJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        
        print("SETTING")
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        loadSetting()
    }
    
    func loadSetting() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getsettingmenu", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SETTIING\(json)")
                
                self.settingJSON = json["data"][0]["settingmenu"]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension Setting: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (settingJSON != nil) {
            return settingJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = SideMenuCell()
        
        let cellArray = settingJSON![indexPath.item]
        
        let keyID = cellArray["menu_key_id"].stringValue
        if keyID == "SETTING_LANGUAGE" {
            cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
            
        }
        else if keyID == "SETTING_LINE" {
            cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuSwitch", for: indexPath) as! SideMenuCell
            
            
            cell.menuSwitch.tag = indexPath.row
            cell.menuSwitch.addTarget(self, action: #selector(self.switchChanged(_:)), for: .valueChanged)
            
            if cellArray["lineid"].boolValue == true {
                cell.menuSwitch.isOn = true
            }
            else {
                cell.menuSwitch.isOn = false
            }
        }
        
        cell.menuTitle.text = cellArray[menuNameKey()].stringValue
        cell.menuImage.sd_setImage(with: URL(string:cellArray["menu_image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        //cell.menuImage.setImageColor(color: .themeColor)
        
        if indexPath.row == settingJSON!.count-1 {
            let hideSeperator = UIEdgeInsets.init(top: 0, left: 2000,bottom: 0, right: 0)
            cell.separatorInset = hideSeperator
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension Setting: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        switch self.settingJSON![indexPath.row]["menu_key_id"].stringValue {
        case "SETTING_LANGUAGE":
            let vc = UIStoryboard.settingStoryBoard.instantiateViewController(withIdentifier: "Language") as! Language
            self.navigationController!.pushViewController(vc, animated: true)
            
        case "SETTING_LINE":
            break
            
        default:
            showComingSoon()
        }
    }
    
    @objc func switchChanged(_ sender : UISwitch!){
        
        print("table row switch Changed \(sender.tag)")
        print("The switch is \(sender.isOn ? "ON" : "OFF")")
        
        if sender.isOn {
            lineAuthen()
        } else {
            loadLineLink(lineUserID:"")
        }
    }
}

extension Setting {
    // MARK: - Line login
    func lineAuthen() {
        LoginManager.shared.login(permissions: [.profile], in: self) {
            result in
            switch result {
            case .success(let loginResult):
                //print(loginResult.accessToken.value)
                if let profile = loginResult.userProfile {
                    print("User ID: \(profile.userID)")
                    print("User Display Name: \(profile.displayName)")
                    print("User Icon: \(String(describing: profile.pictureURL))")
                    
                    self.loadLineLink(lineUserID:profile.userID)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func loadLineLink(lineUserID:String) {
        let parameters:Parameters = ["lineid":lineUserID,
        ]
        loadRequest(method:.post, apiName:"auth/setlineid", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS LINE LINK\(json)")
                
                self.loadSetting()
            }
        }
    }
}
