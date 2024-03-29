//
//  TermOfService.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 16/10/2566 BE.
//

import UIKit
import ProgressHUD

class TermOfService: UIViewController, UIScrollViewDelegate {
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
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
        print("TERM")
        
        //headerTitle.text = ""
        
        myScrollView.contentInset = UIEdgeInsets(top: 30, left: 20, bottom: 30, right: 20)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


