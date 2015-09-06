//
//  ImagesViewCtrl.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

class ImagesViewCtrl: UICollectionViewController, UIImagePickerControllerDelegate,UINavigationControllerDelegate, UIGestureRecognizerDelegate
{
    var imageMgr: ImageManager { return ImageManager.imageMgr }

    @IBOutlet var mCollectView: UICollectionView!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setBackground()
        
        //左侧右滑返回,enable默认为true
        //self.navigationController?.interactivePopGestureRecognizer.delegate = self
        ////self.navigationController?.interactivePopGestureRecognizer.enabled = true
        
        //右滑返回
        var swipeGesture = UISwipeGestureRecognizer(target: self, action: "swipeGesture:")
        swipeGesture.direction = UISwipeGestureRecognizerDirection.Right
        mCollectView.addGestureRecognizer(swipeGesture)
    }
    
    override func viewDidAppear(animated: Bool)
    {
        //从剪裁界面回来之后,跳转至拼图界面
        if Common.needPopJigsawVC
        {
            //直接跳转到拼图界面
            var vc = self.storyboard?.instantiateViewControllerWithIdentifier("jigsawVC") as! JigsawViewCtrl

            presentViewController(vc, animated: true, completion: nil)
            vc.setOriginJigsawImage(Common.popImage!)
            
            Common.needPopJigsawVC = false
            Common.popImage = nil
        }
    }
    
    func setBackground()
    {
        println("setBackground")
        let bgImage = UIImage(named: "bg1.jpg")
        view.backgroundColor = UIColor(patternImage: bgImage!)
        collectionView!.backgroundColor = UIColor.clearColor()
    }

    
    func swipeGesture(swipeGesture:UISwipeGestureRecognizer!)
    {
        //返回上一级
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func updateView()
    {
        println("update view")
        mCollectView.reloadData()
    }
    
    
    func openImage()
    {
        println("openImage")
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        presentViewController(picker, animated: true, completion: nil)
        
        /*
        //展示照片选择器
        if UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiom.Phone  //iphone
        {
        self.presentViewController(picker, animated: true, completion: nil)
        println("iphone")
        }
        else    //ipad
        {
        println("ipad")
        var popover =  UIPopoverController(contentViewController:picker)
        
        popover.presentPopoverFromRect(CGRectMake(0, 0, 300, 300), inView: view, permittedArrowDirections: UIPopoverArrowDirection.Any, animated: true)
        }
        */
        
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!)
    {
        //收起照片选择器
        picker.dismissViewControllerAnimated(true, completion: nil)

        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("saveImageVC") as! SaveImageViewCtrl
        
        presentViewController(vc, animated: true, completion: nil)
        vc.setImageViewWithImage(image)
    }
    
    func longPressHandle(longPress: UILongPressGestureRecognizer)
    {
        if longPress.state != .Began
        {
            return
        }
        
        let index = longPress.view!.tag
        
        //弹出对话框确认是否删除
        confirmDelete(index)
        
    }
    
    private func confirmDelete(index: Int)
    {
        let alertCtrl = UIAlertController(title: "删除图片", message: "您确定要删除该图片吗?", preferredStyle: .Alert)
        let deleteAction = UIAlertAction(title: "删除", style: .Destructive)
        {
            (action: UIAlertAction!) -> Void in
            
            println("delete index:\(index)!")
            
            //删数据就通知重载了,不需要下面那句
            self.imageMgr.removeFileByIndex(index)
            //mCollectView.deleteItemsAtIndexPaths([NSIndexPath(forItem: index, inSection: 0)])
        }
        
        var cancelAction = UIAlertAction(title: "取消", style: .Default)
        {
            (action: UIAlertAction!) -> Void in
            println("cancel delete.")
        }
        
        alertCtrl.addAction(deleteAction)
        alertCtrl.addAction(cancelAction)
        
        presentViewController(alertCtrl, animated: true, completion: nil)
    }
    
    //////// collectionView 协议 /////////
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedIndexPath = indexPath
        imageMgr.setFileIndex(indexPath.row)
        if imageMgr.isSelectedAddButton
        {
            openImage()
            return
        }
        
        let imageCell = collectionView.cellForItemAtIndexPath(indexPath) as! ImageCollectViewCell
        
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("jigsawVC") as! JigsawViewCtrl
        
        presentViewController(vc, animated: true, completion: nil)
        vc.setOriginJigsawImage(imageCell.imageIcon.image!)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("imageCell", forIndexPath: indexPath) as! ImageCollectViewCell
        
        cell.initByIndex(indexPath.row)
        
        //自定义目录,除了第一个元素,其他的可以删除,通过长按手势
        if (imageMgr.mDirIndex == 0 && indexPath.row != 0)
        {
            var longPress = UILongPressGestureRecognizer(target: self, action: "longPressHandle:")
            longPress.minimumPressDuration = 0.6
            cell.tag = indexPath.row
            cell.addGestureRecognizer(longPress)
        }
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imageMgr.imageCount
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
}