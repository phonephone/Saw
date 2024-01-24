//
//  Leave.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 25/11/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum leaveTab {
    case request
    case status
    case history
}

class Leave: UIViewController {
    
    var dateFromCalendar:Date?
    
    var leaveTab:leaveTab?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var requestBtn: MyButton!
    @IBOutlet weak var statusBtn: MyButton!
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
        print("LEAVE")
        
        if leaveTab != nil {
            switch leaveTab {
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
        clearSegmentBtn(button: statusBtn)
        clearSegmentBtn(button: historyBtn)
        
        setSegmentBtn(button: sender)
        
        switch sender.tag {
        case 1:
            setTab(tab: .request)
        case 2:
            setTab(tab: .status)
        case 3:
            setTab(tab: .history)
        default:
            break
        }
    }
    
    func setTab(tab:leaveTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: LeaveRequest.classForCoder())||vc.isKind(of: LeaveStatus.classForCoder())||vc.isKind(of: LeaveHistory.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveRequest") as! LeaveRequest
            vc.dateFromCalendar = dateFromCalendar
            embed(vc, inView: bottomView)
            
        case .status:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveStatus") as! LeaveStatus
            embed(vc, inView: bottomView)
            
        case .history:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "LeaveHistory") as! LeaveHistory
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
