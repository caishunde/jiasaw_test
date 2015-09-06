//
//  SubImageView.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

enum Direction
{
    case Up
    case Down
    case Left
    case Right
    case Center
}

enum Position
{
    case Center
    case Top
    case Bottom
    case Left
    case Right
    case TopLeft
    case TopRight
    case BottomLeft
    case BottomRight
    
    static func getPosition(row: Int, _ col: Int) -> Position
    {
        if (row == 0 && col == 0)
        {
            return TopLeft
        }
        
        if (row == 0 && col == Common.N - 1)
        {
            return TopRight
        }
        
        if (row == Common.N - 1 && col == 0)
        {
            return BottomLeft
        }
        
        if (row == Common.N - 1 && col == Common.N - 1)
        {
            return BottomRight
        }
        
        if (row == 0)
        {
            return Top
        }
        
        if (row == Common.N - 1)
        {
            return Bottom
        }
        
        if (col == 0)
        {
            return Left
        }
        
        if (col == Common.N - 1)
        {
            return Right
        }
        
        return Center
    }
}

class SquareView: UIImageView
{
    var isChangeSize: Bool = false
    
    
    init(sideLength: CGFloat)
    {
        super.init(frame: CGRectMake(0, 0, sideLength, sideLength))
        
        //imageView要添加手势必须设置此属性,如果父层是imageView,则父层也需要设置此属性
        userInteractionEnabled = true
        
        //拖动
        var panGesture = UIPanGestureRecognizer(target: self, action: "handlePanSquare:")
        addGestureRecognizer(panGesture)
        
    }
    
    func drawSquare()
    {
        UIGraphicsBeginImageContext(frame.size)
        var context = UIGraphicsGetCurrentContext()
        
        //正方形边框
        CGContextStrokeRectWithWidth(context, CGRectMake(0, 0, frame.width, frame.width), Common.cutLineWidth)
        
        //右下角小直角
        drawSmallTriangle(context)
        
        image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext()
    }
    
    //利用path进行绘制小直角
    func drawSmallTriangle(context: CGContext)
    {
        //直线宽度
        CGContextSetLineWidth(context, Common.cutLineWidth);
        CGContextBeginPath(context);
        
        //小直角和外框间隙像素
        let interval: CGFloat = 2
        CGContextMoveToPoint(context, bounds.width - Common.cutLineWidth - interval, bounds.height - Common.changeAreaSize);
        CGContextAddLineToPoint(context, bounds.width - Common.cutLineWidth - interval, bounds.height - Common.cutLineWidth - interval);
        CGContextAddLineToPoint(context, bounds.width - Common.changeAreaSize, bounds.height - Common.cutLineWidth - interval);
        
        CGContextStrokePath(context);
    }
    
