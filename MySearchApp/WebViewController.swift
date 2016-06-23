//
//  WebViewController.swift
//  MySearchApp
//
//  Created by inoue on 2016/06/23.
//  Copyright © 2016年 inoue. All rights reserved.
//

import UIKit

class WebViewController: UIViewController {
    var itemUrl: String?
    
    @IBOutlet weak var webView: UIWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let itemUrl = "http://www.google.co.jp"
        if let url = NSURL(string: itemUrl) {
            let request = NSURLRequest(URL: url)
            webView.loadRequest(request)
        }
        
//        if let itemUrl = itemUrl {
//            if let url = NSURL(string: itemUrl) {
//                let request = NSURLRequest(URL: url)
//                webView.loadRequest(request)
//            }
//        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}