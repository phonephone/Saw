//
//  Report.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 18/6/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Report: UIViewController {
    
    var reportTab:actionType?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var checkinBtn: MyButton!
    @IBOutlet weak var updateBtn: MyButton!
    @IBOutlet weak var checkoutBtn: MyButton!
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
        print("REPORT")
        
        setTab(tab: .checkIn)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        checkinBtn.segmentOff()
        updateBtn.segmentOff()
        checkoutBtn.segmentOff()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            setTab(tab: .checkIn)
        case 2:
            setTab(tab: .update)
        case 3:
            setTab(tab: .checkIn)
        default:
            break
        }
    }
    
    func setTab(tab:actionType) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: ReportDetail.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ReportDetail") as! ReportDetail
        vc.reportType = tab
        embed(vc, inView: bottomView)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}




