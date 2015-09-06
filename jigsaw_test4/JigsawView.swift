//
//  JigsawView.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/9/5.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

class JigsawView: UIView
{
    var squareImageView: UIImageView! = nil
    var originImage: UIImage! = nil
    var checkRect: CGRect! = nil    //可移动范围
    var splitLineView: UIImageView! = nil

    var subViewList = [SubImageView]()
    
    var subSideLength: CGFloat = 0  //小片边长,不包含间隔

    var N:Int { return Common.N }
    
    var viewCtrl: JigsawViewCtrl! = nil

    
    func initJigsawView(viewCtrl: JigsawViewCtrl)
    {
//        println("initBigView")
//        bigView = UIView()
//        bigView.frame.origin.x = 0
//        bigView.frame.origin.y = Common.operAreaInterval
//        bigView.frame.size.width = frame.width
//        bigView.frame.size.height = frame.height - Common.operAreaInterval*2
//        
//        //透明
//        bigView.backgroundColor = UIColor.clearColor()
//        
//        //设置其子视图的显示不超出本视图范围
//        bigView.clipsToBounds = true
//        
//        //先禁用交互,否则会挡住块数选择器
//        bigView.userInteractionEnabled = false
//        
//        addSubview(bigView)
        
        self.viewCtrl = viewCtrl
        
        //可移动范围
        checkRect = CGRectMake(10, 10, frame.width - 10*2, frame.height - 10*2)

    }
    
    
    //展示原始图
    func showOriginImage(image: UIImage)
    {
        println("showOriginImage:\(image.size)")
        
        originImage = image

        //压缩图片
        //originImage = Common.scaleImage(originImage, scaleFactor: 0.5)
        
        //获取大正方形
        squareImageView = UIImageView(frame: getBigSquare())
        squareImageView.image = originImage
        
        addSubview(squareImageView)
        sendSubviewToBack(squareImageView)
    }
    
    func splitAndSeparate()
    {
        //分割
        splitImage()
        
        //用于展示的view销毁掉
        //        squareImageView.removeFromSuperview()
        //        squareImageView = nil
        
        //显示底框
        squareImageView.image = nil
        squareImageView.center = center
        squareImageView.layer.borderWidth = Common.showFrameWidth
        squareImageView.layer.borderColor = UIColor.whiteColor().CGColor
        
        //原图释放
        originImage = nil

        //分散
        separateImage()
    }

    
    
    //将图像分割成小片
    func splitImage()
    {
        //分割之前进行压缩
        originImage = Common.compressImage(originImage)
        
        //正方形
//        splitSquareImage()
        splitMultiSquareImage()
    }
    
    func prepareToStart()
    {
        splitLineView?.removeFromSuperview()
        
        //允许手势交互
        userInteractionEnabled = true
    }
    
    func splitSquareImage()
    {
        cleanSubViewList()
        
        let bigSquare = squareImageView.frame
        subSideLength = (bigSquare.width-(CGFloat(N-1))*Common.interval)/CGFloat(N)
        
        let imageW = CGFloat(originImage.size.width/CGFloat(N))
        let imageH = CGFloat(originImage.size.height/CGFloat(N))
        
        for(var row = 0; row < N; ++row)
        {
            for (var col = 0; col < N; ++col)
            {
                let subImageRect = CGRectMake(imageW * CGFloat(col), imageH * CGFloat(row), imageW, imageH)
                let subImage = Common.getImage(originImage, rect: subImageRect)
                
                let subRect = CGRectMake((subSideLength + Common.interval) * CGFloat(col) + bigSquare.origin.x - frame.origin.x,
                    (subSideLength + Common.interval) * CGFloat(row) + bigSquare.origin.y - frame.origin.y,
                    subSideLength, subSideLength)
                let sv = SubImageView(frame: subRect, image: subImage, jigsawView: self, index: row * N + col)
                
                addSubview(sv)
                subViewList.append(sv)
            }
        }
    }

    
    func splitMultiSquareImage()
    {
        drawMultiSquare(true)
    }
    
