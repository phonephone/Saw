//
//  Tutorial_Old.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 21/2/2565 BE.
//

import UIKit
import Alamofire
import SwiftyJSON
import ProgressHUD

class Tutorial_Old: UIViewController, UIScrollViewDelegate {
    
    var tutorialJSON:JSON?
    var isTutorial = "1"
    
    var tutorialArray:[TutorialView] = [];
    
    @IBOutlet weak var myScrollView: UIScrollView!
    @IBOutlet weak var myPageControl: UIPageControl!
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        setupSlideScrollView(slides: tutorialArray)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("TUTORIAL")
        
        myScrollView.delegate = self
        
        tutorialArray = createSlides()
        
        myPageControl.numberOfPages = tutorialArray.count
        myPageControl.currentPage = 0
        self.view.bringSubviewToFront(myPageControl)
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
            }
        }
    }
    
    func createSlides() -> [TutorialView] {
        
        let slide1:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
        slide1.tutorialImage.image = UIImage(named: "demo_profile")
        slide1.tutorialTitle.text = "A Ant"
        
        let slide2:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
        slide2.tutorialImage.image = UIImage(named: "demo_profile")
        slide2.tutorialTitle.text = "B Bird"
        
        let slide3:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
        slide3.tutorialImage.image = UIImage(named: "demo_profile")
        slide3.tutorialTitle.text = "C Cat"
        
        let slide4:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
        slide4.tutorialImage.image = UIImage(named: "demo_profile")
        slide4.tutorialTitle.text = "D Dog"
        
        let slide5:TutorialView = Bundle.main.loadNibNamed("TutorialView", owner: self, options: nil)?.first as! TutorialView
        slide5.tutorialImage.image = UIImage(named: "demo_profile")
        slide5.tutorialTitle.text = "E Egg"
        
        return [slide1, slide2, slide3, slide4, slide5]
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
    }
}

