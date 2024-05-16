//
//  WarningHead.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum warningTab {
    case request
    case status
    case history
}

class WarningHead: UIViewController {
    
    var warningTab:warningTab?
    
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
        print("WARNING HEAD")
        
        setTab(tab: .request)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        requestBtn.segmentOff()
        statusBtn.segmentOff()
        historyBtn.segmentOff()
        
        sender.segmentOn()
        
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
    
    func setTab(tab:warningTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: WarningRequest.classForCoder())||vc.isKind(of: WarningHistory.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningRequest") as! WarningRequest
            embed(vc, inView: bottomView)
            
        case .status:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHistory") as! WarningHistory
            vc.warningTab = .status
            embed(vc, inView: bottomView)
            
        case .history:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHistory") as! WarningHistory
            vc.warningTab = .history
            embed(vc, inView: bottomView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}



