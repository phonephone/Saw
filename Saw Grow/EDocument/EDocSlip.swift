//
//  EDocSlip.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 3/7/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

class EDocSlip: UIViewController, UITextFieldDelegate, UITextViewDelegate {
    
    var slipJSON:JSON?
    
    var selectedSlip:[String] = []
    
    let alertService = AlertService()

    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var submitBtn: MyButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("PAYSLIP REQUEST")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        
        submitBtn.disableBtn()
        self.hideKeyboardWhenTappedAround()
        
        loadSlip(withLoadingHUD: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func loadSlip(withLoadingHUD:Bool) {
        let parameters:Parameters = [:]
        
        loadRequest(method:.get, apiName:"edocument/getslipperiod", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                //print("SUCCESS LEAVE\(json)")
                
                self.slipJSON = json["data"]
                self.myCollectionView.reloadData()
                
                if self.slipJSON!.count > 0
                {
                    if withLoadingHUD {
                        ProgressHUD.dismiss()
                    }
                }
                else{
                    self.showErrorNoData()
                }
            }
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        confirmAsk()
    }
    
    func confirmAsk() {
        let alertMain = alertService.alertMain(title: "EDOC_SLIP_Confirm".localized(), buttonTitle: "Confirm".localized(), buttonColor: .themeColor)
        {
            self.loadSubmit()
        }
        present(alertMain, animated: true)
    }
    
    func loadSubmit() {
        //print(selectedSlip)
        var selectID = ""
        for i in 0..<selectedSlip.count {
            if i == 0{
                selectID = selectedSlip[i]
            }
            else{
                selectID += "," + selectedSlip[i]
            }
        }
        //print(selectID)
         
        let parameters:Parameters = ["id":selectID,
                                     "type":"slip"
        ]
        print(parameters)

        self.clearForm()
        loadRequest(method:.post, apiName:"edocument/setslip", authorization:true, showLoadingHUD:false, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()

            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS SLIP\(json)")

                self.submitSuccess()
                self.clearForm()
            }
        }
    }
    
    func clearForm() {
        slipJSON = nil
        
        selectedSlip.removeAll()
        
        myCollectionView.reloadData()
        
        submitBtn.disableBtn()
        
        loadSlip(withLoadingHUD: false)
    }
}

// MARK: - UICollectionViewDataSource

extension EDocSlip: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (slipJSON != nil) {
            return slipJSON!.count
        }
        else{
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {

//        if let headerCell = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "NotificationHeader_Cell", for: indexPath) as? NotificationHeader_Cell
//        {
//            headerCell.cellBtnReadAll.addTarget(self, action: #selector(readAllClick(_:)), for: .touchUpInside)
//
//            return headerCell
//        }
        return UICollectionReusableView()
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.slipJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"SlipRequest_Cell", for: indexPath) as! OTRequest_Cell
        
        //cell.layer.cornerRadius = 15
        
        cell.cellTitle.text = cellArray["name"].stringValue
        cell.cellDate.text = "\("EDOC_SLIP_Period".localized()) \(cellArray["period"].stringValue)"
        
        let id = cellArray["id"].stringValue
        if selectedSlip.firstIndex(of: id) != nil {
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
        }
        else {
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
        }
        cell.cellBtnCheckbox.addTarget(self, action: #selector(checkboxClick(_:)), for: .touchUpInside)
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension EDocSlip: UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForHeaderInSection section: Int) -> CGSize {
        
        return CGSize(width: collectionView.frame.width, height: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let viewWidth = collectionView.frame.width
        //let viewHeight = collectionView.frame.height
        return CGSize(width: viewWidth , height:70)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
}

// MARK: - UICollectionViewDelegate

extension EDocSlip: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
        updateCheckbox(indexPath: indexPath)
    }
    
    @IBAction func checkboxClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UICollectionViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UICollectionViewCell else {
            print("button is not contained in a table view cell")
            return
        }
        guard let indexPath = myCollectionView.indexPath(for: cell) else {
            print("failed to get index path for cell containing button")
            return
        }
        //print("Delete \(indexPath.section) - \(indexPath.item)")
        updateCheckbox(indexPath: indexPath)
    }
    
    func updateCheckbox(indexPath: IndexPath) {
        let cellArray = self.slipJSON![indexPath.item]
        let id = cellArray["id"].stringValue
        
        let cell = myCollectionView.cellForItem(at: indexPath) as! OTRequest_Cell
        
        if let index = selectedSlip.firstIndex(of: id) {
            selectedSlip.remove(at: index)
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_off"), for: .normal)
        }
        else {
            selectedSlip += [id]
            cell.cellBtnCheckbox.setImage(UIImage(named: "form_checkbox_on"), for: .normal)
        }
        
        if selectedSlip.count > 0 {
            submitBtn.enableBtn()
        }
        else{
            submitBtn.disableBtn()
        }
    }
}

