//
//  MoodDashBoard.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 2/4/2567 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class MoodDashBoard: UIViewController {
    var moodJSON:JSON?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var myScrollView: UIScrollView!
    
    var departmentPicker: UIPickerView! = UIPickerView()
    var periodPicker: UIPickerView! = UIPickerView()
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            //headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("MOOD JOURNAL")
        
        myScrollView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 50, right: 0)
        
        //        pickerSetup(picker: barPicker)
        //        barField.inputView = barPicker
        //
        //        pickerSetup(picker: graphPicker)
        //        graphField.inputView = graphPicker
        
        self.hideKeyboardWhenTappedAround()
        
    }
}
