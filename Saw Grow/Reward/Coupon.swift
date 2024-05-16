//
//  Coupon.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 8/2/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

enum couponTab {
    case valid
    case used
    case expired
}

class Coupon: UIViewController {
    
    var couponTab:couponTab?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var validBtn: MyButton!
    @IBOutlet weak var usedBtn: MyButton!
    @IBOutlet weak var expiredBtn: MyButton!
    @IBOutlet weak var bottomView: UIView!
    
    var blurView : UIVisualEffectView!
    
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
        print("COUPON")
        
        setTab(tab: .valid)
        
        blurView = blurViewSetup()
        self.view.addSubview(blurView)
        self.view.sendSubviewToBack(blurView)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        validBtn.segmentOff()
        usedBtn.segmentOff()
        expiredBtn.segmentOff()
        
        sender.segmentOn()
        
        switch sender.tag {
        case 1:
            setTab(tab: .valid)
        case 2:
            setTab(tab: .used)
        case 3:
            setTab(tab: .expired)
        default:
            break
        }
    }
    
    func setTab(tab:couponTab) {
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: CouponList.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        switch tab {
        case .valid:
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "CouponList") as! CouponList
            vc.couponTab = .valid
            embed(vc, inView: bottomView)
            
        case .used:
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "CouponList") as! CouponList
            vc.couponTab = .used
            embed(vc, inView: bottomView)
            
        case .expired:
            let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "CouponList") as! CouponList
            vc.couponTab = .expired
            embed(vc, inView: bottomView)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
}
