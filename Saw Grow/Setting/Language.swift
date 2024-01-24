//
//  Language.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 8/8/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class Language: UIViewController {
    
    var languageJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(setText), name: NSNotification.Name(LCLLanguageChangeNotification) , object: nil)
    }
    
    @objc func setText(){
        //headTitle.text = "SETTING_LANGUAGE_title".localized()
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
        
        print("LANGUAGE")
        
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = .clear
        //myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        
        loadLanguage()
    }
    
    func loadLanguage() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/getlanguagemenu", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SETTIING\(json)")
                
                self.languageJSON = json["data"][0]["settingmenu"]
                self.myTableView.reloadData()
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension Language: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (languageJSON != nil) {
            return languageJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SideMenuCell", for: indexPath) as! SideMenuCell
        
        let cellArray = languageJSON![indexPath.row]
        let currentLanguage = Localize.currentLanguage()
        
        let menuKeyID = cellArray["menu_key_id"].stringValue
        
        cell.menuImage.isHidden = true
        
        if currentLanguage == "en" {
            cell.menuTitle.text = cellArray["menu_name_en"].stringValue
            
            if menuKeyID == "LANGUAGE_ENGLISH" {
                cell.menuImage.isHidden = false
            }
        }
        if currentLanguage == "th" {
            cell.menuTitle.text = cellArray["menu_name_th"].stringValue
            
            if menuKeyID == "LANGUAGE_THAI" {
                cell.menuImage.isHidden = false
            }
        }
        if currentLanguage == "zh" {
            cell.menuTitle.text = cellArray["menu_name_zh"].stringValue
            
            if menuKeyID == "LANGUAGE_CHINESE" {
                cell.menuImage.isHidden = false
            }
        }
        
        if indexPath.row == languageJSON!.count-1 {
            let hideSeperator = UIEdgeInsets.init(top: 0, left: 2000,bottom: 0, right: 0)
            cell.separatorInset = hideSeperator
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension Language: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        let cellArray = languageJSON![indexPath.row]
        
        if cellArray["menu_key_id"].stringValue == "LANGUAGE_ENGLISH" {
            Localize.setCurrentLanguage("en")
        }
        else if cellArray["menu_key_id"].stringValue == "LANGUAGE_THAI" {
            Localize.setCurrentLanguage("th")
        }
        else if cellArray["menu_key_id"].stringValue == "LANGUAGE_CHINESE" {
            Localize.setCurrentLanguage("zh")
        }
        
        myTableView.reloadData()
        switchToHome()
    }
}
