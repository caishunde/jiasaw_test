//
//  SaveImageViewCtrl.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/30.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

class SaveImageViewCtrl: UIViewController
{
    var imageMgr: ImageManager { return ImageManager.imageMgr }
    var selectImageView: UIImageView! = nil
    var squareView: SquareView! = nil

    override func viewDidLoad()
    {
        println("viewDidLoad")
        super.viewDidLoad()
        
        setNavigationbar()
        
    }
    
    func setNavigationbar()
    {
        let navigationBar = UINavigationBar(frame:CGRectMake(0, 0, view.frame.size.width, 60))
        
        //创建UINavigationItem
        var navItem = UINavigationItem(title: "")
        navigationBar.pushNavigationItem(navItem, animated: true)
        view.addSubview(navigationBar)
        
        //创建UIBarButton 可根据需要选择适合自己的样式
        let item = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.Cancel, target: self, action: "backButton:")
        
        //设置barbutton
        navItem.leftBarButtonItem = item;
        navigationBar.setItems([navItem], animated: true)
    }
    
    func backButton(button: UIBarButtonItem)
    {
        dismissViewControllerAnimated(true, completion: nil)
    }

    func setImageViewWithImage(image: UIImage)
    {
        println("set image")
        
        //展示选择的图片
        showSelectImage(image)
        
        //显示剪裁框
        showCutFrame()
    }
    
    @IBAction func cutAndSave(sender: UIButton)
    {
        if (selectImageView == nil)
        {
            return
        }
        
        let image = selectImageView.image!

        println("cutAndSave:\(image.size)")
        
        let x = image.size.width * squareView.frame.origin.x / selectImageView.frame.width
        let y = image.size.height * squareView.frame.origin.y / selectImageView.frame.height
        let sideLength = image.size.width * squareView.frame.width / selectImageView.frame.width
        let subImageRect = CGRectMake(x, y, sideLength, sideLength)
        let subImage = Common.getImage(image, rect: subImageRect)
        
        //保存结果
        imageMgr.saveImage(subImage)
        
        //释放subview
        squareView?.removeFromSuperview()
        squareView = nil
        selectImageView?.removeFromSuperview()
        selectImageView = nil
        
        //返回
        back()
        
        //直接跳转到拼图界面, 不能在这里直接跳转, 因为back之后的windows还没渲染完,会错乱
        Common.needPopJigsawVC = true
        Common.popImage = subImage
    }
    
    
    //这个frame的大小需要精确计算,确保原始图片比例不失真
    func showSelectImage(image: UIImage)
    {
        var bigView = view

        var width = bigView.frame.width
        var hight = image.size.height * bigView.frame.width / image.size.width
        let maxHight = bigView.frame.height - Common.minButtomInterval * 2
        if (hight > maxHight)
        {
            hight = maxHight
            width = image.size.width * hight / image.size.height
        }
        let x = bigView.center.x - width / 2
        let y = bigView.center.y - hight / 2
        let showFrame = CGRectMake(x, y, width, hight)
        
        selectImageView = UIImageView(frame: showFrame)
        
        selectImageView.image = image
        selectImageView.userInteractionEnabled = true
        
        view.addSubview(selectImageView)
    }
    
    func showCutFrame()
    {
        squareView = SquareView(sideLength: min(selectImageView.frame.width, selectImageView.frame.height))
        squareView.drawSquare()
        selectImageView.addSubview(squareView)
    }

    func back()
    {
        dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    
    
    
    
    
    
    
    
    
    
}
