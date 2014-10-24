//
//  SecondViewController.swift
//  WubiKeyboard
//
//  Created by jeffery on 14-9-18.
//  Copyright (c) 2014年 jeffery. All rights reserved.
//

import UIKit

class SecondViewController: UITableViewController {
    let userDefaults = NSUserDefaults(suiteName: "group.com.jeffery.wubikeyboard")
    @IBOutlet weak var wubiKeyEnableSwitch: UISwitch!
    @IBOutlet weak var pinyinEnableSwitch: UISwitch!

    
    override func viewDidLoad() {
        var uiView = UIView()
        uiView.frame = CGRectZero
        self.tableView.tableFooterView = uiView;
        super.viewDidLoad()
        if let pinyinConf : Int = userDefaults.objectForKey("pinyin") as? Int {
            if 0 == pinyinConf{
                pinyinEnableSwitch.setOn(false, animated: false)
            }
        }
        if let pinyinConf : Int = userDefaults.objectForKey("wubiKey") as? Int {
            if 0 == pinyinConf{
                wubiKeyEnableSwitch.setOn(false, animated: false)
            }
        }

        // Do any additional setup after loading the view, typically from a nib.
        //let inset = UIEdgeInsets(top: 40, left: 0, bottom: 0, right: 0)
        //self.tableView.contentInset = inset
        //tableView.separatorInset = UIEdgeInsetsZero
        //tableView.layoutMargins = UIEdgeInsetsZero
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath){
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    override func tableView(tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        let header:UITableViewHeaderFooterView = view as UITableViewHeaderFooterView
        
        header.textLabel.font = UIFont.systemFontOfSize(12)
        header.textLabel.numberOfLines = 2
        header.textLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        //header.textLabel.frame = CGRectMake(0, 0, self.view.frame.width, 80)
        //header.frame = CGRectMake(0, 0, self.view.frame.width, 80)
    }
    //override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath){
    //    if(cell.respondsToSelector("setSeparatorInset:")){
    //        cell.separatorInset = UIEdgeInsetsZero
    //    }
    //    if(cell.respondsToSelector("setLayoutMargins:")){
    //        cell.layoutMargins = UIEdgeInsetsZero
    //    }
    //}

    @IBAction func onPinyinEnableChange(sender: UISwitch) {
        if sender.on {
            userDefaults.setValue(1, forKey: "pinyin")
        }else{
            userDefaults.setValue(0, forKey: "pinyin")
        }
        userDefaults.synchronize()
    }
    @IBAction func onWubiKeyEnableChange(sender: UISwitch) {
        if sender.on {
            userDefaults.setValue(1, forKey: "wubiKey")
        }else{
            userDefaults.setValue(0, forKey: "wubiKey")
        }
        userDefaults.synchronize()
    }
}

