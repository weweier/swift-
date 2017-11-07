//
//  JCConst.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit
//屏幕宽
public var SCREEN_WIDTH: CGFloat {
    get{
        return UIScreen.main.bounds.size.width
       }
}

//屏幕高
public var SCREEN_HEIGHT: CGFloat {
    get {
         return UIScreen.main.bounds.size.height
        }
}

public func showAlert(_ title:String,message:String,VC:UIViewController){
    let alert:UIAlertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
    VC.present(alert, animated: true, completion: nil)
    let action:UIAlertAction = UIAlertAction(title: "确定", style: .default, handler: nil)
    alert.addAction(action)
}

public func colorWithRGB(_ r:CGFloat,g:CGFloat,b:CGFloat,a:CGFloat)->UIColor{
    return UIColor(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: a)
}

class JCConst: NSObject {

}
extension UIImage{
    
    func fixOrientation() -> UIImage {
        if (self.imageOrientation == .up) {
            return self
        }
        var transform = CGAffineTransform()//CGAffineTransformIdentity
        switch (self.imageOrientation) {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: self.size.height)
            transform = transform.rotated(by: .pi)
            break
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.rotated(by: .pi/2)
            break
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: self.size.height)
            transform = transform.rotated(by: -.pi/2)
            break
        default:
            break
        }
        switch (self.imageOrientation) {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: self.size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: self.size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
            break
        default:
            break
        }
        let ctx = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height),
                            bitsPerComponent: self.cgImage!.bitsPerComponent, bytesPerRow: 0,
                            space: self.cgImage!.colorSpace!,
                            bitmapInfo: self.cgImage!.bitmapInfo.rawValue)
        transform = (ctx?.ctm)!
        // ctx!.concatCTM(transform)
        switch (self.imageOrientation) {
        case .left, .leftMirrored, .right, .rightMirrored:
            
            ctx?.draw(self.cgImage!, in: CGRect(x:0,y:0,width:self.size.height,height:self.size.width))
            
            
            break
        default:
            ctx?.draw(self.cgImage!, in: CGRect(x:0,y:0,width:self.size.width,height:self.size.height))
            
            break
        }
        // And now we just create a new UIImage from the drawing context
        let cgimg = ctx!.makeImage()
        return UIImage(cgImage: cgimg!)//UIImage(CGImage: cgimg!)
    }
    
    func imageAtRect(_ rect:CGRect) -> UIImage{
        let imageRef:CGImage = self.cgImage!.cropping(to: rect)!
        let subImage:UIImage = UIImage(cgImage: imageRef)
        return subImage
        
    }
}
