//
//  Profile.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 7/11/2564 BE.
//

import UIKit
import MessageUI
import Alamofire
import SwiftyJSON
import ProgressHUD
import AVFoundation
import Photos
import Localize_Swift

enum whoMode {
   case Me
   case Other
}

class Profile: UIViewController , MFMailComposeViewControllerDelegate {
    
    var whoMode:whoMode?
    var userID:String?
    
    var profileJSON:JSON?
    
    var senderRemain = 0
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var userPic: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var userPosition: UILabel!
    @IBOutlet weak var userBtn: UIButton!
    
    @IBOutlet weak var callBtn: UIButton!
    @IBOutlet weak var emailBtn: UIButton!
    @IBOutlet weak var employeeCardBtn: UIButton!
    @IBOutlet weak var stickerBtn: UIButton!
    @IBOutlet weak var editProfileBtn: UIButton!
    
    @IBOutlet weak var statusTitle: UILabel!
    @IBOutlet weak var statusIcon: UIImageView!
    
    @IBOutlet weak var warningView: UIView!
    @IBOutlet weak var warningTitle: UILabel!
    @IBOutlet weak var warningIcon: UIImageView!
    
    @IBOutlet weak var tableTitle: UILabel!
    @IBOutlet weak var myTableView: UITableView!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            headerView.setGradientBackground()

            setColor = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadProfile()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("PROFILE \(whoMode!) = \(userID!)")
        
        if whoMode == .Me {
            callBtn.isHidden = true
            emailBtn.isHidden = true
            stickerBtn.isHidden = true
            userBtn.setImage(UIImage(named: "profile_camera"), for: .normal)
            userBtn.isHidden = false
            //userBtn.imageView!.contentMode = .scaleAspectFit
            
            editProfileBtn.isHidden = true
        }
        else{
            employeeCardBtn.isHidden = true
            editProfileBtn.isHidden = true
            userBtn.isHidden = true
        }
        
//        changeColor(callBtn)
//        changeColor(emailBtn)
//        changeColor(employeeCardBtn)
//        changeColor(stickerBtn)
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        userPic.addGestureRecognizer(tapGestureRecognizer)
        userPic.isUserInteractionEnabled = true
        
        statusTitle.text = ""
        statusIcon.image = nil
        
        tableTitle.textColor = UIColor.themeColor
        
