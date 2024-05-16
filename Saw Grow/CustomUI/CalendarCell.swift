//
//  CalendarCell.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 15/12/2564 BE.
//

import UIKit

class CalendarCell_Normal: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellWeekDay: UILabel!
    
    @IBOutlet var cellTimeLine: UIView!
    @IBOutlet var cellDot: UIView!
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellTime: UILabel!
    
    @IBOutlet var cellRemark: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}

class CalendarCell_Event: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellWeekDay: UILabel!
    
    @IBOutlet var cellTimeLine: UIView!
    @IBOutlet var cellTab: UIView!
    @IBOutlet var cellBg: UIView!
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}

class CalendarCell_Header: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellTimeLine: UIView!
    @IBOutlet var cellTab: UIView!
    @IBOutlet var cellBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}

class CalendarCell_Mood: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellWeekDay: UILabel!
    
    @IBOutlet var cellTimeLine: UIView!
    @IBOutlet var cellDot: UIView!
    
    @IBOutlet var cellMoodBgView: UIView!
    @IBOutlet var cellMoodIcon: UIImageView!
    @IBOutlet var cellMoodTitle: UILabel!
    @IBOutlet var cellMoodAttach: UIButton!
    @IBOutlet var cellMoodComment: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}
