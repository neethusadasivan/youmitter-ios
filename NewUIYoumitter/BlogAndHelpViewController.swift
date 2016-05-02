//
//  BlogAndHelpViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 01/07/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class BlogAndHelpViewController: UIViewController, UINavigationControllerDelegate, UIWebViewDelegate {

    @IBOutlet var webView: UIWebView!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!
    var url: String = "https://\(GlobalVariable.apiUrl)/blog"
//    var loadUrl = "http://\(GlobalVariable.apiUrl)/blog"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        println("jhshgjhgfjhgdjgfjsdf")
        
        webView.delegate = self
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
//        webView.loadRequest(request)
        
        let urlConnection:NSURLConnection = NSURLConnection(request: request, delegate: self)!
 
    }
    
    func webView(webView: UIWebView, didFailLoadWithError error: NSError?) {
        println("===error happens=====")
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)
        webView.loadRequest(request)
    }
    
    func webViewDidStartLoad(webView: UIWebView) {
        println("===started loading=====")
        self.activityIndicatorView.startAnimating()
//        self.activityIndicatorView.hidden = false
//        self.view.userInteractionEnabled = false
    }

    func webViewDidFinishLoad(webView: UIWebView) {
        println("===finished loading=====")
        self.activityIndicatorView.stopAnimating()
//        self.activityIndicatorView.hidden = true
//        self.view.userInteractionEnabled = true
    }




    func connection(connection: NSURLConnection, didFailWithError error: NSError){
        println("didFailWithError")
    }
    
    func connection(connection: NSURLConnection, canAuthenticateAgainstProtectionSpace protectionSpace: NSURLProtectionSpace) -> Bool{
        println("canAuthenticateAgainstProtectionSpace")
        //return [protectionSpace.authenticationMethodisEqualToString:NSURLAuthenticationMethodServerTrust];
        return true
    }
    
    func connection(connection: NSURLConnection, didReceiveAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
        println("did autherntcationchallenge = \(challenge.protectionSpace.authenticationMethod)")
        
        //if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust && challenge.protectionSpace.host == "myDomain.com" {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust  {
            println("send credential Server Trust")
            let credential = NSURLCredential(forTrust: challenge.protectionSpace.serverTrust)
            challenge.sender.useCredential(credential, forAuthenticationChallenge: challenge)
            
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic{
            println("send credential HTTP Basic")
            var defaultCredentials: NSURLCredential = NSURLCredential(user: "username", password: "password", persistence:NSURLCredentialPersistence.ForSession)
            challenge.sender.useCredential(defaultCredentials, forAuthenticationChallenge: challenge)
            
        }else if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodNTLM{
            println("send credential NTLM")
            
            
        } else{
            challenge.sender.performDefaultHandlingForAuthenticationChallenge!(challenge)
        }
        //challenge.sender.performDefaultHandlingForAuthenticationChallenge!(challenge)
        //challenge.sender.continueWithoutCredentialForAuthenticationChallenge(challenge)
    }
    
    /*
    func connection(connection: NSURLConnection, willSendRequestForAuthenticationChallenge challenge: NSURLAuthenticationChallenge) {
    
    
    }*/
    func connection(connection: NSURLConnection, didCancelAuthenticationChallenge challenge: NSURLAuthenticationChallenge){
        println("didCancelAuthenticationChallenge")
    }
    /*
    - (void)connection: (NSURLConnection *)connection willSendRequestForAuthenticationChallenge: (NSURLAuthenticationChallenge *)challenge
    {
    [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
    }*/
    
    func connection(connection: NSURLConnection, didReceiveResponse response: NSURLResponse){
        println("-----received response");
        
        
        
        // remake a webview call now that authentication has passed ok.
        
        //_authenticated =YES;
        
        //[_webloadRequest:_request];
        
        let requestURL = NSURL(string:url)
        let request = NSURLRequest(URL: requestURL!)

        webView.loadRequest(request)
        
        
        // Cancel the URL connection otherwise we double up (webview + url connection, same url = no good!)
        
        //[_urlConnectioncancel];
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        
//        navigationController?.popViewControllerAnimated(true)
        self.dismissViewControllerAnimated(true, completion: {})
        
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}
