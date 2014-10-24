//
//  FirstViewController.swift
//  test
//
//  Created by jeffery on 14-9-19.
//  Copyright (c) 2014年 jeffery. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {
                            
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setupwubiView after loading the view, typically from a nib.
        
        self.view.backgroundColor = UIColor.blackColor()

        var topView:UIView = (NSBundle.mainBundle().loadNibNamed("Test", owner: self, options: nil))[0] as UIView
        topView.frame = CGRectMake(0, 0, 320, 250)
        //topView.layoutIfNeeded()
        topView.backgroundColor = UIColor.blueColor()
        self.view.addSubview(topView)
    }
    
    func configureBtn(b:UIButton){
       b.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
       b.backgroundColor = UIColor.whiteColor()
       b.layer.cornerRadius = 5
       b.clipsToBounds = true
       b.addTarget(self, action: "onKeyTap:", forControlEvents: UIControlEvents.TouchUpInside)
        
    }
    var strInput = ""
    func onKeyTap(sender:UIButton){
        strInput = strInput + sender.titleLabel.text
        println(strInput)
        var results:Array = ZeeSQLiteHelper.readQueryFromDB("select * from ZTIUSERWORD where ZSHORTCUT like '" + strInput + "%' limit 7 offset 0")
        for res in results {
            println(res["ZTARGET"])
        }
        if ( countElements(strInput) == 4){
            strInput = ""
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

