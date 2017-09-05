//
//  JCScanQRCodeViewController.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation
import Photos

class JCScanQRCodeViewController: UIViewController,AVCaptureMetadataOutputObjectsDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate {
    
    let device = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo)
    let session = AVCaptureSession()
    var layer: AVCaptureVideoPreviewLayer?
    
    var lineImgV = UIImageView()
    var maskView = UIView()
     var backImgV = UIImageView()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.clear
        self.title = "扫一扫"
        
        let barButton = UIBarButtonItem(title: "相册", style: .plain, target: self, action: #selector(JCScanQRCodeViewController.pickPicture))
        
        self.navigationItem.rightBarButtonItem = barButton
        self.session.addObserver(self, forKeyPath: "running", options: .new, context: nil)
        // Do any additional setup after loading the view.
        if !cameraPermissions() {
            return
        }
        
        self.scanQRCode()
    }
    func pickPicture(){
        if PhotoLibraryPermissions() {
            let picker = UIImagePickerController()
            //设置代理
            picker.delegate = self
            //指定图片控制器类型
            picker.sourceType = UIImagePickerControllerSourceType.photoLibrary
            //弹出控制器，显示界面
            self.present(picker, animated: true, completion: {
                () -> Void in
            })
        }

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.startAnimation()
       self.session.startRunning()
    }
    
    private func scanQRCode(){
        if !isCameraAvailable(){
            showAlert("请使用真机", message: "您的设备没有相机.", VC: self)
            return
        }
        
        self.session.sessionPreset = AVCaptureSessionPresetHigh
        
        do{
            let input = try AVCaptureDeviceInput(device: self.device)
            if self.session.canAddInput(input){
                self.session.addInput(input)
            }
        }
        catch{
            showAlert("错误", message: "初始化失败", VC: self)
            return
        }
        self.layer = AVCaptureVideoPreviewLayer(session: self.session)
        self.layer?.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.layer?.frame = self.view.frame
        self.view.layer.addSublayer(self.layer!)
        self.session.addObserver(self, forKeyPath: "running", options: .new, context: nil)
        if AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo) == .authorized{
            
           
            
            let output = AVCaptureMetadataOutput()
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            
            //设置扫描的有效区域
            output.rectOfInterest = CGRect(x: 140.0/SCREEN_HEIGHT, y: 40.0/SCREEN_WIDTH, width: (SCREEN_WIDTH-80)/SCREEN_HEIGHT, height: (SCREEN_WIDTH-80)/SCREEN_WIDTH)
            if self.session.canAddOutput(output) {
                self.session.addOutput(output)
                output.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                
            }
            self.setOverlayPickerView()
            self.session.startRunning()
        }else{
            showAlert("提示", message:  "Authorization is required to use the camera, please check your permission settings: Settings> Privacy> Camera", VC: self)
        }
        
        
    }
    //设置蒙层
    private func setOverlayPickerView(){
        
        self.maskView = UIView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        self.maskView.alpha = 0.5
        self.maskView.backgroundColor = UIColor.black
        self.view.addSubview(self.maskView)
        
        self.backImgV = UIImageView(frame: CGRect(x: 40, y: 140, width: SCREEN_WIDTH-80, height: SCREEN_WIDTH-80))
        self.backImgV.image = UIImage(named: "扫描框")
        self.view.addSubview(self.backImgV)
        
        
        
        let msgLabel = UILabel(frame: CGRect(x: 30, y: backImgV.frame.maxY+30, width: SCREEN_WIDTH-60, height: 60))
        msgLabel.text = "将二维码放入框内,即可自动扫描"
        msgLabel.textColor = UIColor.white
        msgLabel.font = UIFont.systemFont(ofSize: 16.0)
        msgLabel.textAlignment = .center
        self.view.addSubview(msgLabel)
        self.resetMaskView()
        
        self.lineImgV.frame = CGRect(x: 40, y: 140, width: SCREEN_WIDTH-80, height: 2)
        self.lineImgV.image = UIImage(named: "扫描线")
        self.lineImgV.contentMode = .scaleAspectFill
        self.lineImgV.backgroundColor = UIColor.clear
        self.view.addSubview(self.lineImgV)
    }
    
    private func resetMaskView(){
        let path = UIBezierPath(rect: maskView.bounds)
        let clearPath = UIBezierPath(rect: CGRect(x: backImgV.frame.minX+1, y: backImgV.frame.minY+1, width: backImgV.frame.width-2, height: backImgV.frame.height-2)).reversing()
        path.append(clearPath)
        if let shapeLayer = maskView.layer.mask as? CAShapeLayer {
            shapeLayer.path = path.cgPath
        }else{
            let shapeLayer:CAShapeLayer = CAShapeLayer()
            maskView.layer.mask = shapeLayer
            shapeLayer.path = path.cgPath
        }
    }
    
    private  func cameraPermissions() -> Bool{
        
        let authStatus:AVAuthorizationStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        
        let mediaType = AVMediaTypeVideo
        
        if authStatus == AVAuthorizationStatus.notDetermined {
            AVCaptureDevice.requestAccess(forMediaType: mediaType) { (succuss) in
                if succuss{
                    DispatchQueue.main.sync {
                        self.scanQRCode()
                    }
                }
            }
        }
        
        if(authStatus == AVAuthorizationStatus.denied || authStatus == AVAuthorizationStatus.restricted) {
            let alert:UIAlertController = UIAlertController(title: "提示", message: "请设置－隐私－相机中打开权限", preferredStyle: .alert)
            self.present(alert, animated: true, completion: nil)
            let action:UIAlertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
            alert.addAction(action)
            showAlert("提示", message: "请设置－隐私－相机中打开权限", VC: self)
            return false
        }else if(authStatus == AVAuthorizationStatus.notDetermined){
            return false
        }else{
            return true
        }
        
    }
    
    private func PhotoLibraryPermissions() -> Bool {
        
        let library:PHAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if library == PHAuthorizationStatus.notDetermined{
            PHPhotoLibrary.requestAuthorization({ (libraryStatus) in
                
            })
        }
        if(library == PHAuthorizationStatus.denied || library == PHAuthorizationStatus.restricted){
            showAlert("提示", message: "请设置－隐私－相册中打开权限", VC: self)
            return false
        }else {
            return true
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let ob = object as? AVCaptureSession {
       
            if ob.isRunning{
                DispatchQueue.main.async(execute: {
                    //需要主线程执行的代码
                    self.startAnimation()
                })
                
            }else{
                DispatchQueue.main.async(execute: {
                    //需要主线程执行的代码
                    self.removeAnimation()
                })
                
            }
        }
    }
    //扫描动画
    private func startAnimation(){
        self.lineImgV.isHidden = false
        let animation = CABasicAnimation(keyPath: "position")
        animation.fromValue = NSValue(cgPoint: CGPoint(x: SCREEN_WIDTH/2.0, y: 140))
        animation.toValue = NSValue(cgPoint: CGPoint(x: SCREEN_WIDTH/2.0, y: 140+SCREEN_WIDTH-80))
        animation.duration = 2.0
        animation.repeatCount = Float(OPEN_MAX)
        animation.fillMode = kCAFillModeForwards
        animation.isRemovedOnCompletion = false
        self.lineImgV.layer.add(animation, forKey: "LineAnimation")
    }
    //移除动画
    private func removeAnimation(){
        self.lineImgV.layer.removeAnimation(forKey: "LineAnimation")
        self.lineImgV.isHidden = true
    }
    
    private func isCameraAvailable()->Bool{
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    deinit{
        self.session.removeObserver(self, forKeyPath: "running", context: nil)
    }
    //二维码扫描代理
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        var stringValue:String?
        if metadataObjects.count > 0 {
            let metadataObject = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
            stringValue = metadataObject.stringValue
            
        }
        self.session.stopRunning()
        print("code is \(String(describing: stringValue))")
        let result:JCQRResultViewController = JCQRResultViewController()
        result.urlString = stringValue!
        self.navigationController?.pushViewController(result, animated: true)
    }
    
    //图片选择代理
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        //获取选择的原图
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        picker.dismiss(animated: false, completion: {
            () -> Void in
            
        })
        
        let cropVC:JCImageCropViewController = JCImageCropViewController()
        cropVC.initWithImage(image, complentBlock: { (str) in
            
            let result:JCQRResultViewController = JCQRResultViewController()
            result.urlString = str
            self.navigationController?.pushViewController(result, animated: true)
        }) { (Void) in
            
        }
        
        self.present(cropVC, animated: true, completion: nil)
    }
    

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.session.stopRunning()
        self.removeAnimation()
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
