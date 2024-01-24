//
//  OT.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 12/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum otTab {
    case request
    case history
}

class OT: UIViewController {
    
    var dateFromCalendar:Date?
    
    var otTab:otTab?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var requestBtn: MyButton!
    @IBOutlet weak var historyBtn: MyButton!
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
        print("ATTENDANCE")
        
        if otTab != nil {
            switch otTab {
            case .history:
                segmentClick(historyBtn)
            default:
                break
            }
        }
        else{
            setTab(tab: .request)
        }
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        clearSegmentBtn(button: requestBtn)
        clearSegmentBtn(button: historyBtn)
        
        setSegmentBtn(button: sender)
        
        switch sender.tag {
        case 1:
            setTab(tab: .request)
        case 2:
            setTab(tab: .history)
        default:
            break
        }
    }
    
    func setTab(tab:otTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: OTRequest.classForCoder())||vc.isKind(of: OTHistory.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OTRequest") as! OTRequest
            vc.dateFromCalendar = dateFromCalendar
            embed(vc, inView: bottomView)
            
        case .history:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "OTHistory") as! OTHistory
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
        self.navigationController!.popViewController(animated: true)
    }
}

