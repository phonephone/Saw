//
//  SendComplete.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class SendComplete: UIViewController, UITextViewDelegate {
    
    var receiverJSON:JSON?
    var detailImage:UIImage?
    var detailPoint:String?
    var detailRemark:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var stickerImageView: UIImageView!
    
    @IBOutlet weak var pointView: UIView!
    @IBOutlet weak var pointLabel: UILabel!
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var remarkLabel: UILabel!
    
    @IBOutlet weak var submitBtn: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SEND COMPLETE")
        
        nameLabel.text = "\("STICKER_SEND_Send_To".localized()) \(receiverJSON![self.firstNameKey()].stringValue) \(receiverJSON![self.lastNameKey()].stringValue)"
        
        stickerImageView.image = detailImage
        //pointLabel.text = "+ \(String(describing: detailPoint!)) point"
        
        if detailRemark == "" {
            remarkLabel.isHidden = true
        }
        else{
            remarkLabel.isHidden = false
            remarkLabel.text = detailRemark
        }
        
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popToRootViewController(animated: true)
    }
}
