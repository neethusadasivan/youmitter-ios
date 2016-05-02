//
//  SignUpViewController.swift
//  NewUIYoumitter
//
//  Created by HOME on 03/06/15.
//  Copyright (c) 2015 Ruby Software. All rights reserved.
//

import UIKit

class SignUpViewController: UIViewController, UINavigationControllerDelegate {

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var userNameText: UITextField!
    @IBOutlet var firstNameText: UITextField!
    @IBOutlet var lastNameText: UITextField!
    @IBOutlet var emailIdText: UITextField!
    @IBOutlet var passwordText: UITextField!
    @IBOutlet var retypePasswordText: UITextField!
    @IBOutlet var postalCodeText: UITextField!
    @IBOutlet var promoCodeText: UITextField!
    @IBOutlet var checkBoxButton: UIButton!
    @IBOutlet var switchControl: UISwitch!
    @IBOutlet var referredByButton: UIButton!
    
    var userName: String = "", firstName: String = "", lastName: String = "", emailId: String = "", password: String = "", retypePassword: String = "", postalCode: String = "", promoCode: String = "", referredBy: String = ""
    var aboutYoumitter = ["Referred By Friend", "Article or Media", "Faebook", "Twitter", "Other"]
    var userInterests = ["One", "Two", "Three", "Four", "Five"]
    var checked = false
    var images = ["unchecked.png", "checked.png"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        switchControl.setOn(false, animated: true)
        
        scrollView.contentSize.height = 750
        var tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "DismissKeyboard")
        view.addGestureRecognizer(tap)
    }
    
    func DismissKeyboard(){
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func takeInputData() {
        userName = userNameText.text
        firstName = firstNameText.text
        lastName = lastNameText.text
        emailId = emailIdText.text
        password = passwordText.text
        retypePassword = retypePasswordText.text
        postalCode = postalCodeText.text
        promoCode = promoCodeText.text
        referredBy = referredByButton.titleForState(.Normal)!
        
        if (userName == "" || emailId == "" || password == "" || retypePassword == "") {
            var alertController = UIAlertController(title: "", message: "Please fill in Username, Email, Password and Password Confirmation.", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.view.frame = UIScreen.mainScreen().applicationFrame
            //Creating actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
                //                self.dismissViewControllerAnimated(false, completion: nil)
            }
            //Creating actions
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }
    }

    @IBAction func checkBoxButtonClicked(sender: AnyObject) {
        
        checked = !checked
        
        //        println("====currentBackgroundImage = \(image!) ====")
        var value = checked.hashValue
        println("====bool value = \(checked.hashValue) ====")
        //        let checkedImage = UIImage(named: "checked.png") as UIImage?
        //        let unCheckedImage = UIImage(named: "unchecked.png") as UIImage?
        println("images ===== \(images[value])")
        let image = UIImage(named: images[value]) as UIImage?
        checkBoxButton.setBackgroundImage(image, forState: .Normal)
        
    }
    
    @IBAction func userInterestsButtonClicked(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.userInterests.count {
            var okAction = UIAlertAction(title: "\(self.userInterests[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func aboutYoumitterClicked(sender: AnyObject) {
        
        var alertController = UIAlertController(title: "", message: "", preferredStyle: UIAlertControllerStyle.Alert)
        for i in 0 ..< self.aboutYoumitter.count {
            var okAction = UIAlertAction(title: "\(self.aboutYoumitter[i])", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                self.referredByButton.setTitle("\(self.aboutYoumitter[i])", forState: UIControlState.Normal)
                    println("Ok Pressed")
                
            }
            alertController.addAction(okAction)
        }
        var cancelAction = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel) {
            UIAlertAction in
        }
        alertController.addAction(cancelAction)
        self.presentViewController(alertController, animated: true, completion: nil)
        
    }
    
    @IBAction func switchButtonChanged(sender: AnyObject) {
        
    }
    
    @IBAction func showTermsAndConditions(sender: AnyObject) {
        
        
        let file = "text.txt"
        var text2 = "Welcome to Youmitter: a revolutionary concept for an anonymous social networking, micro-blogging platform. The following are Youmitter’s Terms and Conditions. Upon using or accessing Youmitter in any way, users agree to be bound by and fully comply with both these Terms and Conditions and the Privacy Policy.\n1. Limitations of Liability TO THE MAXIMUM EXTENT ALLOWABLE UNDER THE LAW, YOUMITTER, ITS EMPLOYEES, ITS AGENTS, ITS OWNERS, AND ANY RELATED ENTITY WILL NOT BE LIABLE FOR DIRECT, INDIRECT, CONSEQUENTIAL, SPECIAL, INCIDENTAL, OR PUNITIVE DAMAGES OR LOST PROFITS RESULTING FROM THE USE, MISUSE, OR INABILITY TO USE THE SITE, ANY THIRD PARTY CONTENT, CONTENT OF OTHER USERS OF THE SITE, CONTENT FROM THE SITE, OR CONTENT, MATERIAL, SERVICES, OR GOODS OBTAINED THROUGH THE USE OF THE SITE, IRRESPECTIVE OF WHETHER YOUMITTER HAS BEEN ADVISED OF THE POSSIBLIITY OF SUCH DAMAGES OR LOSSES. In the event that a jurisdiction does not allow for the disclaimer of a particular type of warranty or a limitation of liability, such provisions may not be applicable.\n2. Disclaimer of Warranties YOUMITTER IS AVAILABLE ON AN AS IS AND AS AVAILABLE BASIS. AS SUCH, YOUMITTER, TO THE FULLEST EXTENT OF THE LAW, DISCLAIMS ALL WARRANTIES OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING, BUT NOT LIMITED TO: WARRANTIES OF MERCHANTABILITY, NON-INFRINGEMENT, AND FITNESS FOR A PARTICULAR PURPOSE. NO COMMUNICATION WITH SITE STAFF WILL CREATE A WARRANTY. YOUMITTER DISCLAIMS ALL RESPONSIBILITY AND LIABILITY TO THE FULLEST EXTENT OF THE LAW FOR ISSUES ARISING OUT OF THE SITE, THE USE OF THE SITE, ITS CONTENT, OR CONTENT, GOODS, SERVICES, AND MATERIAL OBTAINED THROUGH THE USE OF THE SITE IN ANY WAY. Youmitter is not responsible or liable for the failure to store or the deletion of data, content, and information on the site.\n3. Limitations of Service Youmitter reserves the right to limit the amount of content users may transmit and upload as well as the amount and level of access users may have to the site. Youmitter may discontinue all or part of its functionality and operations without notice and will not be liable or responsible to users or third parties in the event of such an occurrence.\n4. Copyright Youmitter does not actively scan user content for copyright violations. If you believe content on the site violates copyright, please relay all of the following information to site administrators: identification of the content believed to be in violation of copyright, a statement by you declaring that you have a good faith belief that the alleged use of the copyrighted content is not authorized in any way, your complete contact information, your signature, and a statement declaring, under penalty of perjury, you are authorized to act on behalf of the copyright owner and that all information included in this correspondence is complete and accurate. Youmitter reserves the right to remove content believed to be in violation of copyright and may suspend, disable, or delete the offending account or block the IP address of an offending user.\n5. User Content and Accounts Users waive all rights to transmissions, photos, videos, and other content and grant Youmitter a non-exclusive, irrevocable, transferable, royalty-free, worldwide license to use in any way such content without compensation. Content may also be removed and deleted without notice for violating any provision of the Terms and Conditions or the Privacy Policy.Youmitter reserves the right, without notice, to remove and delete content that is offensive, spam, illegal, or otherwise unwanted. Upon discovering offensive content, users may alert site administrators, who may, but are not obligated to, remove such content. Transmissions that are removed prior to their paid-for expiration date will not result in the refund of the unused credits.By accepting these terms and creating a user account on Youmitter, you are agreeing to receive email notifications that are a part of the operation of Youmitter, and which may be used for informational and marketing purposes.Youmitter reserves the right, without notice, to suspend, disable, and delete accounts that violate the Terms and Conditions or the Privacy Policy. Youmitter may also block IP addresses as well as take any other action to terminate a user’s access to the site. Unused credits will not be refunded to users who have their accounts suspended, disabled, or deleted.\n6. Wishes and Voluntary Disclosures of Information by Users Youmitter does not guarantee that a wish will be granted. Youmitter is not liable or responsible for consequences flowing from voluntary disclosures of personal information by users. When goods are purchased or services rendered between users, Youmitter is not liable or responsible for the shipping, performance, damage to, problem with, or quality of any such good or service. To the fullest extent of the law, Youmitter disclaims all warranties for goods or services received or rendered through the use of the site in any way.\n7. Indemnity In the event a claim is brought against Youmitter that arises out of a user’s actions, content, or transmissions to, on, or through this site or relating to the Terms and Conditions or the Privacy Policy, the aforementioned offending user agrees to indemnify and hold Youmitter harmless from any such claim and related damages of any kind including reasonable legal fees and costs.\n8. Choice of Law Without regard to conflict of law provisions, the laws of the State of Georgia will govern the Terms and Conditions, the Privacy Policy, and any claim that arises in connection with Youmitter.\n9. Jurisdiction Users submit and consent to the personal jurisdiction of and venue in the courts located in Fulton County, Georgia. All claims arising out of the Terms and Conditions, the Privacy Policy, or otherwise in connection with Youmitter will be resolved in such courts.\n10. Third Party Links Youmitter may provide links to third party sites through advertisements or otherwise. Youmitter is not responsible or liable in any way for the content stemming from the use of these links. The user assumes all risk in using such third party links and content therein.\n11. Privacy Policy By agreeing to the Terms and Conditions or by using Youmitter in any way, users also agree to the terms of the Privacy Policy.\n12. Alterations to Terms and Conditions or Privacy PolicyYoumitter reserves the right to alter the Terms and Conditions and the Privacy Policy at any time. Each aforementioned agreement on the site will reflect any alteration immediately upon its implementation. By continuing to use Youmitter following the posting of an altered agreement, users agree to be bound by the altered agreement.\n13. Severability In the event that a court finds a provision of the Terms and Conditions or the Privacy Policy invalid or unenforceable, the remainder of both of these agreements will remain in full force and effect.\n14. Miscellaneous Users agree to comply with all applicable law when using Youmitter. Failure to exercise or enforce any provisions of the Terms and Conditions or Privacy Policy does not constitute a waiver of that or any other provision of either agreement.The Terms and Conditions and Privacy Policy make up the entire agreement between Youmitter and its users, and supersede any prior agreements. Though Youmitter takes all reasonable precautions to ensure the security and privacy of the personal information and content users provide, we do not guarantee security. International users of Youmitter agree that their information and content will be transmitted to and indefinitely stored in the United States. Youmitter does not knowingly collect or store personal information from children younger than 13. If Youmitter becomes aware of such an instance, site administrators will endeavor to remove all related information. Youmitter is the property of Green Circle, LLC. The Youmitter name and Youmitter logo are registered trademarks of Green Circle, LLC. All rights reserved.\n15. Definitions\n\"Transmissions\" are micro-blog text posts, created through the primary application on Youmitter.\nA \"credit\" is the unit of currency on Youmitter, which users purchase and apply towards the posting length of transmissions.\nA \"wish\" is a feature of Youmitter that involves the use of a transmission as a solicitation for a good or service.\n\"Content\" is user-uploaded, -created, or –submitted material that includes, but is not limited to, all picture files, video files, and transmissions.\nA \"user\" is any person who uses any part of Youmitter in any way for any purpose.\n\"The site\" refers to www.youmitter.com and all pages therein and associated therein."
//        let path = NSBundle.mainBundle().pathForResource("terms", ofType: "rtf")//or rtf for an rtf file
//        var text = String(contentsOfFile: path!, encoding: NSUTF8StringEncoding, error: nil)!
//        println(text)
        
//        if let dirs : [String] = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.AllDomainsMask, true) as? [String] {
//            let dir = dirs[0] //documents directory
//            let path = dir.stringByAppendingPathComponent(file);
//            println("===path=====\(path)")
//                        //reading
//            text2 = String(contentsOfFile: path, encoding: NSUTF8StringEncoding, error: nil)!
//        }
        dispatch_async(dispatch_get_main_queue()) {
            var alertController = UIAlertController(title: "", message: "\(text2)", preferredStyle: UIAlertControllerStyle.Alert)
            alertController.view.frame = UIScreen.mainScreen().applicationFrame
            //Creating actions
            var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                UIAlertAction in
                println("Ok Pressed")
//                self.dismissViewControllerAnimated(false, completion: nil)
            }
            //Creating actions
            alertController.addAction(okAction)
            self.presentViewController(alertController, animated: true, completion: nil)
        }

    }
    
    
    @IBAction func registerButtonClicked(sender: AnyObject) {
        
        takeInputData()
        
        if (switchControl.on) {
            
        
        if Reachability.isConnectedToNetwork() == true {
            println("Internet connection OK")
            
        
        var url : String = "http://\(GlobalVariable.apiUrl)/api/sign_up.json?username=\(userName)&password=\(password)&password_confirmation=\(retypePassword)&first_name=\(firstName)&last_name=\(lastName)&email=\(emailId)&postal_code_data=\(postalCode)&promo_code=\(promoCode)&hear_about=\(referredBy)&terms_and_conditions=1"
            
        println("=====url======\(url)")
            
        var request : NSMutableURLRequest = NSMutableURLRequest()
        request.URL = NSURL(string: url)
        request.HTTPMethod = "POST"
        println("url========\(url)")
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue(), completionHandler:{ (response:NSURLResponse!, data: NSData!, error: NSError!) -> Void in
            var error: AutoreleasingUnsafeMutablePointer<NSError?> = nil
            let jsonResult: NSDictionary! = NSJSONSerialization.JSONObjectWithData(data, options:NSJSONReadingOptions.MutableContainers, error: error) as? NSDictionary
            
            if (jsonResult != nil) {
                
                println("====== \(jsonResult) ======")
                // process jsonResult
                //                var authenticationStatus: NSString = jsonResult["authentication"] as NSString
                var api_key:NSString? = jsonResult?.valueForKey("api_key") as? NSString
                println("======= 5555555555555555555 =======")
                if jsonResult?.valueForKey("api_key") != nil {
                    println("======= 2222222 333333333 1111111 44444444 =======")
                    //                    api_key = jsonResult["api_key"] as NSString
                    //                    //                    var defaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()
                    //                    defaults.setObject(api_key, forKey: "apiKey")
                    //
                    //                    defaults.setObject(jsonResult["name"], forKey: "name")
                    //
                    //                    defaults.setObject(jsonResult["username"], forKey: "userName")
                    //
                    //                    defaults.setObject(jsonResult["image_url"], forKey: "imageUrl")
                    //
                    //                    defaults.synchronize()
                    
                    
                    
                    dispatch_async(dispatch_get_main_queue()) {
                        var alertController = UIAlertController(title: "", message: "Check your mail to verify your account.", preferredStyle: UIAlertControllerStyle.Alert)
                        //Creating actions
                        var okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.Default) {
                            UIAlertAction in
                            println("Ok Pressed")
                            self.dismissViewControllerAnimated(false, completion: nil)
                        }
                        //Creating actions
                        alertController.addAction(okAction)
                        self.presentViewController(alertController, animated: true, completion: nil)
                        
                        ////                        self.performSegueWithIdentifier("universeView", sender: self)
                    }
                    
                    
                    
                    
                    //
                }
                else if jsonResult?.valueForKey("validations") != nil{
                    println("======== else part ========")
                    var errorMessage: NSDictionary = (jsonResult["validations"] as NSDictionary)
                    var displayMessage = errorMessage["1"] as String
                    dispatch_async(dispatch_get_main_queue()) {
                        let alertController = UIAlertController(title: "", message: "\(displayMessage)", preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                        self.presentViewController(alertController, animated: true, completion: nil)
                    }
                }
            } else {
                // couldn't load JSON, look at error
            }
        
        })
            
        }
            
        }
        else {
            
            
            dispatch_async(dispatch_get_main_queue()) {
                let alertController = UIAlertController(title: "", message: "Please accept terms and conditions.", preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.Default,handler: nil))
                self.presentViewController(alertController, animated: true, completion: nil)
            }

            
        }
        
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        self.dismissViewControllerAnimated(true, completion: {})
    }
    
}
