//
//  AlertService.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 30/3/2566 BE.
//

import UIKit

class AlertService {
    
    func alert(title: String, body: String, buttonTitle: String, completion: @escaping () -> Void) -> AlertViewController {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertViewController
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.alertActionButtonTitle = buttonTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertSlide(title: String, slideTitle: String, completion: @escaping () -> Void) -> AlertViewSlideController {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVCSlide") as! AlertViewSlideController
        
        alertVC.alertTitle = title
        alertVC.slideTitle = slideTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
}
