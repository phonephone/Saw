//
//  AlertService.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 30/3/2566 BE.
//

import UIKit
import SwiftyJSON

class AlertService {
    
    func alertMain(title: String, buttonTitle: String, buttonColor: UIColor, completion: @escaping () -> Void) -> AlertMain {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertMain") as! AlertMain
        
        alertVC.alertTitle = title
        alertVC.alertActionButtonTitle = buttonTitle
        alertVC.alertActionButtonColor = buttonColor
        
        alertVC.complete = completion
        
        return alertVC
    }
    
    func alertMainWithBody(title: String, body: String, buttonTitle: String, buttonColor: UIColor, completion: @escaping () -> Void) -> AlertMainBody {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertMainBody") as! AlertMainBody
        
        alertVC.alertTitle = title
        alertVC.alertBody = body
        alertVC.alertActionButtonTitle = buttonTitle
        alertVC.alertActionButtonColor = buttonColor
        
        alertVC.complete = completion
        
        return alertVC
    }
    
    func alertImageWithText(image: UIImage? = nil, urlStr: String? = "", title: String? = "", description: String? = "", completion: @escaping () -> Void) -> AlertImageWithText {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertImageWithText") as! AlertImageWithText
        
        alertVC.alertImageFile = image
        alertVC.alertImageURL = urlStr
        alertVC.alertTitle = title
        alertVC.alertDescription = description
        
        alertVC.complete = completion
        
        return alertVC
    }
    
    func alertSlide(title: String, slideTitle: String, completion: @escaping () -> Void) -> AlertSlideVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertSlideVC") as! AlertSlideVC
        
        alertVC.alertTitle = title
        alertVC.slideTitle = slideTitle
        
        alertVC.complete = completion
        
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
    
    func alertMap(title: String, lat: String, long: String, completion: @escaping () -> Void) -> AlertMapVC {
        
        let alertVC = UIStoryboard.alertStoryBoard.instantiateViewController(withIdentifier: "AlertMapVC") as! AlertMapVC
        
        alertVC.alertTitle = title
        alertVC.alertLat = lat
        alertVC.alertLong = long
        alertVC.complete = completion
        
        return alertVC
    }
}
