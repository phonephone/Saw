//
//  Ranking.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 27/4/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum rankingTab {
    case all
    case monthly
}

class Ranking: UIViewController {
    
    var rankingTab:rankingTab?
    
    var isSuperAdmin:Bool?
    var companyJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var allBtn: MyButton!
    @IBOutlet weak var monthlyBtn: MyButton!
    @IBOutlet weak var bottomView: UIView!
    
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
        print("RANKING")
        
        setTab(tab: .all)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        clearSegmentBtn(button: allBtn)
        clearSegmentBtn(button: monthlyBtn)
        
        setSegmentBtn(button: sender)
        
        switch sender.tag {
        case 1:
            setTab(tab: .all)
        case 2:
            setTab(tab: .monthly)
        default:
            break
        }
    }
    
    func setTab(tab:rankingTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: RankingList.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .all:
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RankingList") as! RankingList
            vc.rankingTab = .all
            vc.isSuperAdmin = isSuperAdmin
            vc.companyJSON = companyJSON
            embed(vc, inView: bottomView)
            
        case .monthly:
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RankingList") as! RankingList
            vc.rankingTab = .monthly
            vc.isSuperAdmin = isSuperAdmin
            vc.companyJSON = companyJSON
            embed(vc, inView: bottomView)
        }
    }
    
    func setSegmentBtn(button: UIButton) {
        button.backgroundColor = .themeColor
        button.setTitleColor(UIColor.white, for: .normal)
    }
    
    func clearSegmentBtn(button: UIButton) {
        button.backgroundColor = UIColor.clear
        button.setTitleColor(.textDarkGray, for: .normal)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
}
