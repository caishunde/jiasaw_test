//
//  ImageManager.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit

struct DirInfo
{
    var path = String()         //目录,包含路径
    var fileList = [String]()   //该目录下文件列表,不包含路径,第一个元素是添加图片按钮
}

//自定义目录放在目录列表的第一个//test
class ImageManager
{
    //单例
    private init()
    {
        println("sigle mode! can't declear ImageManager")
    }
    
    static var imageMgr = ImageManager()

    var mDirIndex = 0                         //当前目录index
    var mFileIndex = 0                        //当前目录选中的文件index
    private var mFileMgr = NSFileManager()
    private var mDelegate: ViewController? = nil
    
    var mDirList = [DirInfo]()                //第一个元素为自定义目录
    {
        //数据更新时通知视图刷新
        didSet
        {
//            printInfo()
            mDelegate?.updateView()
        }
    }
    
    ////// 计算属性 //////
    var dirCount: Int { return mDirList.count }
    var imageCount: Int { return mDirList[mDirIndex].fileList.count }
    var isSelectedAddButton: Bool { return mDirIndex == 0 && mFileIndex == 0 }

    
    
    
    
    func printInfo()
    {
        for dirInfo in mDirList
        {
            println(dirInfo.path)
            println(dirInfo.fileList)
        }
        println(mDirIndex)
    }
    
    func setDirIndex(index: Int)
    {
        mDirIndex = index
    }
    
    func setFileIndex(index: Int)
    {
        mFileIndex = index
    }
    
    func setDelegate(delegate: ViewController)
    {
        mDelegate = delegate
    }
    
    
    func removeFileByIndex(index: Int) -> Bool
    {
        let path = mDirList[mDirIndex].path + "/" + mDirList[mDirIndex].fileList[index]
        println("prepare delete \(path)")
        
        var error: NSErrorPointer = nil
        if !mFileMgr.removeItemAtPath(path, error: error)
        {
            println("removeItemAtPath error! path[\(path)]")
            println(error)
            return false
        }
        mDirList[mDirIndex].fileList.removeAtIndex(index)
        return true
    }

    //加载所有目录,仅加载目录名称,不加载内容
    func loadDirList() -> Bool
    {
        if !loadCustomDir()
        {
            println("loadCustomDir error!")
            return false
        }
        
        if !loadFixedDir()
        {
            println("loadFixedDir error!")
            return false
        }
        
        printInfo()
        
        return true
    }
    
    func getDirNameByIndex(index: Int) -> String
    {
        return mDirList[index].path.componentsSeparatedByString("/").last! as String
    }
    
    func getDirIconImage(index: Int) -> UIImage?
    {
        //如果目录下没有文件,则采用默认封面,以目录名命名的,在images.xcassets中
        //第一个目录是自定义目录,特殊处理
        if mDirList[index].fileList.isEmpty || (index == 0 && mDirList[index].fileList.count == 1)
        {
            let dirName = mDirList[index].path.componentsSeparatedByString("/").last! as String
            return UIImage(named: dirName)
        }
        
        let lastFileInDir = mDirList[index].path + "/" + mDirList[index].fileList.last!
        
        return UIImage(named: lastFileInDir)
    }
    
    func getImageByFileIndex(index: Int) -> UIImage?
    {
        let dirInfo = mDirList[mDirIndex]
        let path = dirInfo.path + "/" + dirInfo.fileList[index]
        let image = UIImage(named: path)
        
        let attr = mFileMgr.attributesOfItemAtPath(path, error: nil)!
        println(attr[NSFileSize])
        
        assert((image != nil), "path:\(path) error")
        
        return image
    }
    
    func saveImage(image: UIImage) -> Bool
    {
        let fileName = getNewFileName()
        let path = mDirList[0].path + "/" + fileName
        
        println("prepare saveImage:\(path)")
        
        if !mFileMgr.fileExistsAtPath(path)
        {
            if !saveImageWithPath(image, path: path)
            {
                println("saveImageWithPath error!")
                return false
            }
        }
        else
        {
            println("\(path) is already exists!")
            return false
        }
        
        mDirList[0].fileList.append(fileName)
        
        //将当前文件索引更新为新添加图片的索引,因为马上就跳转到该图的拼图界面
        mFileIndex = mDirList[0].fileList.count - 1
        
        
        return true
    }
    
    
    //////////// 私有方法 ////////////////
    private func loadCustomDir() -> Bool
    {
        let myDirName = "我的图片"
        let addName = "0添加图标"
        var dirInfo = DirInfo()
        
        dirInfo.path = NSHomeDirectory() + "/Documents/" + myDirName
        
        if !mFileMgr.fileExistsAtPath(dirInfo.path)
        {
            //创建自定义目录
            var error: NSErrorPointer = nil
            if !mFileMgr.createDirectoryAtPath(dirInfo.path, withIntermediateDirectories: true, attributes: nil , error: error)
            {
                println("createDirectoryAtPath error! path[\(dirInfo.path)]")
                println(error)
                return false
            }
        }
        
        let addImagePath = dirInfo.path+"/" + addName + ".jpg"
        if !mFileMgr.fileExistsAtPath(addImagePath)
        {
            //在自定义目录中加入一张"添加图片"
            let addButtonImage = UIImage(named: addName)
            if !saveImageWithPath(addButtonImage!, path: addImagePath)
            {
                println("saveImageWithPath error!")
                return false
            }
        }
        
        dirInfo.fileList = loadFileAtPath(dirInfo.path)
        
        mDirList.append(dirInfo)
        return true
    }
    
    private func saveImageWithPath(image: UIImage, path: String) -> Bool
    {
        let compressRate = getCompressRate(image)
        println("compressRate:\(compressRate)")
        var error: NSErrorPointer = nil
        let data = UIImageJPEGRepresentation(image, compressRate);
        if !mFileMgr.createFileAtPath(path, contents: data, attributes: nil)
        {
            println("createFileAtPath error! path[\(path)]")
            println(error)
            return false
        }
        
        return true
    }
    
    private func loadFixedDir() -> Bool
    {
        let paths = NSBundle.mainBundle().pathsForResourcesOfType("", inDirectory: "MyImages_test") as! [String]
        for path in paths
        {
            var dirInfo = DirInfo()
            dirInfo.path = path
            dirInfo.fileList = loadFileAtPath(path)
            mDirList.append(dirInfo)
        }
        
        return true
    }
    
    
    private func loadFileAtPath(path: String) -> [String]
    {
        var error: NSError?
        var fileList = [String]()
        var contents = mFileMgr.contentsOfDirectoryAtPath(path, error: &error) as! [String]
        if let err = error
        {
            println("load dir files error, dir[\(path)], errmsg: \(err.localizedDescription)")
        }
        
        for fileName in contents
        {
            if fileName[fileName.startIndex] == "."
            {
                println("\(fileName) ignored...")
                continue
            }
            
            fileList.append(fileName)
        }
        
        return fileList
    }
    
    private func getNewFileName() -> String
    {
        let currentDate = NSDate()
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyyMMddHHmmss"
        let dateString = formatter.stringFromDate(currentDate)
        
        return dateString + ".jpg"
    }
    
    //根据图片大小调整压缩比例,0-1
    private func getCompressRate(image: UIImage) -> CGFloat
    {
        println("cut:\(image.size)")
//        
//        let resolution = image.size.width * image.size.height
//        
//        if resolution > 2000*2000
//        {
//            return 0.2
//        }
        return 1
    }

    

    
    
    
    
    
}