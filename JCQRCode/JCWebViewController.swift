//
//  JCWebViewController.swift
//  JCQRCode
//
//  Created by 黄超 on 2017/11/7.
//  Copyright © 2017年 jon. All rights reserved.
//

import UIKit

class JCWebViewController: UIViewController,UIWebViewDelegate {
    var webUrl:String!
    var progressV:UIProgressView!
    let codeTimer = DispatchSource.makeTimerSource(queue:DispatchQueue.global())

    override func viewDidLoad() {
        super.viewDidLoad()
        let web:UIWebView = UIWebView(frame:CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height ))
        web.loadRequest(URLRequest(url: URL(string: webUrl)!))
        web.delegate=self
        self.view.addSubview(web)
        
        self.progressV = UIProgressView(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: 5))
        self.progressV.progressTintColor = UIColor.green
        self.progressV.progress=0
        self.view.addSubview(self.progressV)

        // 在global线程里创建一个时间源
        
        // 设定这个时间源是每0.5秒循环一次，立即开始
        self.codeTimer.scheduleRepeating(deadline: .now(), interval: .milliseconds(10))
        // 设定时间源的触发事件
        self.codeTimer.setEventHandler(handler: {
            // 每半秒计时一次

            // 时间到了取消时间源
           
            // 返回主线程处理一些事件，更新UI等等
            DispatchQueue.main.async {
                if self.progressV.progress >= 0.9{
                    self.codeTimer.cancel()

                }
                self.progressV.progress+=0.005
            }
            
        })
        //启动定时器
        self.codeTimer.activate()

        
        // Do any additional setup after loading the view.
    }
    func webViewDidFinishLoad(_ webView: UIWebView) {
        if (self.progressV != nil){
            self.progressV.progress=1
            self.codeTimer.cancel()
            self.progressV.removeFromSuperview();
        }
    }

    deinit {
        self.codeTimer.cancel()
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
