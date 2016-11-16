//
//  ViewController.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func createQRCode(_ sender: AnyObject) {
        let qr = JCCreateQRCodeViewController()
        self.navigationController?.pushViewController(qr, animated: true)
    }
    
    @IBAction func scanQRCode(_ sender: AnyObject) {
        self.navigationController?.pushViewController(JCScanQRCodeViewController(), animated: true)
    }
    
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

