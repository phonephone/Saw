//
//  EDoc.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/6/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum edocTab {
    case request
    case history
}

class EDoc: UIViewController {
    
    var edocTab:edocTab?
    var edocType:edocType?
    
    var edocName:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
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
        print("EDOC")
        
        headTitle.text = edocName
        
        setTab(tab: .request)
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
    
    func setTab(tab:edocTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: EDocRequest.classForCoder())||vc.isKind(of: EDocHistory.classForCoder())||vc.isKind(of: EDocSlip.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .request:
            switch edocType {
            case .payslip:
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocSlip") as! EDocSlip
                embed(vc, inView: bottomView)
                
            case .reimburse:
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocReimburse") as! EDocReimburse
                embed(vc, inView: bottomView)
                
            case .probation:
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "Probation") as! Probation
                vc.edocName = edocName
                vc.edocType = edocType
                embed(vc, inView: bottomView)
                
            default://.salary_cert ,.work_cert
                let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocRequest") as! EDocRequest
                vc.edocType = edocType
                embed(vc, inView: bottomView)
            }
            
        case .history:
            let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "EDocHistory") as! EDocHistory
            vc.edocName = edocName
            vc.edocType = edocType
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

