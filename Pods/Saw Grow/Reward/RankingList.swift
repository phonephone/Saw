//
//  RankingList.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 27/4/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class RankingList: UIViewController, UITextFieldDelegate  {
    
    var rankingJSON:JSON?
    var rankingTab:rankingTab?
    
    var isSuperAdmin:Bool?
    var companyJSON:JSON?
    
    @IBOutlet weak var mainStack: UIStackView!
    
    @IBOutlet weak var myCollectionView: UICollectionView!
    
    @IBOutlet weak var companyView: UIView!
    @IBOutlet weak var companyIcon: UIButton!
    @IBOutlet weak var companyField: UITextField!
    @IBOutlet weak var companyBtn: UIButton!
    
    var companyPicker: UIPickerView! = UIPickerView()
    var selectedCompanyID: String = ""
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadRanking(withLoadingHUD: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("RANKING LIST")
        
        myCollectionView.delegate = self
        myCollectionView.dataSource = self
        myCollectionView.backgroundColor = .clear
        
        
        if isSuperAdmin! {
            companyView.isHidden = false
            companyField.delegate = self
            pickerSetup(picker: companyPicker)
            companyField.inputView = companyPicker
            selectPicker(companyPicker, didSelectRow: 0)
            
            mainStack.isLayoutMarginsRelativeArrangement = true
            mainStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 15, leading: 0, bottom: 15, trailing: 0)
        }
        else{
            companyView.isHidden = true
            mainStack.directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
            myCollectionView.contentInset = UIEdgeInsets(top: 15, left: 0, bottom: 15, right: 0)
        }
    }
    
    func loadRanking(withLoadingHUD:Bool) {
        var parameters:Parameters = [:]//valid,used,expired
        switch rankingTab {
        case .all :
            parameters = ["group":"all"]
        case .monthly:
            parameters = ["group":"monthly"]
        default:
            break
        }
        
        if isSuperAdmin! {
            parameters.updateValue(selectedCompanyID, forKey: "company_id")
        }
        print(parameters)
        
        loadRequest(method:.get, apiName:"reward/getranking", authorization:true, showLoadingHUD:withLoadingHUD, dismissHUD:false, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS RANKING\(json)")
                
                self.rankingJSON = json["data"][0]["profile"]
                
                self.myCollectionView.reloadData()
                
                if self.rankingJSON!.count > 0
                {
                    ProgressHUD.dismiss()
                }
                else{
                    self.showErrorNoData()
                }
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == companyField && companyField.text == "" {
            selectPicker(companyPicker, didSelectRow: 0)
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if companyField.text != "" {
            //submitBtn.enableBtn()
        }
    }
    
    func pickerSetup(picker:UIPickerView) {
        picker.delegate = self
        picker.dataSource = self
        picker.backgroundColor = .white
        picker.setValue(UIColor.textDarkGray, forKeyPath: "textColor")
    }
    
    @IBAction func dropdownClick(_ sender: UIButton) {
        companyField.becomeFirstResponder()
    }
    
}//end ViewController

// MARK: - Picker Datasource
extension RankingList: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if (companyJSON != nil) {
            return companyJSON!.count
        }
        else{
            return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companyJSON?[row]["company_name"].stringValue
    }
}

// MARK: - Picker Delegate
extension RankingList: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        print("Select \(row)")
        selectPicker(pickerView, didSelectRow: row)
    }
    
    func selectPicker(_ pickerView: UIPickerView, didSelectRow row: Int) {
        let cellArray = companyJSON![row]
        selectedCompanyID = cellArray["company_id"].stringValue
        companyField.text = cellArray["company_name"].stringValue
        companyIcon.sd_setImage(with: URL(string: cellArray["company_logo"].stringValue), for: .normal, placeholderImage: UIImage(named: "logo_circle"))
        loadRanking(withLoadingHUD: false)
    }
}


// MARK: - UICollectionViewDataSource

extension RankingList: UICollectionViewDataSource {
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        if (rankingJSON != nil) {
            return rankingJSON!.count
        }
        else{
            return 0
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cellArray = self.rankingJSON![indexPath.item]
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier:"DirectoryList_Cell", for: indexPath) as! Directory_Cell
        
        cell.layer.cornerRadius = 15
        cell.setRoundAndShadow()
        
        cell.cellImage.sd_setImage(with: URL(string:cellArray["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        
        cell.cellTitleName.text = "\(cellArray[self.firstNameKey()].stringValue) \(cellArray[self.lastNameKey()].stringValue)"
        
        cell.cellTitlePosition.text = cellArray["designation_name"].stringValue
        
        if cellArray["bordercolor"].stringValue == "" {
            let color = UIColor.themeColor
            cell.cellImage.borderColor = .clear
            cell.cellImage.borderWidth = 0
            cell.cellStatus.backgroundColor = color
        }
        else{
            let color = colorFromRGB(rgbString: cellArray["bordercolor"].stringValue)
            cell.cellImage.borderColor = color
            cell.cellImage.borderWidth = 4
            cell.cellStatus.backgroundColor = color
        }
        
        if cellArray["backgroundcolor"].stringValue == "" {
            cell.contentView.backgroundColor = .white
        }
        else{
            cell.contentView.backgroundColor = colorFromRGB(rgbString: cellArray["backgroundcolor"].stringValue)
        }
        
        if cellArray["rankingicon"].stringValue == "" {
            cell.cellRankingIcon.isHidden = true
        }
        else{
            cell.cellRankingIcon.isHidden = false
            cell.cellRankingIcon.sd_setImage(with: URL(string:cellArray["rankingicon"].stringValue), placeholderImage: UIImage(named: ""))
        }
        
        cell.cellRankingNo.text = cellArray["orderno"].stringValue
        cell.cellRankingPoint.text = cellArray["total_point"].stringValue
        
        return cell
    }

}

// MARK: - UICollectionViewDelegateFlowLayout

extension RankingList: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: collectionView.frame.width-8 , height:90)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) //.zero
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
}

// MARK: - UICollectionViewDelegate

extension RankingList: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView,
                        didSelectItemAt indexPath: IndexPath) {
//        let cellArray = self.rankingJSON![indexPath.item]

//        let vc = UIStoryboard.rewardStoryBoard.instantiateViewController(withIdentifier: "RewardDetail") as! RewardDetail
//        switch couponTab {
//        case .valid :
//            vc.mode = .mycoupon
//        case .used:
//            vc.mode = .used
//        case .expired:
//            vc.mode = .expired
//        default:
//            break
//        }
//        vc.rewardID = cellArray["id"].stringValue
//        self.navigationController!.pushViewController(vc, animated: true)
    }
}


