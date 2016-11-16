//
//  JCQRResultViewController.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit

class JCQRResultViewController: UIViewController {

    var urlString:String = ""
    
    enum ValidatedType {
        case email
        case phoneNumber
        case url
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.view.backgroundColor = UIColor.white
        
        if ValidateText(validatedType: .email, validateString: urlString)||ValidateText(validatedType: .url, validateString: urlString) {
            let web:UIWebView = UIWebView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height ))
            web.loadRequest(URLRequest(url: URL(string: urlString)!))
            
            self.view.addSubview(web)
        }else{
            let label:UILabel = UILabel(frame:CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height) )
            label.text = urlString
            label.textAlignment = NSTextAlignment.center
            label.textColor = UIColor.red
            self.view.addSubview(label);
        }
        

    }

    
    func ValidateText(validatedType type: ValidatedType, validateString: String) -> Bool {
        do {
            let pattern: String
            
            switch type {
            case ValidatedType.email:
                pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
                
            case ValidatedType.url:
                pattern = "[a-zA-z]+://[^\\s]*"
                
            default:
                pattern = "^1[0-9]{10}$"
                
            }
            
            
            let regex: NSRegularExpression = try NSRegularExpression(pattern: pattern, options: NSRegularExpression.Options.caseInsensitive)
            let matches = regex.matches(in: validateString, options: NSRegularExpression.MatchingOptions.reportProgress, range: NSMakeRange(0, validateString.characters.count))
            return matches.count > 0
        }
        catch {
            return false
        }
    }
    

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
