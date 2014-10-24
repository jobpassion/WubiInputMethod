//
//  Configuration.swift
//  WubiKeyboard
//
//  Created by jeffery on 14-10-12.
//  Copyright (c) 2014年 jeffery. All rights reserved.
//

import Foundation
let userDefaults = NSUserDefaults(suiteName: "group.com.jeffery.wubikeyboard")
let colorTheme = [
    "theme1":["topLeftBackground":0x443F78, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0x443F78
        , "keyLineOne":0x5B568A, "keyLineOneSelected":0x443F78, "keyLineOneFont":0xFFFFFF
        , "keyLineTwo":0x443F78, "keyLineTwoSelected":0x5B568A, "keyLineTwoFont":0xFFFFFF
        , "keyLineThree":0x5B568A, "keyLineThreeSelected":0x443F78, "keyLineThreeFont":0xFFFFFF
        , "keyLineFour":0x443F78, "keyLineFourSelected":0x5B568A, "keyLineFourFont":0xFFFFFF
    ]
    ,"theme2":["topLeftBackground":0xFF9999, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0xFF9999
        , "keyLineOne":0xFFCCCC, "keyLineOneSelected":0xFF9999, "keyLineOneFont":0xFFFFFF
        , "keyLineTwo":0xFF9999, "keyLineTwoSelected":0xFFCCCC, "keyLineTwoFont":0xFFFFFF
        , "keyLineThree":0xFFCCCC, "keyLineThreeSelected":0xFF9999, "keyLineThreeFont":0xFFFFFF
        , "keyLineFour":0xFF9999, "keyLineFourSelected":0xFFCCCC, "keyLineFourFont":0xFFFFFF
    ]
    ,"theme3":["topLeftBackground":0x2f7aff, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0x2f7aff
        , "keyLineOne":0xFFFFFF, "keyLineOneSelected":0xCCCCFF, "keyLineOneFont":0x2f7aff
        , "keyLineTwo":0xFFFFFF, "keyLineTwoSelected":0xCCCCFF, "keyLineTwoFont":0x2f7aff
        , "keyLineThree":0xFFFFFF, "keyLineThreeSelected":0xCCCCFF, "keyLineThreeFont":0x2f7aff
        , "keyLineFour":0xFFFFFF, "keyLineFourSelected":0xCCCCFF, "keyLineFourFont":0x2f7aff
    ]
    ,"theme4":["topLeftBackground":0xFF9900, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0xFF9900
        , "keyLineOne":0xFF9933, "keyLineOneSelected":0xFF9900, "keyLineOneFont":0xFFFFFF
        , "keyLineTwo":0xFF9900, "keyLineTwoSelected":0xFF9933, "keyLineTwoFont":0xFFFFFF
        , "keyLineThree":0xFF9933, "keyLineThreeSelected":0xFF9900, "keyLineThreeFont":0xFFFFFF
        , "keyLineFour":0xFF9900, "keyLineFourSelected":0xFF9933, "keyLineFourFont":0xFFFFFF
    ]
    ,"theme5":["topLeftBackground":0x339933, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0x339933
        , "keyLineOne":0x99CC00, "keyLineOneSelected":0x339933, "keyLineOneFont":0xFFFFFF
        , "keyLineTwo":0x339933, "keyLineTwoSelected":0x99CC00, "keyLineTwoFont":0xFFFFFF
        , "keyLineThree":0x99CC00, "keyLineThreeSelected":0x339933, "keyLineThreeFont":0xFFFFFF
        , "keyLineFour":0x339933, "keyLineFourSelected":0x99CC00, "keyLineFourFont":0xFFFFFF
    ]
    ,"theme6":["topLeftBackground":0x000000, "topLeftFont":0xFFFFFF, "topRightBackground":0xFFFFFF, "topRightFont":0x000000
        , "keyLineOne":0xCCCCCC, "keyLineOneSelected":0x666666, "keyLineOneFont":0x000000
        , "keyLineTwo":0x000000, "keyLineTwoSelected":0x666666, "keyLineTwoFont":0xFFFFFF
        , "keyLineThree":0xCCCCCC, "keyLineThreeSelected":0x666666, "keyLineThreeFont":0x000000
        , "keyLineFour":0x000000, "keyLineFourSelected":0x666666, "keyLineFourFont":0xFFFFFF
    ]
]

public class Configuration:NSObject{
    public class func getPinyinEnabled()->Int {
        if let pinyinConf : Int = userDefaults.objectForKey("pinyin") as? Int {
            return pinyinConf
        }
        return 1;
    }
    public class func getColorTheme() -> Dictionary<String,Int>{
        if let theme : String = userDefaults.objectForKey("theme") as? String {
            return colorTheme[theme]!
        }
        return colorTheme["theme3"]!
    }
    func isOpenAccessGranted() -> Bool {
        let fm = NSFileManager.defaultManager()
        let containerPath = fm.containerURLForSecurityApplicationGroupIdentifier(
            "group.com.example")?.path
        var error: NSError?
        fm.contentsOfDirectoryAtPath(containerPath!, error: &error)
        if (error != nil) {
            NSLog("Full Access: Off")
            return false
        }
        NSLog("Full Access: On");
        return true
    }
    public class func isEnableWubiKey() -> Bool{
        if let pinyinConf : Int = userDefaults.objectForKey("wubiKey") as? Int {
            if 0 == pinyinConf{
                return false
            }
        }
        return true
    }
}