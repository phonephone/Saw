//
//  AlertImageWithText.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 19/6/2567 BE.
//

import UIKit
import SDWebImage

class AlertImageWithText : UIViewController {
    
    var firstTime = true
    
    @IBOutlet weak var imageHeight: NSLayoutConstraint!
    @IBOutlet weak var myImage: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var alertImageFile: UIImage?
    var alertImageURL: String!
    var alertTitle: String!
    var alertDescription: String!
    
    var complete: (() -> Void)?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if firstTime {
            setupView()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //setupView()
    }
    
    func setupView() {
        myImage.isHidden = true
        
        if let imageFile = alertImageFile {
            myImage.image = imageFile
            
            let ratio = imageFile.size.width / imageFile.size.height
            let newHeight = myImage.frame.width / ratio
            imageHeight.constant = newHeight
            myImage.isHidden = false
        }
        else if alertImageURL != "" {
            myImage.sd_setImage(with: URL(string:alertImageURL),
                                   completed: { (image, error, cacheType, url) in
                guard image != nil else {
                    return
                }
                let ratio = image!.size.width / image!.size.height
                let newHeight = self.myImage.frame.width / ratio
                self.imageHeight.constant = newHeight
                self.myImage.isHidden = false
            })
        }
        
        if alertTitle == "" {
            titleLabel.isHidden = true
        }
        else {
            titleLabel.text = alertTitle
        }
        
        
        if alertDescription == "" {
            descriptionLabel.isHidden = true
        }
        else {
            descriptionLabel.text = alertDescription
        }
        
        firstTime = false
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true)
        complete?()
    }
}



