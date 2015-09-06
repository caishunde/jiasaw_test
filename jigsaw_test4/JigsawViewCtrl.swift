//
//  JigsawViewCtrl.swift
//  jigsaw_test4
//
//  Created by 国明唐 on 15/8/29.
//  Copyright (c) 2015年 tangguoming. All rights reserved.
//

import UIKit


class JigsawViewCtrl: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, SphereMenuDelegate
{
    @IBOutlet weak var startButton: UIButton!
    
    @IBOutlet weak var popButton: UIButton!
    
    var sphereMenu: SphereMenu! = nil
    
    @IBOutlet weak var picker: UIPickerView!    //块数选择器
    
    var navigationBar: UINavigationBar! = nil
    
    var hiddenStatusBar = false
    
    @IBOutlet var jigsawView: JigsawView!   //这个就是self.view
    
    override func viewDidLoad()
    {
        println("JigsawViewCtrl.viewDidLoad")
        super.viewDidLoad()
        
        setNavigationbar()

        jigsawView.initJigsawView(self)
        
        initPicker()
        
    }
    
    
    func showSphereMenu()
    {
        let start1 = UIImage(named: "start1")
        let start2 = UIImage(named: "start2")
        let image1 = UIImage(named: "icon-twitter")
        let image2 = UIImage(named: "icon-email")
        let image3 = UIImage(named: "icon-facebook")
        let startImages = [start1!, start2!]
        var images = [image1!,image2!,image3!]
        
        var startPosition = startButton.center
        startPosition.x = 25
        startPosition.y = 25
        
        sphereMenu = SphereMenu(startPoint: startPosition, startImages: startImages, submenuImages:images, tapToDismiss:true)
        sphereMenu.delegate = self
        view.addSubview(sphereMenu)

    }
    
    func frontButton()
    {
        view.bringSubviewToFront(jigsawView.viewCtrl.popButton)
        sphereMenu.bringItemsToFront()
    }



    
    override func prefersStatusBarHidden() ->Bool
    {
        return hiddenStatusBar
    }
    
    
    func setBackground()
    {
        println("setBackground")
        let bgImage = UIImage(named: "bg1.jpg")
        view.backgroundColor = UIColor(patternImage: bgImage!)
    }
    
    func initPicker()
    {
        println("initPicker")
        picker.delegate = self
        picker.dataSource = self
        picker.selectRow(Common.pickerDefaultRow, inComponent:0, animated:true)   //默认第二行, 16块
        
        //因为选择器初始状态不会触发"滑动停止动作",这里要初始化赋值
        Common.N = Common.pickerDefaultRow + 3
    }
    
    
    
    func setOriginJigsawImage(image: UIImage)
    {
        //因为延迟加载,需要先使用一次view,才会进行初始化,否则不能用outlet,这句去掉要小心
        setBackground()
        
        jigsawView.showOriginImage(image)
    }
    
    func setNavigationbar()
    {
        navigationBar = UINavigationBar(frame:CGRectMake(0, 0, view.frame.size.width, 60))
        
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
    
    
    @IBAction func startGame(sender: UIButton)
    {
        startButton.removeFromSuperview()
        
        //切割并分散
        jigsawView.splitAndSeparate()
        prepareToStart()
    }
    
    private func prepareToStart()
    {
        //初始化pop菜单
        showSphereMenu()

        navigationBar.removeFromSuperview()
        navigationBar = nil
        
        //移走块数选择器
        picker.removeFromSuperview()
        picker = nil
        
        //隐藏状态栏
        hiddenStatusBar = true
        setNeedsStatusBarAppearanceUpdate()
        
        jigsawView.prepareToStart()
        
    }
    
    @IBAction func popMenu(sender: UIButton)
    {
        popback()
    }
    
    //菜单按钮
    func sphereDidSelected(index: Int)
    {
        println("selected \(index)")
        
        if (index == 2)
        {
            popback()
        }
    }

    
    
    func popback()
    {
        println("backkkk")
        jigsawView.cleanAll()
        dismissViewControllerAnimated(true, completion: nil)
    }
    

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    
    //////////////
    //设置选择框的列数为3列,继承于UIPickerViewDataSource协议
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int
    {
        return 1
    }
    
    //设置选择框的行数为9行，继承于UIPickerViewDataSource协议
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int
    {
        return 5
    }
    
    //设置选择框各选项的内容，继承于UIPickerViewDelegate协议
    func pickerView(pickerView:UIPickerView, titleForRow row: Int, forComponent component: Int)
        -> String!
    {
        return String((row+3) * (row+3))
    }
    
    //滑动停止后触发,注意:初始状态不会触发!!
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int)
    {
        Common.N = (row+3)
        jigsawView.drawMultiSquare(false)
    }
        
    
    
    
    
    
    
    
}
