//
//  AlertSlideVC.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 28/3/2567 BE.
//

import UIKit
import MTSlideToOpen

class AlertSlideVC : UIViewController, MTSlideToOpenDelegate {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var slideView: MTSlideToOpenView!
    
    var alertTitle = String()
    var slideTitle = String()
    
    var complete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print(alertTitle)
        setupView()
    }
    
    func setupView() {
        titleLabel.text = alertTitle
        slideView.delegate = self
        slideView.labelText = slideTitle
        slideView.textFont = .Kanit_Medium(ofSize: 15)
        slideView.textColor = .textDarkGray
        slideView.showSliderText = true
        slideView.thumnailImageView.image = UIImage(named: "slider")
        slideView.thumnailImageView.backgroundColor = .clear
//        slideView.thumnailImageView.layer.masksToBounds = true
//        slideView.thumnailImageView.layer.borderWidth = 3
//        slideView.thumnailImageView.layer.borderColor = UIColor.white.cgColor
        slideView.sliderViewTopDistance = 0
        slideView.sliderCornerRadius = 28
        slideView.backgroundColor = .clear
        slideView.slidingColor = .buttonRed
        slideView.sliderBackgroundColor = .white
        slideView.sliderHolderView.layer.borderWidth = 2
        slideView.sliderHolderView.layer.borderColor = UIColor.buttonRed.cgColor
    }
    
    func mtSlideToOpenDelegateDidFinish(_ sender: MTSlideToOpenView) {
        //print("Slide completed!");
        dismiss(animated: true)
        complete?()
    }
    
    @IBAction func didTapCancel(_ sender: UIButton) {
        dismiss(animated: true)
    }
}


