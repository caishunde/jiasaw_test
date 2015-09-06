//
//  DirCollectViewCell.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

class DirCollectViewCell: UICollectionViewCell
{
    
    @IBOutlet weak var dirIconImage: UIImageView!
    
    
    
    @IBOutlet weak var dirTitle: UILabel!
    
    func initByIndex(index: Int)
    {
        dirTitle.text = ImageManager.imageMgr.getDirNameByIndex(index)
        dirIconImage.image = ImageManager.imageMgr.getDirIconImage(index)
        dirIconImage.layer.cornerRadius = Common.cornerRadius
        dirIconImage.layer.masksToBounds = true
        
        dirIconImage.layer.borderColor = UIColor.whiteColor().CGColor
        dirIconImage.layer.borderWidth = 0.5
        
        setBackground()
    }
    
    func setBackground()
    {
        let image = UIImage(named: "bg7")
        backgroundView = UIImageView(image: image)
        backgroundView?.frame = dirIconImage.frame
        backgroundView?.frame.origin.y = dirIconImage.frame.origin.y + 8
    }
    
    
}

class ImageCollectViewCell: UICollectionViewCell
{
    @IBOutlet weak var imageIcon: UIImageView!
    
    func initByIndex(index: Int)
    {
        imageIcon.image = ImageManager.imageMgr.getImageByFileIndex(index)
        
        imageIcon.layer.shouldRasterize = false
        //设置圆角
//        imageIcon.layer.cornerRadius = Common.cornerRadius
//        imageIcon.layer.masksToBounds = true
        
        imageIcon.layer.shadowColor = UIColor.grayColor().CGColor
        imageIcon.layer.shadowOffset = CGSizeMake(3, 8)
        imageIcon.layer.shadowOpacity = 0.8
//        imageIcon.layer.shadowRadius = 5

    }
}