    func handlePanSquare(panGesture:UIPanGestureRecognizer!)
    {
        switch panGesture.state
        {
        case .Began:
            let area = Common.changeAreaSize
            let point = panGesture.locationInView(self)
            //当前初始触摸点是右下角的时候,动作为调整截图框大小
            let changeRect = CGRectMake(frame.height - area, frame.height - area, area, area)
            if changeRect.contains(point)
            {
                isChangeSize = true
            }
            
        case .Changed:
            
            //相对偏移
            let offSet = panGesture.translationInView(self)
            
            if isChangeSize
            {
                let maxLength = min(superview!.frame.width - frame.origin.x, superview!.frame.height - frame.origin.y)
                let newSideLength = min(max(frame.width + min(offSet.x, offSet.y), 150), maxLength)
                frame.size = CGSize(width: newSideLength, height: newSideLength)
            }
            else
            {
                let newX = frame.origin.x + offSet.x
                let newY = frame.origin.y + offSet.y
                
                //只需要上下移动
                frame.origin.x = max(min(newX, superview!.frame.width - frame.width), 0)
                frame.origin.y = max(min(newY, superview!.frame.height - frame.height), 0)
            }
            
            panGesture.setTranslation(CGPointMake(0, 0), inView: self)
            break
            
        case .Ended, .Cancelled:
            isChangeSize = false
            break
            
        default:
            break
        }
    }
    
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class SubImageView: UIImageView
{
    var jigsawView: JigsawView! = nil
    var recognizer: UIPanGestureRecognizer!
    var index: Int = -1
    var indexUnion = Set<Int>()         //保存已匹配的相关联片
    
    var subViewList: [SubImageView] { return jigsawView.subViewList }
    var N: Int { return Common.N }
    var subSideLength: CGFloat { return jigsawView.subSideLength }
    
    var rightPosition: CGPoint? = nil   //正确位置,center,需要时计算,仅计算一次
    
    func getRigthPosition() -> CGPoint
    {
        if rightPosition == nil
        {
            rightPosition = calcRightPosition()
        }
        return rightPosition!
    }
    
    
    init(frame: CGRect, image: UIImage, jigsawView: JigsawView, index: Int)
    {
        super.init(frame: frame)
        self.image = image
        
        self.layer.shadowColor = UIColor.grayColor().CGColor
        self.layer.shadowOffset = CGSize(width: 5,height: 5)
        
        self.jigsawView = jigsawView
        self.index = index
        indexUnion.insert(index)
        
        //imageView或者父层是imageView,要添加手势必须设置此属性
        userInteractionEnabled = true
        
        recognizer = UIPanGestureRecognizer()
        
        recognizer.addTarget(self, action:"handleSwipeView:")
        
        addGestureRecognizer(recognizer)
    }
    
    required init(coder aDecoder: NSCoder)
    {
        fatalError("init(coder:) has not been implemented")
    }
    
    func handleSwipeView(panGesture:UIPanGestureRecognizer!)
    {
        switch panGesture.state
        {
        case .Began:
            //选中的子视图置顶显示
            frontShowUnion()
            return
            
        case .Changed, .Ended:
            //当前触摸点是否在可移动范围内,防止小片移出视图
            if !jigsawView.checkRect.contains(panGesture.locationInView(superview))
            {
                return
            }
            
            //相对偏移
            let offSet = panGesture.translationInView(self)
            
            //相关片整体移动
            moveUnion(offSet)
            
            panGesture.setTranslation(CGPointMake(0, 0), inView: self)
            
            //手指离开时进行匹配
            if (panGesture.state == .Ended)
            {
                matchAdjacentUnion()
            }
            
            break
            
        case .Cancelled:
            break
            
        default:
            break
        }
    }
    
    func frontShowUnion()
    {
        for i in indexUnion
        {
            subViewList[i].frontShow()
        }
    }
    
    private func frontShow()
    {
        //小片移到上层
        superview!.bringSubviewToFront(self)
        
        //popMenu按钮保持置顶
        jigsawView.viewCtrl.frontButton()
    }
    
    
    func moveUnion(offSet: CGPoint)
    {
        for i in indexUnion
        {
            subViewList[i].center.x += offSet.x
            subViewList[i].center.y += offSet.y
        }
    }
    
    func matchAdjacentUnion()
    {
        //先匹配精确位置
        if matchRightPosition()
        {
            return
        }
        
        //精确位置未匹配,再匹配相邻位置
        for i in indexUnion
        {
            if subViewList[i].matchAdjacent()
            {
                break
            }
        }
    }
    
    func matchRightPosition() -> Bool
    {
        let rightPosition = getRigthPosition()
        let distance = distanceBetweenPoints(center, rightPosition)
        if (distance < Common.near)
        {
            moveToAdjacentWithDirection(.Center, currentPoint: center, adjacentPoint: rightPosition)
            
            //匹配精确位置后,要靠后显示,并禁用手势固定住
            for i in indexUnion
            {
                subViewList[i].moveBackAndFixed()
            }
            
            return true
        }
        
        return false
    }
    
    func moveBackAndFixed()
    {
        superview?.sendSubviewToBack(self)
        userInteractionEnabled = false
        recognizer = nil
    }
    
    
    //一次匹配一片即可,提高性能
    func matchAdjacent() -> Bool
    {
        if matchDirection(.Left)
        {
            println("match left")
            return true
        }
        
        if matchDirection(.Up)
        {
            println("match up")
            return true
        }
        
        if matchDirection(.Right)
        {
            println("match right")
            return true
        }
        
        if matchDirection(.Down)
        {
            println("match down")
            return true
        }
        
        return false
    }
    
    func matchDirection(direction: Direction) -> Bool
    {
        var currentPoint = CGPoint()
        var adjacentPoint = CGPoint()
        var adjacentIndex = 0
        
        
        switch direction
        {
        case .Up:
            adjacentIndex = index - N
            
            if (adjacentIndex < 0) { return false }
            if indexUnion.contains(adjacentIndex) { return false }
            
            currentPoint = frame.origin
            adjacentPoint.x = subViewList[adjacentIndex].frame.origin.x
            adjacentPoint.y = subViewList[adjacentIndex].frame.origin.y + subSideLength
            
            break
            
        case .Down:
            adjacentIndex = index + N
            
            if (adjacentIndex >= N*N) { return false }
            if indexUnion.contains(adjacentIndex) { return false }
            
            currentPoint.x = frame.origin.x
            currentPoint.y = frame.origin.y + subSideLength
            adjacentPoint = subViewList[adjacentIndex].frame.origin
            break
            
        case .Left:
            adjacentIndex = index - 1
            
            if (index % N == 0) { return false }
            if indexUnion.contains(adjacentIndex) { return false }
            
            currentPoint = frame.origin
            adjacentPoint.x = subViewList[adjacentIndex].frame.origin.x + subSideLength
            adjacentPoint.y = subViewList[adjacentIndex].frame.origin.y
            break
            
        case .Right:
            adjacentIndex = index + 1
            
            if (adjacentIndex % N == 0) { return false }
            if indexUnion.contains(adjacentIndex) { return false }
            
            currentPoint.x = frame.origin.x + subSideLength
            currentPoint.y = frame.origin.y
            adjacentPoint = subViewList[adjacentIndex].frame.origin
            
        default:
            println("direction error!")
            return false
            
        }
        
        let distance = distanceBetweenPoints(currentPoint, adjacentPoint)
        if (distance < Common.near)
        {
            //整体吸附
            moveToAdjacentWithDirection(direction, currentPoint:currentPoint, adjacentPoint:adjacentPoint)
            
            //更新本片与相邻片的关联
            join2Union(adjacentIndex)
            
            return true
        }
        
        return false
    }
    
    func join2Union(index: Int)
    {
        indexUnion = indexUnion.union(subViewList[index].indexUnion)
        println(indexUnion)
        
        for i in indexUnion
        {
            subViewList[i].indexUnion = indexUnion
        }
    }
    
    func distanceBetweenPoints(first: CGPoint, _ second: CGPoint) -> CGFloat
    {
        let deltaX = second.x - first.x
        let deltaY = second.y - first.y
        
        return sqrt(deltaX*deltaX + deltaY*deltaY)
    }
    
    func moveToAdjacentWithDirection(direction: Direction, currentPoint: CGPoint, adjacentPoint: CGPoint)
    {
        var offSet = CGPoint()
        
        switch direction
        {
        case .Up, .Left:
            //            frame.origin = adjacentPoint
            offSet.x = adjacentPoint.x - frame.origin.x
            offSet.y = adjacentPoint.y - frame.origin.y
            break
            
        case .Down:
            //            frame.origin.x = adjacentPoint.x
            //            frame.origin.y = adjacentPoint.y - frame.width
            offSet.x = adjacentPoint.x - frame.origin.x
            offSet.y = adjacentPoint.y - frame.origin.y - subSideLength
            break
            
        case .Right:
            //            frame.origin.x = adjacentPoint.x - frame.width
            //            frame.origin.y = adjacentPoint.y
            offSet.x = adjacentPoint.x - frame.origin.x - subSideLength
            offSet.y = adjacentPoint.y - frame.origin.y
            break
            
        case .Center:
            offSet.x = adjacentPoint.x - currentPoint.x
            offSet.y = adjacentPoint.y - currentPoint.y
            break
            
        default:
            println("direction error!")
            return
        }
        
        moveUnion(offSet)
        
    }
    
    //计算小片的正确位置,中心
    private func calcRightPosition() -> CGPoint
    {
        println("calcRightPosition")
        
        let mainCenter = jigsawView.center
        
        let x = mainCenter.x + CGFloat((index % N) * 2 + 1 - N) * subSideLength / 2
        let y = mainCenter.y + CGFloat(Int(index / N) * 2 + 1 - N) * subSideLength / 2
        
        return CGPoint(x: x, y: y)
    }

    
    
}