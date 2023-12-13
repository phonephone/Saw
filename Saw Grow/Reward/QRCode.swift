//
//  QRCode.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 10/2/2565 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD

class QRCode: UIViewController {
    
    var qrJSON:JSON?
    
    @IBOutlet weak var qrTitle: UILabel!
    @IBOutlet weak var qrDate: UILabel!
    
    @IBOutlet weak var cardView: MyView!
    @IBOutlet weak var qrPic: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("QR")
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.75)

        qrTitle.text = qrJSON!["desc"].stringValue
        qrDate.text = qrJSON!["expire_date"].stringValue
        qrPic.image = generateQRCode(from: qrJSON!["redeam_url"].stringValue)
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
    
    @IBAction func back(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
