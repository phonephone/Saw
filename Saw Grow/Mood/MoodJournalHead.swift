//
//  MoodJournalHead.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/4/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum moodTab {
    case mymood
    case report
}

class MoodJournalHead: UIViewController {
    
    var moodTab:moodTab?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var mymoodBtn: MyButton!
    @IBOutlet weak var reportBtn: MyButton!
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
        print("MOOD JOURNAL HEAD")
        
        if moodTab != nil {
            switch moodTab {
            case .report:
                segmentClick(reportBtn)
            default:
                break
            }
        }
        else{
            setTab(tab: .mymood)
        }
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        mymoodBtn.segmentOff()
        reportBtn.segmentOff()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            setTab(tab: .mymood)
        case 2:
            setTab(tab: .report)
        default:
            break
        }
    }
    
    func setTab(tab:moodTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: MyMood.classForCoder())||vc.isKind(of: MoodDashBoard.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .mymood:
            let vc = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MyMood") as! MyMood
            embed(vc, inView: bottomView)
            
        case .report:
            let vc = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MoodDashBoard") as! MoodDashBoard
            embed(vc, inView: bottomView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


