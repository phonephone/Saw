//
//  EmployeeCard.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 10/11/2564 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD

class EmployeeCard: UIViewController {
    
    var profileJSON:JSON?
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    
    @IBOutlet weak var cardView: MyView!
    @IBOutlet weak var qrPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //print(profileJSON!)
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
        
        self.userPic.sd_setImage(with: URL(string:self.profileJSON!["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        self.userName.text = "\(self.profileJSON![self.firstNameKey()].stringValue) \n\(self.profileJSON![self.lastNameKey()].stringValue)"
        self.userPosition.text = self.profileJSON!["designation_name"].stringValue
        
        qrPic.image = generateQRCode(from: self.profileJSON!["qrurl"].stringValue)
    }
    
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: String.Encoding.ascii)

        if let filter = CIFilter(name: "CIQRCodeGenerator") {
            filter.setValue(data, forKey: "inputMessage")
            let transform = CGAffineTransform(scaleX: 3, y: 3)

            if let output = filter.outputImage?.transformed(by: transform) {
                return UIImage(ciImage: output)
            }
        }
        return nil
    }
    
    @IBAction func scanQRClick(_ sender: UIButton) {
    }
    
    @IBAction func shareClick(_ sender: UIButton) {
        // Setting description
        //let firstActivityItem = "Test Share Button"
        
        // Setting url
        //let secondActivityItem : NSURL = NSURL(string: "https://fw.f12key.xyz/")!
        
        // If you want to use an image
        let image : UIImage = cardView.asImage()
        let activityViewController : UIActivityViewController = UIActivityViewController(
            activityItems: [image], applicationActivities: nil)
        //let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [firstActivityItem, secondActivityItem, image], applicationActivities: nil)
        
        // This lines is for the popover you need to show in iPad
        //activityViewController.popoverPresentationController?.sourceView = (sender as! UIButton)
        
        // This line remove the arrow of the popover to show in iPad
        //activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection.down
        //activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
        
        // Pre-configuring activity items
        activityViewController.activityItemsConfiguration = [
            UIActivity.ActivityType.message
        ] as? UIActivityItemsConfigurationReading
        
        // Anything you want to exclude
        activityViewController.excludedActivityTypes = [
            UIActivity.ActivityType.postToWeibo,
            //UIActivity.ActivityType.print,
            UIActivity.ActivityType.assignToContact,
            //UIActivity.ActivityType.saveToCameraRoll,
            UIActivity.ActivityType.addToReadingList,
            UIActivity.ActivityType.postToFlickr,
            UIActivity.ActivityType.postToVimeo,
            UIActivity.ActivityType.postToTencentWeibo,
            //UIActivity.ActivityType.postToFacebook
        ]
        
        activityViewController.isModalInPresentation = true
        self.present(activityViewController, animated: true, completion: nil)
    }
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}

extension UIView {

    // Using a function since `var image` might conflict with an existing variable
    // (like on `UIImageView`)
    func asImage() -> UIImage {
        if #available(iOS 10.0, *) {
            let renderer = UIGraphicsImageRenderer(bounds: bounds)
            return renderer.image { rendererContext in
                layer.render(in: rendererContext.cgContext)
            }
        } else {
            UIGraphicsBeginImageContext(self.frame.size)
            self.layer.render(in:UIGraphicsGetCurrentContext()!)
            let image = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return UIImage(cgImage: image!.cgImage!)
        }
    }
}
