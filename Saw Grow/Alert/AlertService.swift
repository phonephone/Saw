//
//  AlertService.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 30/3/2566 BE.
//

import UIKit

class AlertService {
    
    func alert(title: String, body: String, buttonTitle: String, completion: @escaping () -> Void) -> AlertVC {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.alertActionButtonTitle = buttonTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertSlide(title: String, slideTitle: String, completion: @escaping () -> Void) -> AlertSlideVC {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertSlideVC") as! AlertSlideVC
        
        alertVC.alertTitle = title
        alertVC.slideTitle = slideTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertMood(completion: @escaping () -> Void) -> AlertMoodVC {
        
        let storyboard = UIStoryboard(name: "Alert", bundle: .main)
        let alertVC = storyboard.instantiateViewController(withIdentifier: "AlertMoodVC") as! AlertMoodVC
        
        alertVC.complete = completion
        
        return alertVC
    }
}
