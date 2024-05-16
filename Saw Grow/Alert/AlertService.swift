//
//  AlertService.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 30/3/2566 BE.
//

import UIKit
import SwiftyJSON

class AlertService {
    
    func alert(title: String, body: String, buttonTitle: String, completion: @escaping () -> Void) -> AlertVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertVC") as! AlertVC
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.alertActionButtonTitle = buttonTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertSlide(title: String, slideTitle: String, completion: @escaping () -> Void) -> AlertSlideVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertSlideVC") as! AlertSlideVC
        
        alertVC.alertTitle = title
        alertVC.slideTitle = slideTitle
        
        alertVC.buttonAction = completion
        
        return alertVC
    }
    
    func alertMood(moodJSON: JSON, completion: @escaping () -> Void) -> AlertMoodVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertMoodVC") as! AlertMoodVC
        
        alertVC.moodJSON = moodJSON
        alertVC.complete = completion
        
        return alertVC
    }
    
    func alertMoodReport(moodJSON: JSON, completion: @escaping () -> Void) -> AlertMoodReportVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertMoodReportVC") as! AlertMoodReportVC
        
        alertVC.moodJSON = moodJSON
        alertVC.complete = completion
        
        return alertVC
    }
}
