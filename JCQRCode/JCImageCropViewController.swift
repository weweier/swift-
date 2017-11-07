//
//  JCImageCropViewController.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit

class JCImageCropViewController: UIViewController {

    fileprivate var cropImage:UIImage!
    fileprivate var imgV:UIImageView!
    fileprivate var bgView:UIView!
    fileprivate var cropView:UIView!
    fileprivate var startPoint:CGPoint!
    fileprivate var lastScaleFactor:CGFloat = 1
    fileprivate var startSize:CGSize!
    fileprivate var touchBeginPoint:CGPoint!
    fileprivate var touchBeginCropViewRect:CGRect!
    fileprivate var imageScale:CGFloat!
    
    var complentButtonBlock:((_ stringVaule:String)->Void)?
    var cancalButtonBlock:(()->Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        loadImage()
        resetCropViewMask()
        // Do any additional setup after loading the view.
    }
    
    func initWithImage(_ image:UIImage,complentBlock:@escaping (_ str :String)->Void,cancalBlock:@escaping ()->Void){
        
        cropImage = image.fixOrientation()
        self.complentButtonBlock = complentBlock
        self.cancalButtonBlock = cancalBlock
        
        
        
    }
    //加载图片
    fileprivate func loadImage(){
        
        
        var frame:CGRect = CGRect()
        
        let wscale:CGFloat = self.cropImage.size.width/SCREEN_WIDTH
        let hscale:CGFloat = self.cropImage.size.height/SCREEN_HEIGHT
        
        frame.size.height = self.cropImage.size.height/max(wscale, hscale)
        frame.size.width = self.cropImage.size.width/max(wscale, hscale)
        self.imageScale = max(wscale, hscale)
        
        self.imgV.frame = frame
        self.imgV.center = self.view.center
        //self.view.layoutIfNeeded()
    }
    
    fileprivate func setupUI(){
        self.view.backgroundColor = UIColor.black
        
        self.imgV = UIImageView(frame: CGRect(x: 0, y: 0, width: SCREEN_WIDTH, height: SCREEN_HEIGHT))
        
        self.imgV.image = cropImage
        self.view.addSubview(self.imgV)
        //
        self.bgView = UIView(frame: CGRect(x:0, y:0, width:SCREEN_WIDTH, height:SCREEN_HEIGHT))
        self.bgView.backgroundColor = UIColor(white: 0, alpha: 0.6)
        self.bgView.isUserInteractionEnabled = true
        self.view.addSubview(self.bgView)
        
        self.cropView = UIView(frame:  CGRect(x:0, y:0, width:100, height:100))
        self.cropView.center = self.imgV.center
        self.cropView.layer.borderColor = UIColor.yellow.cgColor
        self.cropView.layer.borderWidth = 1;
        //self.cropView.backgroundColor = UIColor.whiteColor()
        self.bgView.addSubview(self.cropView)
        
        let cropViewPanGesture:UIPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(JCImageCropViewController.cropViewPanGesture(_:)))
        self.cropView.isUserInteractionEnabled = true
        self.cropView.addGestureRecognizer(cropViewPanGesture)
        
