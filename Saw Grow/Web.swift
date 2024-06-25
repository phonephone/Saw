//
//  Web.swift
//  Saw Grow
//
//  Created by Truk Karawawattana on 6/1/2565 BE.
//

import UIKit
import ProgressHUD
import WebKit

class Web: UIViewController, WKNavigationDelegate, WKUIDelegate {
    
    var titleString:String?
    var webUrlString:String?
    
    var setColor: Bool = true
    
    @IBOutlet weak var headerView: UIView!
    
    @IBOutlet weak var headerTitle: UILabel!
    @IBOutlet var myWebView: WKWebView!
    
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
        
        myWebView.uiDelegate = self
        myWebView.navigationDelegate = self
        
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
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
        
        if let url = navigationAction.request.url, let scheme = url.scheme?.lowercased() {
            if scheme != "https" && scheme != "http" {//Check deeplink?
                if UIApplication.shared.canOpenURL(url){
                    UIApplication.shared.open(url)
                }
            }
            else {
            }
        }
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        return nil
    }
    
    @IBAction func back(_ sender: UIButton) {
        self.navigationController!.popViewController(animated: true)
    }
}
