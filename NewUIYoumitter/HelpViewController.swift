//
//  HelpViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 26/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {

    @IBOutlet var webView: UIWebView!
    
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()

        println("=====jhshgjhgfjhgdjgfjsdf=====")
        
        self.activityIndicatorView.startAnimating()
        self.activityIndicatorView.hidden = false
        self.view.userInteractionEnabled = false
        
        let url = "http://\(GlobalVariable.apiUrl)/help"
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
        
        self.activityIndicatorView.stopAnimating()
        self.activityIndicatorView.hidden = true
        self.view.userInteractionEnabled = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