        // TableView
        myTableView.delegate = self
        myTableView.dataSource = self
        myTableView.backgroundColor = .clear
        //myTableView.tableFooterView = UIView(frame: .zero)
        myTableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: self.myTableView.frame.size.width, height: 1))
        
        warningView.isHidden = true
    }
    
    func loadProfile() {
        let parameters:Parameters = ["q":userID!]
        loadRequest(method:.get, apiName:"auth/getprofile", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PROFILE\(json)")
                
                self.profileJSON = json["data"][0]["profile"][0]
                self.senderRemain = json["data"][0]["remain"].intValue
                
                self.updateDisplay()
                
                self.myTableView.reloadData()
            }
        }
    }
    
    func updateDisplay() {
        userPic.sd_setImage(with: URL(string:profileJSON!["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        userName.text = "\(profileJSON!["first_name_en"].stringValue) \(profileJSON!["last_name_en"].stringValue)"
        
        //self.userPosition.text = self.profileJSON!["designation_name"].stringValue
        userPosition.text = "\(profileJSON!["first_name"].stringValue) \(profileJSON!["last_name"].stringValue)"
        
        if whoMode == .Me && profileJSON!["editable"].count > 0 {
            editProfileBtn.isHidden = false
        }
        
        statusTitle.text = profileJSON!["empstatusdetail"].stringValue
        statusTitle.textColor = colorFromRGB(rgbString: profileJSON!["empstatuscolor"].stringValue)
        statusIcon.sd_setImage(with: URL(string:profileJSON!["empstatusicon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        let warningStr = profileJSON!["warningcount"].stringValue
        if whoMode == .Me && warningStr != "" {
            warningTitle.text = warningStr
            warningTitle.textColor = colorFromRGB(rgbString: profileJSON!["warningcolor"].stringValue)
            warningIcon.sd_setImage(with: URL(string:profileJSON!["warningicon"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
            warningView.isHidden = false
        }
        else {
            warningView.isHidden = true
        }
    }
    
    func changeColor(_ sender: UIButton) {
        sender.setTitleColor(UIColor.customThemeColor(), for: .normal)
        sender.imageView?.setImageColor(color: UIColor.customThemeColor())
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        //let tappedImage = tapGestureRecognizer.view as! UIImageView

        if whoMode == .Me {
            chooseImageSource()
        }
        else{
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "EmployeeCard") as! EmployeeCard
            vc.profileJSON = self.profileJSON
            self.present(vc, animated: true, completion: nil)
        }
        
    }
    
    @IBAction func btnClick(_ sender: UIButton) {
        switch sender.tag {
        case 1://Call
            print("call")
            let phoneNumber = self.profileJSON!["contact_number"].stringValue
            
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: phoneNumber, style: .default , handler:{ (UIAlertAction)in
                if let callUrl = URL(string: "tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(callUrl) {
                            UIApplication.shared.open(callUrl)
                        }
            }))
            alert.actions.last?.titleTextColor = .themeColor
            
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler:{ (UIAlertAction)in
                
            }))
            alert.actions.last?.titleTextColor = .buttonRed
            
            //uncomment for iPad Support
            //alert.popoverPresentationController?.sourceView = self.view
            
            self.present(alert, animated: true, completion: {
                //print("Show Action Sheet completion block")
            })
            
        case 2://Email
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                mail.setToRecipients([self.profileJSON!["email"].stringValue])
                //mail.setMessageBody("<p>You're so awesome!</p>", isHTML: true)

                present(mail, animated: true)
            } else {
                // show failure alert
            }
            
        case 3://Employee Card
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "EmployeeCard") as! EmployeeCard
            vc.profileJSON = self.profileJSON
            self.present(vc, animated: true, completion: nil)
            
        case 4://Send Sticker
            let cellArray = self.profileJSON!
            print(cellArray["sendstatus"])
            if senderRemain > 0 {
                if cellArray["sendstatus"] == "0" {
                    if cellArray["remain"] != "0" {
                        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "SendSticker") as! SendSticker
                        vc.receiverJSON = cellArray
                        self.navigationController!.pushViewController(vc, animated: true)
                    }
                    else{
                        ProgressHUD.showError(cellArray["remaintext"].stringValue)
                    }
                }
                else{
                    ProgressHUD.showError("STICKER_Already_Sent".localized())
                }
            }
            else{
                ProgressHUD.showError("STICKER_Reach_Max".localized())
            }
            
        case 5://Edit Profile
            let vc = UIStoryboard.mainStoryBoard.instantiateViewController(withIdentifier: "EditProfile") as! EditProfile
            vc.editJSON = profileJSON!["editable"]
            self.navigationController!.pushViewController(vc, animated: true)
            
        default:
            break
        }
    }

    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
    }
    
    @IBAction func cameraClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    func chooseImageSource()
    {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showCameraAndPhotoLibrary(vc: self, allowEdit: true)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                self.uploadToServer(image: image)
            }
        }
    }
    
    func uploadToServer(image:UIImage)
    {
        //userPic.image = image
        let base64Image = image.convertImageToBase64String()
        //print(base64Image)
        
        let parameters:Parameters = ["image":base64Image]
        loadRequest(method:.post, apiName:"auth/setprofilepic", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS UPLOAD\(json)")
                
                self.loadProfile()
                //self.userPic.image = image
                //self.submitSuccess()
            }
        }
        
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension Profile: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (profileJSON != nil) {
            return 6
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70//self.myTableView.frame.height/6
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    {
        let cornerRadius = 15
        var corners: UIRectCorner = []

        if indexPath.row == 0
        {
            corners.update(with: .topLeft)
            corners.update(with: .topRight)
        }

        if indexPath.row == tableView.numberOfRows(inSection: indexPath.section) - 1
        {
            corners.update(with: .bottomLeft)
            corners.update(with: .bottomRight)
        }

        let maskLayer = CAShapeLayer()
        maskLayer.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: corners,
                                      cornerRadii: CGSize(width: cornerRadius, height: cornerRadius)).cgPath
        cell.layer.mask = maskLayer
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProfileCell", for: indexPath) as! ProfileCell

        switch indexPath.row {
        case 0:
            cell.profileTitle.text = "PROFILE_Title_Position".localized()
            cell.profileDetail.text = self.profileJSON!["designation_name"].stringValue
        case 1:
            cell.profileTitle.text = "PROFILE_Title_Department".localized()
            cell.profileDetail.text = self.profileJSON!["department_name"].stringValue
        case 2:
            cell.profileTitle.text = "PROFILE_Title_Head".localized()
            cell.profileDetail.text = self.profileJSON!["headname"].stringValue
        case 3:
            cell.profileTitle.text = "PROFILE_Title_Hire".localized()
            
            if  let hireDate = appDateFromServerString(dateStr: self.profileJSON!["date_of_joining"].stringValue) {
                cell.profileDetail.text = appStringFromDate(date: hireDate, format: DateFormatter.appDateFormatStr)
            }
            else {
                cell.profileDetail.text = "-"
            }
        case 4:
            cell.profileTitle.text = "PROFILE_Title_Email".localized()
            cell.profileDetail.text = self.profileJSON!["email"].stringValue
        case 5:
            cell.profileTitle.text = "PROFILE_Title_Phone".localized()
            cell.profileDetail.text = self.profileJSON!["contact_number"].stringValue
            cell.separatorInset = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        default:
            break
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension Profile: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
