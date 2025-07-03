//
//  TutorialComplete.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 21/2/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class TutorialComplete: UIViewController, UIScrollViewDelegate {
    
    var mode:tutorialMode?
    var tutorialPoint:String?
    
    var tutorialJSON:JSON?
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TUTORIAL COMPLETE")
        
        //pointLabel.text = "+\(tutorialPoint!)"
        descriptionLabel.text = "\("TUTORIAL_COMPLETE_Sub_Header_1".localized()) \(tutorialPoint!) \("TUTORIAL_COMPLETE_Sub_Header_2".localized()) "
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        loadSubmit()
    }
    
    func loadSubmit() {
        let parameters:Parameters = [:]
        
        loadRequest(method:.get, apiName:"auth/settutorial", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS TUTORIAL COMPLETE\(json)")

                //self.submitSuccess()
                if self.mode == .firstTime {
                    self.switchToHome()
                }
                else{
                    self.navigationController!.popToRootViewController(animated: true)
                }
            }
        }
    }
}
