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
    
    @IBOutlet weak var validBtn: MyButton!
    @IBOutlet weak var usedBtn: MyButton!
    @IBOutlet weak var expiredBtn: MyButton!
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("COUPON")
        
        setTab(tab: .valid)
    }
    
    @IBAction func segmentClick(_ sender: UIButton) {
        self.view.endEditing(true)
        clearSegmentBtn(button: validBtn)
        clearSegmentBtn(button: usedBtn)
        clearSegmentBtn(button: expiredBtn)
        
        setSegmentBtn(button: sender)
        
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
