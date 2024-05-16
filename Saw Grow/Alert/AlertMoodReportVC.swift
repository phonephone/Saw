//
//  AlertMoodReportVC.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/4/2567 BE.
//

import UIKit
import SwiftyJSON
import SDWebImage

class AlertMoodReportVC : UIViewController {
    
    var moodJSON:JSON?
    
    @IBOutlet weak var dateLabel: UILabel!
    
    @IBOutlet weak var attachStack: UIStackView!
    @IBOutlet weak var attachImage: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var actionButton: UIButton!
    
    var complete: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupView()
    }
    
    func setupView() {
        //        dateLabel.text = moodJSON!["xxx"].stringValue
        //        attachImage.sd_setImage(with: URL(string:moodJSON!["xxx"].stringValue), placeholderImage: nil)
        //        titleLabel.text = moodJSON!["xxx"].stringValue
        //        descriptionLabel.text = moodJSON!["xxx"].stringValue
        //actionButton.setTitle(alertActionButtonTitle, for: .normal)
        //attachStack.isHidden = true
    }
    
    @IBAction func didTapDone(_ sender: UIButton) {
        dismiss(animated: true)
        complete?()
    }
}