    //画多边形, 参数needSplitImage 需要切割, 否则只画线
    func drawMultiSquare(needSplitImage: Bool)
    {
        cleanSubViewList()
        
        subSideLength = (squareImageView.frame.width-(CGFloat(N-1))*Common.interval) / CGFloat(N)
        let offset = subSideLength / 4
        
        let cgImage = squareImageView.image!.CGImage
        let imageWidth = squareImageView.image!.size.width
        let imageInterval = imageWidth / CGFloat(N)
        let imageOffset = imageInterval/4
        
        var contextSize = CGSize(width: imageInterval + imageOffset*2, height: imageInterval + imageOffset*2)
        
        for(var row = 0; row < N; ++row)
        {
            for (var col = 0; col < N; ++col)
            {
                UIGraphicsBeginImageContext(contextSize)
                let ct = UIGraphicsGetCurrentContext()
                
                //宽度和颜色
                //CGContextSetLineWidth(ct, 2);
                CGContextSetRGBStrokeColor(ct, 1, 1, 1, 1)
                
                let position = Position.getPosition(row, col)
                
                drawPaths(ct, position, imageInterval, imageOffset)
                
                if needSplitImage
                {
                    CGContextClip(ct)
                }
                else
                {
                    CGContextStrokePath(ct)
                }
                
                //坐标系转换
                //因为CGContextDrawImage会使用Quartz内的以左下角为(0,0)的坐标系
                if needSplitImage
                {
                    var rx = -(CGFloat(col)*imageInterval-imageOffset)
                    var ry = CGFloat(row)*imageInterval-imageOffset
                    
                    //路径的位置固定,然后利用这个矩形的位置,来截取需要的小图
                    let rect = CGRectMake(rx, ry, imageWidth, imageWidth)
                    
                    CGContextTranslateCTM(ct, 0, imageWidth)
                    CGContextScaleCTM(ct, 1, -1);
                    CGContextDrawImage(ct, rect, cgImage)
                }
                
                let subImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let subRect = CGRectMake(squareImageView.frame.origin.x + CGFloat(col) * (subSideLength+Common.interval) - offset,
                    squareImageView.frame.origin.y + CGFloat(row) * (subSideLength+Common.interval) - offset,
                    subSideLength+offset*2, subSideLength+offset*2)
                
                var sv = SubImageView(frame: subRect, image: subImage, jigsawView: self, index: row * N + col)
                
                if needSplitImage
                {
                    addSubview(sv)
                }
                else
                {
                    sv.frame.origin.x -= squareImageView.frame.origin.x
                    sv.frame.origin.y -= squareImageView.frame.origin.y
                    squareImageView.addSubview(sv)
                }
                
                subViewList.append(sv)
            }
        }
    }
    
    
    private func drawPaths(ct: CGContextRef, _ position: Position, _ imageInterval: CGFloat, _ imageOffset: CGFloat)
    {
        CGContextBeginPath(ct)
        
        //原点
        CGContextMoveToPoint(ct, imageOffset, imageOffset)
        
        switch position
        {
        case .Center, .Left:
            CGContextAddLineToPoint(ct, imageOffset*2, 0)
            CGContextAddLineToPoint(ct, imageInterval, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageOffset)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset*2, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval+imageOffset*2)
            CGContextAddLineToPoint(ct, imageOffset*2, imageInterval)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            if (position == .Center)
            {
                CGContextAddLineToPoint(ct, 0, imageInterval)
                CGContextAddLineToPoint(ct, imageOffset*2, imageOffset*2)
            }
            
            break
            
        case .Top, .TopLeft:
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageOffset)
            CGContextAddLineToPoint(ct, imageInterval+2*imageOffset, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval+imageOffset*2)
            CGContextAddLineToPoint(ct, 2*imageOffset, imageInterval)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            if position == .Top
            {
                CGContextAddLineToPoint(ct, 0, imageInterval)
                CGContextAddLineToPoint(ct, 2*imageOffset, imageOffset*2)
            }
            break
            
