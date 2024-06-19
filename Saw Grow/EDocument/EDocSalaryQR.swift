//
//  EDocSalaryQR.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 6/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class EDocSalaryQR: UIViewController {
    
    var edocName:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var qrDetailView: UIStackView!
    @IBOutlet weak var qrImageView: UIImageView!
    @IBOutlet weak var uploadBtn: UIButton!
    @IBOutlet weak var deleteBtn: UIButton!
    @IBOutlet weak var downloadBtn: UIButton!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if setColor {
            self.navigationController?.setStatusBarColor()
            headerView.setGradientBackground()
            
            setColor = false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("EDOCUMENT QR")
        
        headTitle.text = edocName
        
        uploadBtn.isHidden = true
        deleteBtn.isHidden = true
        downloadBtn.isHidden = true

        qrDetailView.isHidden = true
        qrImageView.isHidden = true
        
        loadQR()
    }
    
    func loadQR() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"edocument/getqrcodepayroll", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS QR\(json)")
                
                if json["qr_code"].stringValue != "" {
                    self.qrImageView.sd_setImage(with: URL(string:json["qr_code"].stringValue), placeholderImage: nil)
                    self.updateButton(qrExisted: true)
                }
                else {
                    self.qrImageView.image = nil
                    self.updateButton(qrExisted: false)
                }
            }
        }
    }
    
    func updateButton(qrExisted: Bool) {
        uploadBtn.isHidden = true
        deleteBtn.isHidden = true
        downloadBtn.isHidden = true
        qrDetailView.isHidden = true
        qrImageView.isHidden = true
        
        if qrExisted {
            deleteBtn.isHidden = false
            downloadBtn.isHidden = false
            qrImageView.isHidden = false
            mainView.backgroundColor = .clear
        }
        else {
            uploadBtn.isHidden = false
            qrDetailView.isHidden = false
            mainView.backgroundColor = .white
        }
    }
    
    @IBAction func uploadClick(_ sender: UIButton) {
        chooseImageSource()
    }
    
    func chooseImageSource()
    {
        DispatchQueue.main.async {
            AttachmentHandler.shared.showAttachmentActionSheet(vc: self, allowEdit: false)
            AttachmentHandler.shared.imagePickedBlock = { (image) in
                self.uploadToServer(image: image)
            }
        }
    }
    
    func uploadToServer(image:UIImage)
    {
        let base64Image = image.convertImageToBase64String()
        print(base64Image)
        
        let parameters:Parameters = ["image":base64Image]
        loadRequest(method:.post, apiName:"edocument/setqrcodepayroll", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS UPLOAD\(json)")
                
                self.loadQR()
                //self.userPic.image = image
            }
        }
    }
    
    @IBAction func deleteClick(_ sender: UIButton) {
        deleteFromServer()
    }
    
    func deleteFromServer()
    {
        let parameters:Parameters = ["image":""]
        loadRequest(method:.post, apiName:"edocument/setqrcodepayroll", authorization:true, showLoadingHUD:true, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS DELETE\(json)")
                
                self.loadQR()
            }
        }
    }
    
    //MARK: - Saving Image here
    @IBAction func save(_ sender: AnyObject) {
        guard let selectedImage = qrImageView.image else {
            print("Image not found!")
            return
        }
        UIImageWriteToSavedPhotosAlbum(selectedImage, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    //MARK: - Add image to Library
    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // we got back an error!
            ProgressHUD.showError(error.localizedDescription)
        } else {
            ProgressHUD.showSuccess("Image saved".localized(), interaction: false)
        }
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}
