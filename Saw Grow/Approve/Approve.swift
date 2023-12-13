//
//  Approve.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/12/2564 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

enum approveTab {
    case request
    case history
}

class Approve: UIViewController {
    
    var approveType:approveType?
    
    @IBOutlet weak var headerTitle: UILabel!
    
    @IBOutlet weak var requestBtn: MyButton!
    @IBOutlet weak var historyBtn: MyButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("APPROVE")
        
        switch approveType {
        case .leave:
            headerTitle.text = "APPROVE_LEAVE_Header".localized()
        case .attendance:
            headerTitle.text = "APPROVE_ATTENDANCE_Header".localized()
        case .ot:
            headerTitle.text = "APPROVE_OT_Header".localized()
        case .edocument:
            headerTitle.text = "APPROVE_EDOC_Header".localized()
        case .shift:
            headerTitle.text = "APPROVE_SWAP_Header".localized()
        case .reimburse:
            headerTitle.text = "APPROVE_REIMBURSE_Header".localized()
        
        default:
            break
        }
        setTab(tab: .request)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        
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
    
    func setTab(tab:approveTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: ApproveRequest.classForCoder())||vc.isKind(of: ApproveHistory.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveRequest") as! ApproveRequest
            vc.approveType = approveType
            embed(vc, inView: bottomView)
            
        case .history:
            let vc = UIStoryboard.attendanceStoryBoard.instantiateViewController(withIdentifier: "ApproveHistory") as! ApproveHistory
            vc.approveType = approveType
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