        case .Bottom, .BottomLeft:
            CGContextAddLineToPoint(ct, imageOffset*2, 0)
            CGContextAddLineToPoint(ct, imageInterval, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageOffset)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset*2, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval)
            
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            if position == .Bottom
            {
                CGContextAddLineToPoint(ct, 0, imageInterval)
                CGContextAddLineToPoint(ct, 2*imageOffset, imageOffset*2)
            }
            break
            
        case .Right, .TopRight:
            if (position == .Right)
            {
                CGContextAddLineToPoint(ct, imageOffset*2, 0)
                CGContextAddLineToPoint(ct, imageInterval, imageOffset*2)
            }
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageOffset)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageInterval, imageInterval+imageOffset*2)
            CGContextAddLineToPoint(ct, imageOffset*2, imageInterval)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, 0, imageInterval)
            CGContextAddLineToPoint(ct, imageOffset*2, imageOffset*2)
            
            break
            
        case .BottomRight:
            CGContextAddLineToPoint(ct, imageOffset*2, 0)
            CGContextAddLineToPoint(ct, imageInterval, imageOffset*2)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageOffset)
            CGContextAddLineToPoint(ct, imageInterval+imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, imageOffset, imageInterval+imageOffset)
            CGContextAddLineToPoint(ct, 0, imageInterval)
            CGContextAddLineToPoint(ct, imageOffset*2, imageOffset*2)
            
            
            break
        default:
            break
        }
        
        CGContextClosePath(ct)
        
    }
    
    
    //随机分离小片到四周
    func separateImage()
    {
        for (var i = 0; i < Int(N*N); ++i)
        {
            //0,1上下,2,3左右
            let areaIndex = arc4random() % 2
            let randPoint = genRandPointInArea(areaIndex)
            
            moveSubImage2Point(i, point: randPoint)
        }
        
    }
    
    //分四个区域生成随机点
    func genRandPointInArea(areaIndex: UInt32) -> CGPoint
    {
        var minX: CGFloat = 0
        var rangeX: CGFloat = 0
        var minY: CGFloat = 0
        var rangeY: CGFloat = 0
        
        switch areaIndex
        {
        case 0: //上, 左上角有按钮,不要分散到左上角
            minX = frame.origin.x + frame.width/4
            rangeX = frame.width*3/4
            minY = frame.origin.y / CGFloat(Common.separateRange)
            rangeY = frame.height / CGFloat(Common.separateRange)
            break
            
        case 1: //下
            minX = frame.origin.x
            rangeX = frame.width
            minY = frame.origin.y + frame.height * CGFloat(Common.separateRange-1) / CGFloat(Common.separateRange)
            rangeY = frame.height / CGFloat(Common.separateRange)
            break
            
        case 2: //左
            minX = frame.origin.x
            rangeX = frame.width / CGFloat(Common.separateRange)
            minY = frame.origin.y
            rangeY = frame.height
            break
            
        case 3: //右
            minX = frame.origin.x + frame.width * CGFloat(Common.separateRange-1) / CGFloat(Common.separateRange)
            rangeX = frame.width / CGFloat(Common.separateRange)
            minY = frame.origin.y
            rangeY = frame.height
            break
            
        default:
            println("error!")
            break
        }
        
        //记得转换坐标系
        let x = (CGFloat)(arc4random() % UInt32(rangeX)) + minX - frame.origin.x
        let y = (CGFloat)(arc4random() % UInt32(rangeY)) + minY - frame.origin.y
        
        return CGPointMake(x, y)
    }

    //将中心移到指定点
    func moveSubImage2Point(index: Int, point: CGPoint) -> Bool
    {
        if (index < 0 || index >= Int(N*N))
        {
            println("invalid index: \(index)")
            return false
        }
        
        let newOrigin = CGPointMake(point.x - subSideLength / 2, point.y - subSideLength / 2)
        
        UIView.animateWithDuration(1)
        {
            self.subViewList[index].frame.origin = newOrigin
        }
        
        return true
    }
    
    func cleanAll()
    {
        cleanSubViewList()
    }
    
    func cleanSubViewList()
    {
        for subView in subViewList
        {
            subView.removeFromSuperview()
        }
        subViewList.removeAll(keepCapacity: false)
    }
    
    
    /////////////////////////
    //画分割线
    private func drawSplitLine()
    {
        splitLineView?.removeFromSuperview()
        splitLineView = UIImageView(frame: squareImageView.frame)
        
        UIGraphicsBeginImageContext(splitLineView.frame.size)
        let context = UIGraphicsGetCurrentContext()
        
        //宽度和颜色
        CGContextSetLineWidth(context, 1);
        CGContextSetRGBStrokeColor(context, 1, 1, 1, 1)
        
        let interval = splitLineView.frame.width / CGFloat(N)
        
        for(var i = 0; i <= N; ++i)
        {
            var beginPoint = CGPoint(x: CGFloat(i) * interval, y: 0)
            var endPoint = CGPoint(x: CGFloat(i) * interval, y: splitLineView.frame.height)
            
            drawLine(context, begin: beginPoint, end: endPoint)
            
            beginPoint = CGPoint(x: 0, y: CGFloat(i) * interval)
            endPoint = CGPoint(x: splitLineView.frame.width, y: CGFloat(i) * interval)
            
            drawLine(context, begin: beginPoint, end: endPoint)
        }
        
        splitLineView.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
        
        addSubview(splitLineView)
    }
    
    private func drawLine(context: CGContext, begin: CGPoint, end: CGPoint)
    {
        CGContextBeginPath(context);
        
        CGContextMoveToPoint(context, begin.x, begin.y);
        CGContextAddLineToPoint(context, end.x, end.y);
        
        CGContextStrokePath(context);
    }

    //获取大正方形,中心区域
    private func getBigSquare() -> CGRect
    {
        let sideLength = min(frame.width, frame.height) - 10
        println("sideLength: \(sideLength)")
        
        var temp = CGRectInset(frame, (frame.width - sideLength)/2, (frame.height - sideLength)/2)
        
        temp.origin.y -= 40
        
        return temp
    }

    
    
    
}
