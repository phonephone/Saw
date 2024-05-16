//
//  MoodJournal.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 28/3/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class MoodJournal: UIViewController {
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
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
        print("MOOD JOURNAL")
        
        if self.children.count > 0 {
            for vc in self.children {
                if vc.isKind(of: MyMood.classForCoder()) {
                    unEmbed(vc)
                }
            }
        }
        
        let vc = UIStoryboard.moodStoryBoard.instantiateViewController(withIdentifier: "MyMood") as! MyMood
        embed(vc, inView: bottomView)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
