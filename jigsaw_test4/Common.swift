//
//  Common.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/30.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

//公共区,全局区
class Common
{
    static let interval: CGFloat = 0            //切割小片时间隔的像素
    static let near: CGFloat = 10               //靠近的像素,小于该距离时自动吸附
    static let cutLineWidth: CGFloat = 5        //剪裁框线宽度
    static let changeAreaSize: CGFloat = 40     //剪裁框右下角,缩放框的触摸区大小
    static let minButtomInterval: CGFloat = 80  //剪裁框离底部最小距离
    static let operAreaInterval: CGFloat = 50   //触摸区离上下边缘的距离
    static let pickerDefaultRow = 1             //块数选择器默认行数,第二行,块数(1+3)*(1+3)
    static let cornerRadius:CGFloat = 5         //缩略图圆角半径
    static let showFrameWidth:CGFloat = 2       //展示框的边框宽度
    static let separateRange = 5                //分散碎片的时候分散在上下左右边缘的1/M处
    
    static var N = 4                            //拆分行列数,N*N
    
    static var needPopJigsawVC = false          //剪裁完直接跳转到对应的拼图界面
    static var popImage: UIImage? = nil         //剪裁完的图片
    
    
    //截图
    static func getImage(img: UIImage, rect: CGRect) -> UIImage
    {
        let tempImage = fixOrientation(img)
        let imagePartRef = CGImageCreateWithImageInRect(tempImage.CGImage, rect)
        
        return UIImage(CGImage: imagePartRef)!
    }
    
    static func compressImage(image: UIImage) -> UIImage
    {
        //这里直接用1,不进行压缩,也有明显效果,何解?画质应该降了
        let scaleFactor:CGFloat = 1
        
        return compressImageWithScale(image, scaleFactor: scaleFactor)
    }
    
    
    //压缩图片,长宽等比压缩
    private static func compressImageWithScale(image: UIImage, scaleFactor: CGFloat) -> UIImage
    {
        println("scaleImage:\(image.size)")
        var size = CGSizeMake(image.size.width * scaleFactor, image.size.height * scaleFactor)
        
        UIGraphicsBeginImageContext(size)
        var context = UIGraphicsGetCurrentContext()
        var transform = CGAffineTransformIdentity
        
        transform = CGAffineTransformScale(transform, scaleFactor, scaleFactor)
        CGContextConcatCTM(context, transform)
        
        image.drawAtPoint(CGPointMake(0,0))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        println("after scaleImage:\(newImage.size)")

        
        return newImage
    }

    
    static func fixOrientation(img:UIImage) -> UIImage
    {
        if (img.imageOrientation == UIImageOrientation.Up)
        {
            return img;
        }
        
        UIGraphicsBeginImageContextWithOptions(img.size, false, img.scale);
        let rect = CGRect(x: 0, y: 0, width: img.size.width, height: img.size.height)
        img.drawInRect(rect)
        
        var normalizedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        return normalizedImage;
    }
    
    
    /*
    func fixOrientation(img: UIImage) -> UIImage
    {
    if (img.imageOrientation == UIImageOrientation.Up)
    {
    return img;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    var transform:CGAffineTransform = CGAffineTransformIdentity
    
    if (img.imageOrientation == UIImageOrientation.Down || img.imageOrientation == UIImageOrientation.DownMirrored)
    {
    transform = CGAffineTransformTranslate(transform, img.size.width, img.size.height)
    transform = CGAffineTransformRotate(transform, CGFloat(M_PI))
    }
    
    if (img.imageOrientation == UIImageOrientation.Left || img.imageOrientation == UIImageOrientation.LeftMirrored)
    {
    transform = CGAffineTransformTranslate(transform, img.size.width, 0)
    transform = CGAffineTransformRotate(transform, CGFloat(M_PI_2))
    }
    
    if (img.imageOrientation == UIImageOrientation.Right || img.imageOrientation == UIImageOrientation.RightMirrored)
    {
    transform = CGAffineTransformTranslate(transform, 0, img.size.height);
    transform = CGAffineTransformRotate(transform,  CGFloat(-M_PI_2));
    }
    
    if (img.imageOrientation == UIImageOrientation.UpMirrored || img.imageOrientation == UIImageOrientation.DownMirrored)
    {
    transform = CGAffineTransformTranslate(transform, img.size.width, 0)
    transform = CGAffineTransformScale(transform, -1, 1)
    }
    
    if (img.imageOrientation == UIImageOrientation.LeftMirrored || img.imageOrientation == UIImageOrientation.RightMirrored)
    {
    transform = CGAffineTransformTranslate(transform, img.size.height, 0);
    transform = CGAffineTransformScale(transform, -1, 1);
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    var ctx:CGContextRef = CGBitmapContextCreate(nil, Int(img.size.width), Int(img.size.height),
    CGImageGetBitsPerComponent(img.CGImage), 0,
    CGImageGetColorSpace(img.CGImage),
    CGImageGetBitmapInfo(img.CGImage));
    CGContextConcatCTM(ctx, transform)
    
    
    if (img.imageOrientation == UIImageOrientation.Left
    || img.imageOrientation == UIImageOrientation.LeftMirrored
    || img.imageOrientation == UIImageOrientation.Right
    || img.imageOrientation == UIImageOrientation.RightMirrored
    )
    {
    CGContextDrawImage(ctx, CGRectMake(0,0,img.size.height,img.size.width), img.CGImage)
    }
    else
    {
    CGContextDrawImage(ctx, CGRectMake(0,0,img.size.width,img.size.height), img.CGImage)
    }
    
    
    // And now we just create a new UIImage from the drawing context
    var cgimg:CGImageRef = CGBitmapContextCreateImage(ctx)
    var imgEnd:UIImage = UIImage(CGImage: cgimg)!
    
    return imgEnd
    }
    */
    
}
