//
//  SendSticker.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 26/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class SendSticker: UIViewController, UITextViewDelegate {
    
    var receiverJSON:JSON?
    var stickerJSON:JSON?
    
    var selectedStickerID:String = ""
    var detailImage:UIImage?
    var detailPoint:String = ""
    
    let remarkStr = "STICKER_SEND_Remark".localized()
    
    @IBOutlet weak var pointLabel: UILabel!
    @IBOutlet weak var receiverNameLabel: UILabel!
    @IBOutlet weak var remarkText: UITextView!
    @IBOutlet weak var submitBtn: UIButton!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("SEND STICKER")
        
        // CollectionView
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        myCollectionView.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        
        remarkText.delegate = self
        remarkText.text = remarkStr
        remarkText.textColor = UIColor.lightGray
        remarkText.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        //remarkText.contentOffset = CGPoint(x: 0, y: -10)
        
        receiverNameLabel.text = "\(receiverJSON![self.firstNameKey()].stringValue) \(receiverJSON![self.lastNameKey()].stringValue)"
        
        submitBtn.disableBtn()
        
        loadSticker()
    }
    
    func loadSticker() {
        let parameters:Parameters = ["q":receiverJSON!["user_id"]]
        loadRequest(method:.get, apiName:"reward/getsendgift", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ [self] result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS STICKER\(json)")

                self.stickerJSON = json["data"][0]["sticker"]
                self.receiverJSON = json["data"][0]["profile"][0]
                myCollectionView.reloadData()
                //self.remainLabel.text = "Remain \(json["data"][0]["remain"].stringValue)"
            }
        }
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.text == remarkStr {
            textView.text = ""
            remarkText.textColor = .textDarkGray
        }
        
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        if textView.text == "" {
            textView.text = remarkStr
            remarkText.textColor = UIColor.lightGray
        }
        return true
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        var alert = UIAlertController()
        
        alert = UIAlertController(title: nil, message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel".localized(), style: .default, handler: { action in
        }))
        alert.actions.last?.titleTextColor = .buttonRed
        
        alert.title = "STICKER_SEND_Confirm".localized()
        //alert.message = "plaes make sure before..."
        alert.addAction(UIAlertAction(title: "Confirm".localized(), style: .default, handler: { action in
            self.loadSubmit()
        }))
        alert.actions.last?.titleTextColor = .themeColor
        
        alert.setColorAndFont()
        
        self.present(alert, animated: true)
    }
    
    func loadSubmit() {
        
        var descriptionStr:String
        if remarkText.text == remarkStr {
            descriptionStr = ""
        }
        else{
            descriptionStr = remarkText.text
        }
        
        let parameters:Parameters = ["user_id":receiverJSON!["user_id"] ,
                                     "sticker_id":selectedStickerID,
                                     "remark":descriptionStr,
        ]
        print(parameters)
        
        loadRequest(method:.post, apiName:"reward/setsendgift", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SEND STICKER\(json)")

                //self.submitSuccess()
                
                let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "SendComplete") as! SendComplete
                vc.receiverJSON = self.receiverJSON
                vc.detailImage = self.detailImage
                vc.detailPoint = self.detailPoint
                vc.detailRemark = descriptionStr
                self.navigationController!.pushViewController(vc, animated: true)
            }
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}

// MARK: - UICollectionViewDataSource

extension SendSticker: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (stickerJSON != nil) {
            return stickerJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"CategoryCell", for: indexPath) as! CategoryCell
        let cellArray = self.stickerJSON![indexPath.item]
        
        cell.layer.cornerRadius = 15
        cell.backgroundColor = .white
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["image_url"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitle.text = cellArray["sticker_name"].stringValue
        
//        if cellArray["myaccount"] == "1" {
//            cell.cellBtnStar.isHidden = true
//        }
        
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension SendSticker: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 110 , height: 110)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UICollectionViewDelegate

extension SendSticker: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        
        for i in 0..<stickerJSON!.count {
            let cell = myCollectionView.cellForItem(at: IndexPath(row: i, section: 0)) as! CategoryCell
            cell.backgroundColor = .white
        }
        
        let cell = myCollectionView.cellForItem(at: indexPath) as! CategoryCell
        cell.backgroundColor = UIColor.themeColor.withAlphaComponent(0.1)
        selectedStickerID = stickerJSON![indexPath.item]["sticker_id"].stringValue
        detailImage = cell.cellImage.image
        detailPoint = stickerJSON![indexPath.item]["sticker_name"].stringValue
        submitBtn.enableBtn()
    }
}
