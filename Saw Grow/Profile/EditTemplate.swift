//
//  EditTextField.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 20/2/2567 BE.
//

import Foundation
import UIKit

class EditTextField: UIView {
    
    @IBOutlet weak var editTitle: UILabel!
    @IBOutlet weak var editTextField: UILabel!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        //commonInit()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        //commonInit()
    }
    
    func commonInit(withTemplate:Int, withTextColor:UIColor){
        var viewFromXib = UIView()
        
        switch withTemplate {
        case 1:
            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate", owner: self, options: nil)![0] as! UIView
            
        case 2:
            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate2", owner: self, options: nil)![0] as! UIView
            
        default:
            viewFromXib = Bundle.main.loadNibNamed("ShareTemplate", owner: self, options: nil)![0] as! UIView
        }
        
        dateLabel.textColor = withTextColor
        
        timeTitle.textColor = withTextColor
        timeIcon.setImageColor(color: withTextColor)
        timeLabel.textColor = withTextColor
        
        distanceTitle.textColor = withTextColor
        distanceLabel.textColor = withTextColor
        distanceSuffix.textColor = withTextColor
        
        calorieTitle.textColor = withTextColor
        calorieIcon.setImageColor(color: withTextColor)
        calorieLabel.textColor = withTextColor
        
//        let viewFromXib = Bundle.main.loadNibNamed("ShareTemplate", owner: self, options: nil)![0] as! UIView
        viewFromXib.frame = self.bounds
        
        addSubview(viewFromXib)
    }
}

