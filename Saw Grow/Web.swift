//
//  Web.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 6/1/2565 BE.
//

import UIKit
import ProgressHUD
import WebKit

class Web: UIViewController, WKNavigationDelegate {
    
    var titleString:String?
    var webUrlString:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet weak var myWebView: WKWebView!
    
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
        print("Web")
        
        headerTitle.text = titleString
        
        let url = URL(string: webUrlString!)!
        //let url = URL(string: "https://www.google.com")!
        myWebView.load(URLRequest(url: url))
        myWebView.navigationDelegate = self
        myWebView.allowsBackForwardNavigationGestures = true
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loadingHUD()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        ProgressHUD.dismiss()
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
