//
//  MyCell.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 5/11/2564 BE.
//

import UIKit

class SideMenuCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var menuImage: UIImageView!
    @IBOutlet var menuTitle: UILabel!
    @IBOutlet var menuAlert: UILabel!
    @IBOutlet var menuSwitch: UISwitch!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
        
        // Title
        //self.menuTitle.textColor = .white
    }
}

class ProfileCell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var profileTitle: UILabel!
    @IBOutlet var profileDetail: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class CategoryCell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class AnnouncementCell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}

class DirectoryHeader_Cell: UICollectionReusableView {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellTitleAlphabet: UILabel!
    @IBOutlet var cellBtnAdd: UIButton!
    @IBOutlet var cellBtnEdit: UIButton!
    @IBOutlet var cellBtnDone: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class Directory_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellIcon: UIImageView!
    @IBOutlet var cellImage: MyImageView!
    @IBOutlet var cellStatus: UIView!
    @IBOutlet var cellTitleName: UILabel!
    @IBOutlet var cellTitlePosition: UILabel!
    @IBOutlet var cellTitleStatus: UILabel!
    @IBOutlet var cellBtnCall: UIButton!
    @IBOutlet var cellBtnEmail: UIButton!
    @IBOutlet var cellBtnDelete: UIButton!
    @IBOutlet var cellBtnStar: UIButton!
    @IBOutlet var cellBtnReport: UIButton!
    @IBOutlet var cellReportWorking: UILabel!
    @IBOutlet var cellReportLate: UILabel!
    @IBOutlet var cellReportAbsent: UILabel!
    @IBOutlet var cellReportLeave: UILabel!
    @IBOutlet var cellRankingNo: UILabel!
    @IBOutlet var cellRankingPoint: UILabel!
    @IBOutlet var cellRankingIcon: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class LeaveStatus_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellTotal: UILabel!
    @IBOutlet var cellRemain: UILabel!
    @IBOutlet var cellBar: UIProgressView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class LeaveHistory_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellTitle2: UILabel!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellSentDate: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellBtnDelete: UIButton!
    @IBOutlet var cellCount: UILabel!
    @IBOutlet var cellCountBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class LeaveDetail_Cell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellBg: UIView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellTitle2: UILabel!
    @IBOutlet var cellDescription2: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellPosition: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellBtnAccept: UIButton!
    @IBOutlet var cellBtnReject: UIButton!
    @IBOutlet var cellBtnCancel: UIButton!
    @IBOutlet var cellBtnWithdraw: UIButton!
    @IBOutlet var cellBtnStackView: UIStackView!
    @IBOutlet var cellReason: UITextView!
    @IBOutlet var cellBtnAction: UIButton!
    
    //Swap
    @IBOutlet var cellImage1: UIImageView!
    @IBOutlet var cellName1: UILabel!
    @IBOutlet var cellDate1: UILabel!
    @IBOutlet var cellTime1: UILabel!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellName2: UILabel!
    @IBOutlet var cellDate2: UILabel!
    @IBOutlet var cellTime2: UILabel!
    
    //Process
    @IBOutlet var cellCircle1: UIView!
    
    @IBOutlet var cellCircle2: UIView!
    
    @IBOutlet var cellCircle3: UIView!
    @IBOutlet var cellImage3: UIImageView!
    @IBOutlet var cellName3: UILabel!
    
    @IBOutlet var cellLine1: UIView!
    @IBOutlet var cellLine2: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class AttendanceHistory_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellType: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellBtnDelete: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}


class ApproveMenu_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellAlert: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class Approve_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellApproveType: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellRemark: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellBtnApprove: UIButton!
    @IBOutlet var cellBtnReject: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class ApproveDetail_Cell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellBg: UIView!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellTitle2: UILabel!
    @IBOutlet var cellDescription2: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellName: UILabel!
    @IBOutlet var cellPosition: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellReason: UITextView!
    @IBOutlet var cellBtnApprove: UIButton!
    @IBOutlet var cellBtnReject: MyButton!
    @IBOutlet var cellBtnStackView: UIStackView!
    
    @IBOutlet var cellImage1: UIImageView!
    @IBOutlet var cellName1: UILabel!
    @IBOutlet var cellDate1: UILabel!
    @IBOutlet var cellTime1: UILabel!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellName2: UILabel!
    @IBOutlet var cellDate2: UILabel!
    @IBOutlet var cellTime2: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class NotificationHeader_Cell: UICollectionReusableView {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellBtnReadAll: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class Notification_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage1: UIImageView!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellswapIcon: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellTime: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class OTRequest_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellBtnCheckbox: UIButton!
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellTime: UILabel!
    @IBOutlet var cellHour: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellBtnDelete: UIButton!
    @IBOutlet var cellTitle: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class Swap_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage1: UIImageView!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDate: UILabel!
    @IBOutlet var cellRemark: UILabel!
    @IBOutlet var cellStatus: UILabel!
    @IBOutlet var cellBtnApprove: UIButton!
    @IBOutlet var cellBtnReject: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class MissionCell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellPoint: UILabel!
    @IBOutlet var cellPointBg: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class MissionHistory_Cell: UICollectionViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellImage1: UIImageView!
    @IBOutlet var cellImage2: UIImageView!
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellTime: UILabel!
    @IBOutlet var cellPoint: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
}

class Probation_Cell: UITableViewCell {
    
    class var identifier: String { return String(describing: self) }
    class var nib: UINib { return UINib(nibName: identifier, bundle: nil) }
    
    @IBOutlet var cellTitle: UILabel!
    @IBOutlet var cellDescription: UILabel!
    @IBOutlet var cellButton1: UIButton!
    @IBOutlet var cellButton2: UIButton!
    @IBOutlet var cellButton3: UIButton!
    @IBOutlet var cellButton4: UIButton!
    @IBOutlet var cellButton5: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Background
        self.backgroundColor = .clear
    }
}
