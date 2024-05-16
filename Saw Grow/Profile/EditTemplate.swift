//
//  EditTextField.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/2/2567 BE.
//

import Foundation
import UIKit

enum templateType {
   case textField
   case switchOnOff
}

class EditTemplate: UIView {
    
    @IBOutlet weak var editTitle: UILabel!
    @IBOutlet weak var editTextField: UITextField!
    @IBOutlet weak var editSwitch: UISwitch!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //commonInit()
    }
    
    func commonInit(template:templateType){
        let view = loadViewFromNib(withTemplate: template)
        view.frame = self.bounds
        view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(view)
    }
    
    func loadViewFromNib(withTemplate:templateType) -> UIView {
        var viewFromXib = UIView()
        
        switch withTemplate {
        case .textField:
            viewFromXib = Bundle.main.loadNibNamed("EditTextField", owner: self, options: nil)![0] as! UIView
            
        case .switchOnOff:
            viewFromXib = Bundle.main.loadNibNamed("EditSwitch", owner: self, options: nil)![0] as! UIView
        }
        return viewFromXib
    }
}

