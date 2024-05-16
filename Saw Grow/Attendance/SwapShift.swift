//
//  SwapShift.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 23/1/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum swapTab {
    case request
    case response
    case history
}

class SwapShift: UIViewController {
    
    var dateFromCalendar:Date?
    var myUserID:String?
    var myName:String?
    
    var swapTab:swapTab?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var requestBtn: MyButton!
    @IBOutlet weak var responseBtn: MyButton!
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
        print("SWAP")
        
        if swapTab != nil {
            switch swapTab {
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
        requestBtn.segmentOff()
        responseBtn.segmentOff()
        historyBtn.segmentOff()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            setTab(tab: .request)
        case 2:
            setTab(tab: .response)
        case 3:
            setTab(tab: .history)
        default:
            break
        }
    }
    
    func setTab(tab:swapTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: SwapShiftRequest.classForCoder())||vc.isKind(of: SwapShiftResponse.classForCoder())||vc.isKind(of: SwapShiftHistory.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "SwapShiftRequest") as! SwapShiftRequest
            vc.dateFromCalendar = dateFromCalendar
            vc.myUserID = myUserID
            vc.myName = myName
            embed(vc, inView: bottomView)
            
        case .response:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "SwapShiftResponse") as! SwapShiftResponse
            embed(vc, inView: bottomView)
            
        case .history:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "SwapShiftHistory") as! SwapShiftHistory
            embed(vc, inView: bottomView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
