//
//  AlertOK.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/7/2567 BE.
//

import UIKit
import Localize_Swift

class AlertOK : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var alertTitle = String()
    var alertActionButtonColor = UIColor()
    
    var complete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        actionButton.setTitle("OK".localized(), for: .normal)
        actionButton.backgroundColor = alertActionButtonColor
    }
    
    @IBAction func didTapActionButton(_ sender: UIButton) {
        dismiss(animated: true)
        
        complete?()
    }
}



