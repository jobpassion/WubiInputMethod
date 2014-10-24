//
//  FirstViewController.swift
//  WubiKeyboard
//
//  Created by jeffery on 14-9-18.
//  Copyright (c) 2014年 jeffery. All rights reserved.
//

import UIKit
let themeData = [
    ["title":"蓝白恬静", "img":"10", "themeKey":"theme3", "bgImg":"jdwb(2)"]
    ,["title":"深海静蓝", "imgColor":0x443F78, "themeKey":"theme1", "bgImg":"jduwb"]
    ,["title":"粉红草莓", "img":"bg10", "themeKey":"theme2", "bgImg":"jedwb"]
    ,["title":"新生绿野", "imgColor":0x339933, "themeKey":"theme5", "bgImg":"bg12"]
    ,["title":"时尚橙黄", "img":"20090223_debee2b995985afbe28cvSeFhhbDgHfB", "themeKey":"theme4", "bgImg":"20090223_debee2b995985afbe28cvSeFhhbDgHfB"]
    ,["title":"炫酷黑白", "imgColor":0x000000, "themeKey":"theme6", "bgImg":"bg14"]
]

public class FirstViewController: UIViewController,UICollectionViewDelegateFlowLayout, UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate {
    var _collectionView:UICollectionView?
    let userDefaults = NSUserDefaults(suiteName: "group.com.jeffery.wubikeyboard")
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.navigationBarHidden = true
        var layout:MPSkewedParallaxLayout = MPSkewedParallaxLayout()
        _collectionView = UICollectionView(frame: self.view.bounds, collectionViewLayout: layout)
        _collectionView?.delegate = self
        _collectionView?.dataSource = self
        _collectionView?.backgroundColor = UIColor.whiteColor()
        _collectionView?.registerClass(MPSkewedCell.classForCoder(), forCellWithReuseIdentifier: "cell")
        self.view.addSubview(_collectionView!)
        // Do any additional setup after loading the view, typically from a nib.
        //var arr:Array = (NSBundle.mainBundle().loadNibNamed("WubiView", owner: self, options: nil))
        //println(arr.count)
        //var wubiView:WubiView = arr[0] as WubiView
        //self.view.addSubview(wubiView)
        //var wubiView:UIView = [0] as UIView
        
        userDefaults.setObject("def", forKey: "abc")
        userDefaults.synchronize()
        
        self.tabBarController?.tabBar.tintColor = UIColor(hex: 0xff5f1b);
        //self.tabBarController?.tabBar.backgroundColor = UIColor(red: 0.046779754647349063, green: 0.048423441235564579, blue: 0.050314198369565188, alpha: 1)
        //self.tabBarController?.tabBar.barTintColor = UIColor.orangeColor()

    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return themeData.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell:MPSkewedCell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as MPSkewedCell
        if(nil == themeData[indexPath.row]["imgColor"]){
            cell.image = UIImage(named: themeData[indexPath.row]["img"]! as String)
        }else{
            //UIGraphicsBeginImageContext(CGSizeMake(500, 500))
            ////UIColor(hex: themeData[indexPath.row]["imgColor"] as Int).setFill()
            //CGContextAddRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, 500, 500)) // this may not be necessary
            //UIColor.orangeColor().setFill()
            //let image = UIGraphicsGetImageFromCurrentImageContext();
            //UIGraphicsEndImageContext();
            
            let rect = CGRectMake(0, 0, 500, 500)
            
            UIGraphicsBeginImageContext(rect.size);
            let context = UIGraphicsGetCurrentContext();
            CGContextSetFillColorWithColor(context, UIColor(hex: themeData[indexPath.row]["imgColor"] as Int).CGColor)
            CGContextFillRect(context, rect);
            let image = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsEndImageContext();
            
            cell.image = image
        }
        //if let theme : String = userDefaults.objectForKey("theme") as? String {
        //    if(theme == themeData[indexPath.row]["themeKey"]){
        //        cell.text = themeData[indexPath.row]["title"]! + "(当前主题)"
        //    }else if ("theme3" == themeData[indexPath.row]["themeKey"]){
        //        cell.text = themeData[indexPath.row]["title"]! + "(当前主题)"
        //    }else{
        //        cell.text = themeData[indexPath.row]["title"]
        //    }
        //}else{
        //    cell.text = themeData[indexPath.row]["title"]
        //}
        cell.text = themeData[indexPath.row]["title"] as String
        switch indexPath.row {
            case 0:
                cell.textLabel.textColor = UIColor(hex: 0x99CCFF)
            case 1:
                cell.textLabel.textColor = UIColor(hex: 0x6666CC)
            case 2:
                cell.textLabel.textColor = UIColor(hex: 0xFFCCCC)
            default:
                let a = 1
        }

        return cell
    }
    
    var semiVC:KNThirdViewController?
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        let bgimgv = UIImageView(image: UIImage(named: "background_01"))
        semiVC = KNThirdViewController(nibName: "KNThirdViewController", bundle: nil)
        semiVC?.parent = self
        semiVC?.themeId = themeData[indexPath.row]["themeKey"] as String
        self.presentSemiViewController(semiVC, withOptions: [KNSemiModalOptionKeys.backgroundView:bgimgv])
        semiVC?.bgImage1.image = UIImage(named: themeData[indexPath.row]["bgImg"]! as String)
        
      //[self presentSemiViewController:semiVC withOptions:@{ KNSemiModalOptionKeys.backgroundView:bgimgv }];
    }


}


public extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
    
    public class func randomColor() -> UIColor {
        let red = (CGFloat)(arc4random() % 255) / 255.0
        let green = (CGFloat)(arc4random() % 255) / 256.0
        let blue = (CGFloat)(arc4random() % 255) / 256.0
        let color = UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        return color
    }
}
