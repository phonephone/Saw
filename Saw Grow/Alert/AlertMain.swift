//
//  AlertMain.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/5/2567 BE.
//

import UIKit

class AlertMain : UIViewController {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var alertTitle = String()
    var alertActionButtonTitle = String()
    var alertActionButtonColor = UIColor()
    
    var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        actionButton.setTitle(alertActionButtonTitle, for: .normal)
        actionButton.backgroundColor = alertActionButtonColor
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    @IBAction func didTapActionButton(_ sender: UIButton) {
        dismiss(animated: true)
        
        buttonAction?()
    }
}


