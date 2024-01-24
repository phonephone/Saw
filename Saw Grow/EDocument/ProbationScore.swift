//
//  ProbationScore.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 25/9/2566 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class ProbationScore: UIViewController {
    
    var probationJSON:JSON?
    var typeJSON:JSON?
    
    var edocName:String?
    var selectedPersonJSON:JSON?
    
    var scoreArray = [Int]()
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headTitle: UILabel!
    
    @IBOutlet weak var personPic: UIImageView!
    @IBOutlet weak var personName: UILabel!
    
    @IBOutlet weak var myTableView: UITableView!
    
    @IBOutlet weak var submitBtn: UIButton!
    
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
        print("PROBATION SCORE")
        
        headTitle.text = edocName
        personPic.sd_setImage(with: URL(string:selectedPersonJSON!["profile_photo"].stringValue), placeholderImage: UIImage(named: "logo_circle"))
        personName.text = "\(selectedPersonJSON!["first_name"].stringValue) \(selectedPersonJSON!["last_name"].stringValue)"
        
        myTableView.delegate = self
        myTableView.dataSource = self
        //myTableView.layer.cornerRadius = 15;
        //myTableView.layer.masksToBounds = true;
        myTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        submitBtn.disableBtn()
        self.hideKeyboardWhenTappedAround()
        
        loadProbation()
    }
    
    func loadProbation() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"edocument/getprobation_evaluate_title", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS PROBATION\(json)")
                
                self.probationJSON = json["data"][0]["evaluate"]
                self.typeJSON = json["data"][0]["remarklist"]
                
                self.setupScoreArray(total: self.probationJSON?.count ?? 0)
            }
        }
    }
    
    func setupScoreArray(total: Int) {
        scoreArray = [Int]()
        for _ in 0...total-1 {
            scoreArray.append(0)
        }
        print(scoreArray)
        
        myTableView.reloadData()
    }
    
    func checkAllScore() {
        submitBtn.enableBtn()
        for i in 0...scoreArray.count-1 {
            if scoreArray[i] == 0 {
                submitBtn.disableBtn()
            }
        }
    }
    
    @IBAction func submitClick(_ sender: UIButton) {
        let vc = UIStoryboard.eDocumentStoryBoard.instantiateViewController(withIdentifier: "ProbationResult") as! ProbationResult
        vc.edocName = edocName
        vc.selectedPersonJSON = selectedPersonJSON
        vc.scoreArray = scoreArray
        vc.typeJSON = typeJSON
        self.navigationController!.pushViewController(vc, animated: true)
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
    
}//end ViewController

// MARK: - UITableViewDataSource

extension ProbationScore: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        if (probationJSON != nil) {
            return probationJSON!.count
        }
        else{
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 0
        }
        else {
            return 5
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let headerView = UIView()
//        headerView.backgroundColor = .clear
//        return headerView
//    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension;
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cellArray = self.probationJSON![indexPath.section]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Probation_Cell", for: indexPath) as! Probation_Cell
        
        let hideSeperator = UIEdgeInsets.init(top: 0, left: 400,bottom: 0, right: 0)
        
        cell.cellTitle.text = "\(indexPath.section+1). \(cellArray["name_th"].stringValue)"
        
        cell.cellDescription.isHidden = true
        //cell.cellDescription.text = cellArray["xxx"].stringValue
        
        cell.cellButton1.backgroundColor = .buttonDisable
        cell.cellButton2.backgroundColor = .buttonDisable
        cell.cellButton3.backgroundColor = .buttonDisable
        cell.cellButton4.backgroundColor = .buttonDisable
        cell.cellButton5.backgroundColor = .buttonDisable
        
        cell.cellButton1.setTitleColor(.textDarkGray, for: .normal)
        cell.cellButton2.setTitleColor(.textDarkGray, for: .normal)
        cell.cellButton3.setTitleColor(.textDarkGray, for: .normal)
        cell.cellButton4.setTitleColor(.textDarkGray, for: .normal)
        cell.cellButton5.setTitleColor(.textDarkGray, for: .normal)
        
        switch scoreArray[indexPath.section] {
        case 1:
            cell.cellButton1.backgroundColor = .themeColor
            cell.cellButton1.setTitleColor(.white, for: .normal)
        case 2:
            cell.cellButton2.backgroundColor = .themeColor
            cell.cellButton2.setTitleColor(.white, for: .normal)
        case 3:
            cell.cellButton3.backgroundColor = .themeColor
            cell.cellButton3.setTitleColor(.white, for: .normal)
        case 4:
            cell.cellButton4.backgroundColor = .themeColor
            cell.cellButton4.setTitleColor(.white, for: .normal)
        case 5:
            cell.cellButton5.backgroundColor = .themeColor
            cell.cellButton5.setTitleColor(.white, for: .normal)
        default:
            break
        }
        
        cell.cellButton1.addTarget(self, action: #selector(scoreClick(_:)), for: .touchUpInside)
        cell.cellButton2.addTarget(self, action: #selector(scoreClick(_:)), for: .touchUpInside)
        cell.cellButton3.addTarget(self, action: #selector(scoreClick(_:)), for: .touchUpInside)
        cell.cellButton4.addTarget(self, action: #selector(scoreClick(_:)), for: .touchUpInside)
        cell.cellButton5.addTarget(self, action: #selector(scoreClick(_:)), for: .touchUpInside)
        
        cell.separatorInset = hideSeperator
        
        DispatchQueue.main.async {
            cell.roundCorners(corners: [.allCorners], radius: 15)
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate

extension ProbationScore: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Select \(indexPath.row)")
        
        //var cell = (tableView.cellForRow(at: indexPath) as? LeaveDetail_Cell)!
        //cell.menuImage.setImageColor(color: .themeColor)
        //cell.menuTitle.textColor = .themeColor
    }
    
    @IBAction func scoreClick(_ sender: UIButton) {
        var superview = sender.superview
        while let view = superview, !(view is UITableViewCell) {
            superview = view.superview
        }
        guard let cell = superview as? UITableViewCell else {
            return
        }
        guard let indexPath = myTableView.indexPath(for: cell) else {
            return
        }
        print("Score \(indexPath.section) - \(sender.tag)")
        //let cellArray = self.detailJSON![indexPath.item]
        
        scoreArray[indexPath.section] = sender.tag
        print(scoreArray)
        myTableView.reloadData()
        checkAllScore()
    }
}


