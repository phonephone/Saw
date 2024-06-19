//
//  Warning.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/6/2565 BE.
//

import UIKit

class Warning: UIViewController {
    
    @IBOutlet weak var bottomView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("WARNING EMPLOYEE")
        
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "WarningHistory") as! WarningHistory
        vc.warningTab = .status
        embed(vc, inView: bottomView)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}