        let cropViewpinchGesture = UIPinchGestureRecognizer(target: self, action: #selector(JCImageCropViewController.handlePinchGesture(_: )))
        self.cropView.addGestureRecognizer(cropViewpinchGesture)
        
        
        let complentButton:UIButton = UIButton(type: .custom)
        complentButton.frame = CGRect(x:SCREEN_WIDTH-120, y:SCREEN_HEIGHT-64, width:100, height:44)
        complentButton.backgroundColor = colorWithRGB(19, g: 154, b: 235, a: 1)
        complentButton.setTitle("确定", for: UIControlState.init(rawValue: 0))
        complentButton.titleColor(for: UIControlState(rawValue: UInt(0)))
        complentButton.addTarget(self, action:#selector(JCImageCropViewController.complentButtonClick), for: .touchUpInside)
        self.view.addSubview(complentButton)
        complentButton.layer.cornerRadius = 22
        
        
        let cancalButton:UIButton = UIButton(type: .custom)
        cancalButton.frame = CGRect(x:20, y:SCREEN_HEIGHT-64, width:100, height:44)
        cancalButton.setTitle("取消", for:  UIControlState.init(rawValue: 0))
        cancalButton.addTarget(self, action: #selector(JCImageCropViewController.cancalButtonClcik), for: .touchUpInside)
        cancalButton.backgroundColor = colorWithRGB(19, g: 154, b: 235, a: 1)
        self.view.addSubview(cancalButton)
        cancalButton.layer.cornerRadius = 22
    }
    fileprivate func resetCropViewMask(){
        
        let path:UIBezierPath = UIBezierPath(rect: self.bgView.bounds)
        let clearPath:UIBezierPath = UIBezierPath(rect: CGRect(x:self.cropView.frame.minX+1, y:self.cropView.frame.minY+1, width:self.cropView.frame.width-2, height:self.cropView.frame.height-2)).reversing()
        path.append(clearPath)
        
        if let shapeLayer = self.bgView.layer.mask as? CAShapeLayer  {
            shapeLayer.path = path.cgPath
        }else{
            let shapeLayer:CAShapeLayer = CAShapeLayer()
            self.bgView.layer.mask = shapeLayer
            shapeLayer.path = path.cgPath
        }
        
    }
    
    
    func cropViewPanGesture(_ gesture:UIPanGestureRecognizer){
        
        let minX:CGFloat = self.imgV.frame.minX
        let maxX:CGFloat = self.imgV.frame.maxX - self.cropView.frame.width
        let minY = self.imgV.frame.minY
        let maxY = self.imgV.frame.maxY - self.cropView.frame.height
        
        if gesture.state == .began {
            startPoint = gesture.location(in: self.bgView)
            
            
            
        }else if gesture.state == .changed {
            let endPoint:CGPoint = gesture.location(in: self.bgView)
            
            var frame:CGRect = (self.cropView.frame)
            
            frame.origin.x += (endPoint.x - startPoint.x)
            frame.origin.y += (endPoint.y - startPoint.y)
            frame.origin.x = min(maxX, max(frame.origin.x, minX))
            frame.origin.y = min(maxY, max(frame.origin.y, minY))
            self.cropView.frame = frame
            startPoint = endPoint
        }
        self.view.layoutIfNeeded()
        resetCropViewMask()
        
    }
    
    func handlePinchGesture(_ pinchGesture: UIPinchGestureRecognizer){
        let factor = pinchGesture.scale
        
        if pinchGesture.state == .began {
            startSize = pinchGesture.view!.frame.size
        }
        
        if factor > 1{
            //图片放大
            self.cropView.transform = CGAffineTransform(scaleX: lastScaleFactor+factor-1, y: lastScaleFactor+factor-1)
            
            var  frame:CGRect = (pinchGesture.view!.frame)
            
            let maxWidth:CGFloat = min(frame.width, self.imgV.frame.width)
            
            
            let maxHight:CGFloat = min(frame.height, self.imgV.frame.height)
            
            let wscale:CGFloat = frame.width/self.imgV.frame.width
            let hscale:CGFloat = frame.height/self.imgV.frame.height
            
            
            frame.origin.x = max(self.imgV.frame.minX, min(frame.origin.x, (self.imgV.frame).maxX-frame.width))
            
            frame.origin.y = max(self.imgV.frame.minY,min(frame.origin.y, self.imgV.frame.maxY-frame.height) )
            
            self.cropView.frame = frame
            
            if  wscale>hscale {
                if maxWidth == self.imgV.frame.size.width{
                    
                    frame.size.width = maxWidth
                    frame.size.height = startSize.height/(startSize.width/maxWidth)
                    self.cropView.frame = frame
                    
                }
            }else{
                if maxHight == self.imgV.frame.size.height {
                    
                    frame.size.width = startSize.width/(startSize.height/maxHight)
                    frame.size.height = maxHight
                    self.cropView.frame = frame
                    
                }
            }
            
            
            
            
        }else{
            //缩小
            self.cropView.transform = CGAffineTransform(scaleX: lastScaleFactor*factor, y: lastScaleFactor*factor)
        }
        //状态是否结束，如果结束保存数据
        if pinchGesture.state == UIGestureRecognizerState.ended{
            if factor > 1{
                lastScaleFactor = lastScaleFactor + factor - 1
            }else{
                lastScaleFactor = lastScaleFactor * factor
            }
        }
        resetCropViewMask()
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        for touch:AnyObject in touches{
            touchBeginPoint = (touch as! UITouch).location(in: self.bgView)
            touchBeginCropViewRect = self.cropView.frame
            if (self.imgV.frame).contains(touchBeginPoint) {
                if !self.cropView.frame.contains(touchBeginPoint){
                    var frame:CGRect = (self.cropView.frame)
                    
                    frame.origin.x = min(self.cropView.frame.minX, touchBeginPoint.x)
                    frame.origin.y = min(self.cropView.frame.minY, touchBeginPoint.y)
                    
                    frame.size.width = (touchBeginPoint.x-self.cropView.frame.minX) > 0 ? max((touchBeginPoint.x-self.cropView.frame.minX), (self.cropView.frame).width) : (self.cropView.frame.maxX-touchBeginPoint.x)
                    
                    frame.size.height = (touchBeginPoint.y-self.cropView.frame.minY) > 0 ? max((touchBeginPoint.y-self.cropView.frame.minY), (self.cropView.frame).height) : (self.cropView.frame.maxY-touchBeginPoint.y)
                    
                    self.cropView.frame = frame
                    
                    resetCropViewMask()
                    
                }
            }
            
        }
        
        
    }
    
    override func touchesMoved( _ touches: Set<UITouch>, with event: UIEvent?) {
        for touch:AnyObject in touches{
            let touchEndPoint:CGPoint = (touch as! UITouch).location(in: self.bgView)
            if (self.imgV.frame).contains(touchBeginPoint) {
                if !touchBeginCropViewRect.contains(touchBeginPoint){
                    
                    var frame:CGRect = (self.cropView.frame)
                    
                    if (touchBeginPoint.x > touchBeginCropViewRect.minX)&&(touchBeginPoint.x < touchBeginCropViewRect.maxX) {
                        frame.origin.x = touchBeginCropViewRect.origin.x
                        frame.origin.y = touchBeginPoint.y > touchBeginCropViewRect.minY ? touchBeginCropViewRect.origin.y : min(max(touchEndPoint.y, self.imgV.frame.minY), touchBeginCropViewRect.maxY-10)
                        frame.size.width = self.cropView.frame.width
                        frame.size.height = touchBeginPoint.y > touchBeginCropViewRect.minY ? max(min(touchEndPoint.y - touchBeginCropViewRect.minY, self.imgV.frame.maxY-touchBeginCropViewRect.minY), 10) : max(min(touchBeginCropViewRect.maxY - touchEndPoint.y, touchBeginCropViewRect.maxY-self.imgV.frame.minY), 10)
                        
                    }else if (touchEndPoint.y > touchBeginCropViewRect.minY)&&(touchEndPoint.y < touchBeginCropViewRect.maxY){
                        
                        frame.origin.x = touchBeginPoint.x > touchBeginCropViewRect.minX ? touchBeginCropViewRect.origin.x : min(touchEndPoint.x, touchBeginCropViewRect.maxX-10)
                        frame.origin.y = touchBeginCropViewRect.origin.y
                        frame.size.width = touchBeginPoint.x > touchBeginCropViewRect.minX ? max(10, min(touchEndPoint.x - touchBeginCropViewRect.minX, self.imgV.frame.maxX-touchBeginCropViewRect.minX)) : max(10, min(touchBeginCropViewRect.maxX-touchEndPoint.x, touchBeginCropViewRect.maxX-self.imgV.frame.minX))
                        frame.size.height = touchBeginCropViewRect.height
                        
                    }else{
                        frame.origin.x = touchBeginPoint.x > touchBeginCropViewRect.minX ? touchBeginCropViewRect.origin.x : min(touchEndPoint.x, touchBeginCropViewRect.maxX-10)
                        frame.origin.y = touchBeginPoint.y > touchBeginCropViewRect.minY ? touchBeginCropViewRect.origin.y : min(max(touchEndPoint.y, self.imgV.frame.minY), touchBeginCropViewRect.maxY-10)
                        frame.size.width = touchBeginPoint.x > touchBeginCropViewRect.minX ? max(10, min(touchEndPoint.x - touchBeginCropViewRect.minX, self.imgV.frame.maxX-touchBeginCropViewRect.minX)) : max(10, min(touchBeginCropViewRect.maxX-touchEndPoint.x, touchBeginCropViewRect.maxX-self.imgV.frame.minX))
                        frame.size.height = touchBeginPoint.y > touchBeginCropViewRect.minY ? max(min(touchEndPoint.y - touchBeginCropViewRect.minY, self.imgV.frame.maxY-touchBeginCropViewRect.minY), 10) : max(min(touchBeginCropViewRect.maxY - touchEndPoint.y, touchBeginCropViewRect.maxY-self.imgV.frame.minY), 10)
                    }
                    
                    self.cropView.frame = frame
                    resetCropViewMask()
                    
                }
            }
        }
    }
    
    func complentButtonClick(){
        
        let cropAreaInImageView:CGRect = self.bgView.convert(self.cropView.frame, to: self.imgV)
        var cropAreaInImage:CGRect = CGRect()
        cropAreaInImage.origin.x = cropAreaInImageView.origin.x * imageScale
        cropAreaInImage.origin.y = cropAreaInImageView.origin.y * imageScale
        cropAreaInImage.size.width = cropAreaInImageView.size.width * imageScale
        cropAreaInImage.size.height = cropAreaInImageView.size.height * imageScale
        
        let image:UIImage = self.cropImage.imageAtRect(cropAreaInImage)
        let strings:String = readQRImage(image)
        
        if !strings.isEmpty {
            self.complentButtonBlock!(strings)
            self.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func cancalButtonClcik(){
        self.dismiss(animated: true, completion: nil)
        self.cancalButtonBlock!()
    }
    
    
    
    
    fileprivate func readQRImage(_ image:UIImage)->String{
        //二维码读取
        let ciImage:CIImage=CIImage(image:image)!
        let context = CIContext(options: nil)
        let detector:CIDetector=CIDetector(ofType: CIDetectorTypeQRCode,
                                           context: context, options: [CIDetectorAccuracy:CIDetectorAccuracyHigh])!
        let features=detector.features(in: ciImage)
        print("扫描到二维码个数：\(features.count)")
        
        var stringValue:String = ""
        
        if features.count<=0 {
            showAlert("提示", message: "无法解析图片",VC: self)
        }else {
            //遍历所有的二维码，并框出
            for feature in features as! [CIQRCodeFeature] {
                print(feature.messageString ?? String())
                stringValue = feature.messageString!
            }
        }
        return stringValue
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
