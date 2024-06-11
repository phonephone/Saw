//
//  DemoExpired.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 6/6/2567 BE.
//

import UIKit

class DemoExpired: UIViewController {
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var bottomView: UIView!
    
    @IBOutlet weak var mobileBtn: UIButton!
    @IBOutlet weak var lineBtn: UIButton!
    @IBOutlet weak var fbBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            headerView.setGradientBackground(colorTop: UIColor.themeColor, colorBottom: UIColor.themeColor)
            bottomView.setGradientBackground(colorTop: UIColor.themeColor, colorBottom: UIColor.white)
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("Demo Expired")
        
        mobileBtn.imageView!.contentMode = .scaleAspectFit
        lineBtn.imageView!.contentMode = .scaleAspectFit
        fbBtn.imageView!.contentMode = .scaleAspectFit
        emailBtn.imageView!.contentMode = .scaleAspectFit
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
