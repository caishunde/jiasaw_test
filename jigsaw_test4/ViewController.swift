//
//  ViewController.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit



class ViewController: UICollectionViewController
{
    var imageMgr: ImageManager { return ImageManager.imageMgr }
    
    @IBOutlet var mCollectView: UICollectionView!
    
    private var mDelegateImagesVC: ImagesViewCtrl? = nil

    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        println("===========here we gogogogogogog========")
        println("===========here we gogogogogogog========")
        println("===========here we gogogogogogog========")
        println("===========here we gogogogogogog========")
        
        self.navigationItem.title = "World"
        
        imageMgr.setDelegate(self)
        imageMgr.loadDirList()
        
        setBackground()
    
    }
    
    func setBackground()
    {
        println("setBackground")
        let bgImage = UIImage(named: "bg1.jpg")
        view.backgroundColor = UIColor(patternImage: bgImage!)
        collectionView!.backgroundColor = UIColor.clearColor()
    }

    
    
    func updateView()
    {
        println("vc updateView")
        //刷新目录
        mCollectView.reloadData()
        
        //刷新所有的图
        mDelegateImagesVC?.updateView()
    }

   


    
    ////////// collectionView 协议 ///////////
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath)
    {
        self.selectedIndexPath = indexPath
        imageMgr.setDirIndex(indexPath.row)
        
        var vc = self.storyboard?.instantiateViewControllerWithIdentifier("imageVC") as? ImagesViewCtrl
        
        mDelegateImagesVC = vc
        
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell
    {
        var cell = collectionView.dequeueReusableCellWithReuseIdentifier("dirCell", forIndexPath: indexPath) as! DirCollectViewCell
        
        cell.initByIndex(indexPath.row)
        
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return imageMgr.dirCount
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int
    {
        return 1
    }
    
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

//        //第一个目录是自定义,需要嵌入"添加图片"按钮
//        if indexPath.row == 0
//        {
//            println("add new button")
//            var newButton = UIButton(frame: CGRectMake(0, 0, 100, 100))
//            newButton.setTitle("添加图片", forState: UIControlState.Normal)
//            newButton.backgroundColor = UIColor.greenColor()
//            vc?.view.addSubview(newButton)
//        }
