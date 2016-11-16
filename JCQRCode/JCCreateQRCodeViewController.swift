//
//  JCCreateQRCodeViewController.swift
//  JCQRCode
//
//  Created by jon on 16/11/15.
//  Copyright © 2016年 jon. All rights reserved.
//

import UIKit

class JCCreateQRCodeViewController: UIViewController {

    @IBOutlet weak var qrImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "生成二维码"
        // Do any additional setup after loading the view.
    }
    @IBAction func createQRCode(_ sender: AnyObject) {
       let qrImage  = self.createQRCodeImage(content: "www.baidu.com", size: CGSize(width: 300, height: 300))
        
//        self.qrImageView.image = qrImage
        
        self.qrImageView.image = self.addIconToQRCodeImage(image: qrImage, icon: UIImage(named: "icon.jpg")!, iconSize: CGSize(width: 100, height: 100))
    }
    
    //生成二维码
    private func createQRCodeImage(content:String,size:CGSize)->UIImage{
        let stringData = content.data(using: String.Encoding.utf8)
        let qrFilter = CIFilter(name: "CIQRCodeGenerator")
        
        qrFilter?.setValue(stringData, forKey: "inputMessage")
        qrFilter?.setValue("H", forKey: "inputCorrectionLevel")
        
        let colorFilter = CIFilter(name: "CIFalseColor")
        colorFilter?.setDefaults()
        
        colorFilter?.setValuesForKeys(["inputImage" : (qrFilter?.outputImage)!,"inputColor0":CIColor.init(cgColor: UIColor.black.cgColor),"inputColor1":CIColor.init(cgColor: UIColor.white.cgColor)])
        
        let qrImage = colorFilter?.outputImage
        let cgImage = CIContext(options: nil).createCGImage(qrImage!, from: (qrImage?.extent)!)
        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()
        context!.interpolationQuality = .none
        context!.scaleBy(x: 1.0, y: -1.0)
        context?.draw(cgImage!, in: (context?.boundingBoxOfClipPath)!)
        let codeImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return codeImage!
    }
   //向二维码中添加图片
    private func addIconToQRCodeImage(image:UIImage,icon:UIImage,iconSize:CGSize)->UIImage{
        UIGraphicsBeginImageContext(image.size)
        
        let imageWidth = image.size.width
        let imageHeight = image.size.height
        let iconWidth = iconSize.width
        let iconHeight = iconSize.height
        
        image.draw(in: CGRect(x: 0, y: 0, width: imageWidth, height: imageHeight))
        icon.draw(in: CGRect(x: (imageWidth-iconWidth)/2.0, y: (imageHeight-iconHeight)/2.0, width: iconWidth, height: iconHeight))
        let qrImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return qrImage!
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
