//
//  Tutorial.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 5/1/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD
import Localize_Swift

enum tutorialMode {
    case firstTime
    case later
}

class Tutorial: UIViewController, UIScrollViewDelegate {
    
    var mode:tutorialMode?
    
    var tutorialJSON:JSON?
    var isTutorial = "1"
    var tutorialPoint = "0"
    
    var tutorialArray:[TutorialView] = [];
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myPageControl: UIPageControl!
    
    @IBOutlet weak var nextBtn: UIButton!
    @IBOutlet weak var skipBtn: UIButton!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TUTORIAL")
        
        myScrollView.delegate = self
        
        if mode == .later {
            skipBtn.setTitle("TUTORIAL_Back_Button".localized(), for: .normal)
        }
        else{
            skipBtn.setTitle("TUTORIAL_Skip_Button".localized(), for: .normal)
        }
        loadTutorial()
    }
    
    override func viewDidLayoutSubviews() {
//        myPageControl.subviews.forEach {
//            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
//        }
    }
    
    func loadTutorial() {
        let parameters:Parameters = [:]
        loadRequest(method:.get, apiName:"auth/gettutorial", authorization:true, showLoadingHUD:true, dismissHUD:true, parameters: parameters){ result in
            switch result {
            case .failure(let error):
                print(error)
                //ProgressHUD.dismiss()
                
            case .success(let responseObject):
                let json = JSON(responseObject)
                print("SUCCESS TUTORIAL\(json)")
                
                self.tutorialJSON = json["data"]["tutorial"]
                self.isTutorial = json["data"]["istutorial"].stringValue
                self.tutorialPoint = json["data"]["point"].stringValue
                
                self.createSlides()
            }
        }
    }
    
    func createSlides() {
        tutorialArray.removeAll()
        for i in 0 ..< tutorialJSON!.count {
            let slide:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
            slide.tutorialImage.image = UIImage(named: "demo_profile")
            slide.tutorialImage.sd_setImage(with: URL(string:tutorialJSON![i]["image_url"].stringValue), placeholderImage: UIImage(named: "xxx"))
            slide.tutorialTitle.text = tutorialJSON![i]["title"].stringValue
            slide.tutorialDescription.text = tutorialJSON![i]["desc"].stringValue
            tutorialArray.append(slide)
        }
        
        myPageControl.numberOfPages = tutorialArray.count
        myPageControl.currentPage = 0
        self.view.bringSubviewToFront(myPageControl)
        
        setupSlideScrollView(slides: tutorialArray)
    }
    
    func setupSlideScrollView(slides : [TutorialView]) {
        myScrollView.frame = CGRect(x: 0, y: 0, width: myScrollView.frame.width, height: myScrollView.frame.height)
        myScrollView.contentSize = CGSize(width: myScrollView.frame.width * CGFloat(slides.count), height: myScrollView.frame.height)
        myScrollView.isPagingEnabled = true
        
        for i in 0 ..< slides.count {
            slides[i].frame = CGRect(x: myScrollView.frame.width * CGFloat(i), y: 0, width: myScrollView.frame.width, height: myScrollView.frame.height)
            myScrollView.addSubview(slides[i])
        }
    }
    
    @IBAction func pageControlChange(_ sender: UIPageControl) {
        //sender.currentPage*myScrollView.frame.width
        myScrollView.setContentOffset(CGPoint(x: sender.currentPage*Int(myScrollView.frame.width), y: 0), animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/scrollView.frame.width)
        myPageControl.currentPage = Int(pageIndex)
        
        if myPageControl.currentPage == myPageControl.numberOfPages-1 {
            nextBtn.setTitle("TUTORIAL_Next_Button_Done".localized(), for: .normal)
            skipBtn.isHidden = true
        }
        else{
            nextBtn.setTitle("TUTORIAL_Next_Button".localized(), for: .normal)
            skipBtn.isHidden = false
        }
        
        /*
        let maximumHorizontalOffset: CGFloat = scrollView.contentSize.width - scrollView.frame.width
        let currentHorizontalOffset: CGFloat = scrollView.contentOffset.x
        
        // vertical
        let maximumVerticalOffset: CGFloat = scrollView.contentSize.height - scrollView.frame.height
        let currentVerticalOffset: CGFloat = scrollView.contentOffset.y
        
        let percentageHorizontalOffset: CGFloat = currentHorizontalOffset / maximumHorizontalOffset
        let percentageVerticalOffset: CGFloat = currentVerticalOffset / maximumVerticalOffset
        
        
        /*
         * below code changes the background color of view on paging the scrollview
         */
        //        self.scrollView(scrollView, didScrollToPercentageOffset: percentageHorizontalOffset)
        
        
        /*
         * below code scales the imageview on paging the scrollview
         */
        let percentOffset: CGPoint = CGPoint(x: percentageHorizontalOffset, y: percentageVerticalOffset)
        
        if(percentOffset.x > 0 && percentOffset.x <= 0.25) {
            tutorialArray[0].tutorialImage.transform = CGAffineTransform(scaleX: (0.25-percentOffset.x)/0.25, y: (0.25-percentOffset.x)/0.25)
            tutorialArray[1].tutorialImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.25, y: percentOffset.x/0.25)
            
        } else if(percentOffset.x > 0.25 && percentOffset.x <= 0.50) {
            tutorialArray[1].tutorialImage.transform = CGAffineTransform(scaleX: (0.50-percentOffset.x)/0.25, y: (0.50-percentOffset.x)/0.25)
            tutorialArray[2].tutorialImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.50, y: percentOffset.x/0.50)
            
        } else if(percentOffset.x > 0.50 && percentOffset.x <= 0.75) {
            tutorialArray[2].tutorialImage.transform = CGAffineTransform(scaleX: (0.75-percentOffset.x)/0.25, y: (0.75-percentOffset.x)/0.25)
            tutorialArray[3].tutorialImage.transform = CGAffineTransform(scaleX: percentOffset.x/0.75, y: percentOffset.x/0.75)
            
        } else if(percentOffset.x > 0.75 && percentOffset.x <= 1) {
            tutorialArray[3].tutorialImage.transform = CGAffineTransform(scaleX: (1-percentOffset.x)/0.25, y: (1-percentOffset.x)/0.25)
            tutorialArray[4].tutorialImage.transform = CGAffineTransform(scaleX: percentOffset.x, y: percentOffset.x)
        }
         */
    }
    
    @IBAction func nextClick(_ sender: UIButton) {
        if myPageControl.currentPage == myPageControl.numberOfPages-1 {
            if isTutorial == "0" {
                let vc = UIStoryboard.loginStoryBoard.instantiateViewController(withIdentifier: "TutorialComplete") as! TutorialComplete
                vc.mode = mode
                vc.tutorialPoint = tutorialPoint
                self.navigationController!.pushViewController(vc, animated: true)
            }
            else{
                dismissTutorial()
            }
        }
        else{
            let nextPage = myPageControl.currentPage+1
            if nextPage <= myPageControl.numberOfPages-1 {
                myScrollView.setContentOffset(CGPoint(x: nextPage*Int(myScrollView.frame.width), y: 0), animated: true)
            }
        }
    }
    
    @IBAction func skipClick(_ sender: UIButton) {
        dismissTutorial()
    }
    
    func dismissTutorial() {
        if mode == .firstTime {
            switchToHome()
        }
        else{
            self.navigationController!.popViewController(animated: true)
        }
    }
}
