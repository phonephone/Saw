//
//  AlertViewSlideController.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 30/3/2566 BE.
//

import UIKit
import MTSlideToOpen

class AlertViewSlideController : UIViewController, MTSlideToOpenDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slideView: MTSlideToOpenView!
    
    var alertTitle = String()
    var slideTitle = String()
    
    var buttonAction: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        slideView.delegate = self
        slideView.labelText = slideTitle
        slideView.textFont = .Roboto_Regular(ofSize: 17)
        slideView.textColor = .textDarkGray
        slideView.showSliderText = true
        slideView.thumnailImageView.image = UIImage(named: "slider")
        slideView.thumnailImageView.layer.masksToBounds = true
        slideView.thumnailImageView.layer.borderWidth = 3
        slideView.thumnailImageView.layer.borderColor = UIColor.white.cgColor
        slideView.sliderCornerRadius = 25
        slideView.sliderViewTopDistance = 0
        slideView.backgroundColor = .clear
        slideView.slidingColor = .white
        slideView.sliderBackgroundColor = .buttonDisable
    }
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        //print("Slide completed!");
        dismiss(animated: true)
        buttonAction?()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}

