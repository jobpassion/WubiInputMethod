//
//  KeyboardViewController.swift
//  五笔输入法
//
//  Created by jeffery on 14-9-18.
//  Copyright (c) 2014年 jeffery. All rights reserved.
//

import UIKit
import Slidden

let numKeys: [[String]] = [["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"],
    ["-", "/", ":", ";", "(", ")", "$", "&", "@", "”"],
    ["#+=", ".", ",", "?", "!", "’", "backspace"],
    ["ABC", "next", "简单五笔", "return"]]
let englishKeys: [[String]] = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["blankType1", "A", "S", "D", "F", "G", "H", "J", "K", "L", "blankType1"],
    ["shift", "Z", "X", "C", "V", "B", "N", "M", "backspace"],     ["123", "next", "space", "return"]]
let wubiKeys: [[String]] = [["Q", "W", "E", "R", "T", "Y", "U", "I", "O", "P"],
    ["A", "S", "D", "F", "G", "H", "J", "K", "L"],
    ["，。？！", "Z", "X", "C", "V", "B", "N", "M", "backspace"],     ["123", "next", "简单五笔", "return"]]
let wubiKeyMap = [
    "Q":"钅"
    ,"W":"人"
    ,"E":"月"
    ,"R":"白"
    ,"T":"禾"
    ,"Y":"讠"
    ,"U":"立"
    ,"I":"水"
    ,"O":"火"
    ,"P":"之"
    ,"A":"工"
    ,"S":"木"
    ,"D":"大"
    ,"F":"土"
    ,"G":"一"
    ,"H":"丨"
    ,"J":"日"
    ,"K":"口"
    ,"L":"田"
    ,"X":"纟"
    ,"C":"又"
    ,"V":"女"
    ,"B":"子"
    ,"N":"己"
    ,"M":"山"
]

public class MyKeyboardViewController: Slidden.KeyboardViewController,UICollectionViewDataSource,UICollectionViewDelegate,UIInputViewAudioFeedback {
    
    @IBOutlet weak var nextKeyboardButton: UIButton!
    var updatedConstraints = false
    var heightConstraint: NSLayoutConstraint!
    var pinyinConf:Int?
    //let userDefaults = NSUserDefaults(suiteName: "group.com.jeffery.wubikeyboard")
    
    //override var inputAccessoryView: UIView? {
    //    var accessFrame:CGRect = CGRectMake(0.0, 0.0, 768.0, 77.0)
    //    var _view:UIView = UIView(frame: accessFrame)
    //    _view.backgroundColor = UIColor.blueColor()
    //    var compButton:UIButton = UIButton.buttonWithType(UIButtonType.InfoDark) as UIButton
    //    compButton.frame = CGRectMake(313.0, 20.0, 158.0, 37.0)
    //    compButton.setTitle("hello", forState: UIControlState.Normal)
    //    compButton.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
    //    _view.addSubview(compButton)
    //    return _view
    //}
    
    override public func updateViewConstraints() {
        super.updateViewConstraints()
        
        // Add custom view sizing constraints here
    }
    
    var inputLabelArray:Array<UILabel> = []
    var selectList:UIScrollView!
    var selectCollectionView:UICollectionView!
    //var datasource:Array<AnyObject> = [["ZTARGET":"是"],["ZTARGET":"是"],["ZTARGET":"是"],["ZTARGET":"是"],["ZTARGET":"是"]]
    var datasource:Array<AnyObject> = []
    var cellArray:Array<AnyObject> = []
    
    var fastQueue:dispatch_queue_t!
    var keyboardQueue:dispatch_queue_t!
    var topView:UIView!
    var wubiView:UIView!
    var numberView:UIView!
    override public func viewDidLoad() {
        super.viewDidLoad()
        //userDefaults.synchronize()
        
        pinyinConf = Configuration.getPinyinEnabled()
        
        keyboardQueue = dispatch_queue_create("com.jeffery.keyboard", DISPATCH_QUEUE_SERIAL)
        var priority:dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0)
        dispatch_set_target_queue(priority, keyboardQueue)
        fastQueue = dispatch_queue_create("com.jeffery.fast", DISPATCH_QUEUE_SERIAL)
        priority = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)
        
        
        topView = configureTopView()
        if(Configuration.getPinyinEnabled() == 0){
        inputLabelArray.append(topView.viewWithTag(10) as UILabel)
        inputLabelArray.append(topView.viewWithTag(11) as UILabel)
        inputLabelArray.append(topView.viewWithTag(12) as UILabel)
        inputLabelArray.append(topView.viewWithTag(13) as UILabel)
        }else{
            inputLabelArray.append(topView.viewWithTag(10) as UILabel)
        }
        //self.keyboardView.addSubview(topView)
        //let left = NSLayoutConstraint(item: topView, attribute: .Left, relatedBy: .Equal, toItem: self.keyboardView, attribute: .Left, multiplier: 1.0, constant: 0)
        //let top = NSLayoutConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: self.keyboardView, attribute: .Top, multiplier: 1.0, constant: 0)
        //let right = NSLayoutConstraint(item: topView, attribute: .Right, relatedBy: .Equal, toItem: self.keyboardView, attribute: .Right, multiplier: 1.0, constant: 0)
        //let bottom = NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: self.keyboardView, attribute: .Bottom, multiplier: 0.18, constant: 0)
        
        self.view.addSubview(topView)
        let left = NSLayoutConstraint(item: topView, attribute: .Left, relatedBy: .Equal, toItem: self.view, attribute: .Left, multiplier: 1.0, constant: 0)
        let top = NSLayoutConstraint(item: topView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
        let right = NSLayoutConstraint(item: topView, attribute: .Right, relatedBy: .Equal, toItem: self.view, attribute: .Right, multiplier: 1.0, constant: 0)
        let bottom = NSLayoutConstraint(item: topView, attribute: .Bottom, relatedBy: .Equal, toItem: self.view, attribute: .Bottom, multiplier: 0.18, constant: 0)
        self.view.addConstraints([left, top, right, bottom])
        
        selectCollectionView = topView.viewWithTag(14) as UICollectionView
        dispatch_async(keyboardQueue, { () -> Void in
            ZeeSQLiteHelper.initializeSQLiteDB()
            return
        })
        
        
    }
    
    private func configureTopView() -> UIView{
        let topView = UIView()
        topView.setTranslatesAutoresizingMaskIntoConstraints(false)
        let leftContainer = UIView()
        leftContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        leftContainer.backgroundColor = UIColor(hex: Configuration.getColorTheme()["topLeftBackground"]!)
        topView.addSubview(leftContainer)
        var left = NSLayoutConstraint(item: leftContainer, attribute: .Left, relatedBy: .Equal, toItem: topView, attribute: .Left, multiplier: 1.0, constant: 0)
        var top = NSLayoutConstraint(item: leftContainer, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Top, multiplier: 1.0, constant: 0)
        var right = NSLayoutConstraint(item: leftContainer, attribute: .Right, relatedBy: .Equal, toItem: topView, attribute: .Right, multiplier: 0.3, constant: 0)
        var bottom = NSLayoutConstraint(item: leftContainer, attribute: .Bottom, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1, constant: 0)
        topView.addConstraints([left, top, right, bottom])
        
        //
        if(Configuration.getPinyinEnabled() == 0){
        for i in 0...3{
            let inputLabel = UILabel()
            //inputLabel.backgroundColor = UIColor.randomColor()
            inputLabel.textAlignment = NSTextAlignment.Center
            inputLabel.font = UIFont(name: inputLabel.font.fontName, size: 18)
            inputLabel.textColor = UIColor(hex: Configuration.getColorTheme()["topLeftFont"]!)
            inputLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            inputLabel.text = ""
            inputLabel.tag = 10 + i
            leftContainer.addSubview(inputLabel)
            left = NSLayoutConstraint(item: inputLabel, attribute: .Left, relatedBy: .Equal, toItem: leftContainer, attribute: .Right, multiplier: CGFloat(i)/6.0 + 1/6, constant: 0)
            top = NSLayoutConstraint(item: inputLabel, attribute: .Top, relatedBy: .Equal, toItem: leftContainer, attribute: .Top, multiplier: 1, constant: 0)
            right = NSLayoutConstraint(item: inputLabel, attribute: .Right, relatedBy: .Equal, toItem: leftContainer, attribute: .Right, multiplier: 1 - ((4 - CGFloat(i))/6), constant: 0)
            bottom = NSLayoutConstraint(item: inputLabel, attribute: .Bottom, relatedBy: .Equal, toItem: leftContainer, attribute: .Bottom, multiplier: 1, constant: 0)
            leftContainer.addConstraints([left, top, right, bottom])
        }
        }else{
            let inputLabel = UILabel()
            //inputLabel.backgroundColor = UIColor.randomColor()
            inputLabel.textAlignment = NSTextAlignment.Center
            inputLabel.font = UIFont(name: inputLabel.font.fontName, size: 18)
            inputLabel.textColor = UIColor(hex: Configuration.getColorTheme()["topLeftFont"]!)
            inputLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
            inputLabel.adjustsFontSizeToFitWidth = true
            inputLabel.text = ""
            inputLabel.tag = 10
            leftContainer.addSubview(inputLabel)
            left = NSLayoutConstraint(item: inputLabel, attribute: .Left, relatedBy: .Equal, toItem: leftContainer, attribute: .Right, multiplier: 0, constant: 0)
            top = NSLayoutConstraint(item: inputLabel, attribute: .Top, relatedBy: .Equal, toItem: leftContainer, attribute: .Top, multiplier: 1, constant: 0)
            right = NSLayoutConstraint(item: inputLabel, attribute: .Right, relatedBy: .Equal, toItem: leftContainer, attribute: .Right, multiplier: 1, constant: 0)
            bottom = NSLayoutConstraint(item: inputLabel, attribute: .Bottom, relatedBy: .Equal, toItem: leftContainer, attribute: .Bottom, multiplier: 1, constant: 0)
            leftContainer.addConstraints([left, top, right, bottom])
        }
        
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        //layout.itemSize = CGSize(width: 30, height: 120)
        layout.itemSize.width = 40
        layout.itemSize.height = 60
        //let rightView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 0, height: 0), collectionViewLayout: layout)
        var rightView:UICollectionView = (NSBundle.mainBundle().loadNibNamed("Collection", owner: self, options: nil))[0] as UICollectionView
        rightView.dataSource = self
        rightView.delegate = self
        rightView.tag = 14
        var nipName=UINib(nibName: "CollectionCell", bundle:nil)
        rightView.registerNib(nipName, forCellWithReuseIdentifier: "cell")
        
        rightView.setTranslatesAutoresizingMaskIntoConstraints(false)
        rightView.backgroundColor = UIColor(hex: Configuration.getColorTheme()["topRightBackground"]!)
        topView.addSubview(rightView)
        left = NSLayoutConstraint(item: rightView, attribute: .Left, relatedBy: .Equal, toItem: topView, attribute: .Right, multiplier: 0.3, constant: 0)
        top = NSLayoutConstraint(item: rightView, attribute: .Top, relatedBy: .Equal, toItem: topView, attribute: .Top, multiplier: 1.0, constant: 0)
        right = NSLayoutConstraint(item: rightView, attribute: .Right, relatedBy: .Equal, toItem: topView, attribute: .Right, multiplier: 1, constant: 0)
        bottom = NSLayoutConstraint(item: rightView, attribute: .Bottom, relatedBy: .Equal, toItem: topView, attribute: .Bottom, multiplier: 1, constant: 0)
        
        topView.addConstraints([left, top, right, bottom])
        
        
        //topView.backgroundColor = UIColor.blueColor()
        return topView
    }
    
    
    override public func viewWillAppear(animated: Bool) {
        super.viewWillAppear(false)
        var newHeight: CGFloat = 270
        if(UIDevice.currentDevice().userInterfaceIdiom == .Pad){
            newHeight = 352
        }
        heightConstraint = NSLayoutConstraint(item: self.view, attribute:NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem:nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: newHeight)
        heightConstraint.priority = 999
        self.view.addConstraint(heightConstraint)
        
        //        self.view.setNeedsUpdateConstraints()
        
        //        for (index, constraint) in enumerate(self.view.constraints()) {
        //            println("---------\n")
        //            println(constraint)
        //            let lookingFor = constraint as NSLayoutConstraint
        //            if lookingFor.firstAttribute == NSLayoutAttribute.Height {
        //                heightConstraint = constraint as NSLayoutConstraint
        //            }
        //        }
        
    }
    
    
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated
    }
    
    func configureBtn(b:UIButton){
        b.setTitleColor(UIColor.blackColor(), forState: UIControlState.Normal)
        b.backgroundColor = UIColor.whiteColor()
        b.layer.cornerRadius = 5
        b.clipsToBounds = true
        b.addTarget(self, action: "onKeyTap:", forControlEvents: UIControlEvents.TouchDown)
        configureBtnStyle(b)
    }
    func configureBtnStyle(b:UIButton){
        b.addTarget(self, action: "onKeyTapDown:", forControlEvents: UIControlEvents.TouchDown)
        b.addTarget(self, action: "onKeyTapUp:", forControlEvents: UIControlEvents.TouchUpInside)
        b.addTarget(self, action: "onKeyTapUp:", forControlEvents: UIControlEvents.TouchUpOutside)
    }
    func onKeyTapDown(sender:UIButton){
        sender.backgroundColor = UIColor.blueColor()
    }
    func onKeyTapUp(sender:UIButton){
        sender.backgroundColor = UIColor.whiteColor()
    }
    var strInput = ""
    var keyTapQuerying = false
    func onKeyTap(key:String){
        //self.lastTypeTime = NSDate().timeIntervalSince1970
        //println("onKeyTap:clear datasource")
        if(self.keyTapQuerying){
            //querying, cannot perfom blank Tap
            return
        }
        dispatch_async(fastQueue, { () -> Void in
            //dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if (Configuration.getPinyinEnabled() == 0 && countElements(self.strInput) == 4){
                if(self.datasource.count > 0){
                    (self.textDocumentProxy as UIKeyInput).insertText(self.datasource[0]["ZTARGET"] as String)
                    self.strInput = ""
                }else{
                    return
                }
            }
            self.datasource = []
            let abc:String? = key
            self.strInput = self.strInput + abc!
            self.keyTapQuerying = true
            self.quickUpdateTop()
            //self.updateTop()
            //updateSelect()
            //if ( countElements(self.strInput) == 4){
            //    if(self.datasource.count == 1){
            //        (self.textDocumentProxy as UIKeyInput).insertText(self.datasource[0]["ZTARGET"] as String)
            //        self.clear()
            //    }
            //}
            //})
        })
    }
    
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
        return datasource.count
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell{
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell
        var label:UIButton = cell.viewWithTag(10) as UIButton
        if(datasource.count > indexPath.row){
            label.setTitle(datasource[indexPath.row]["ZTARGET"] as? String, forState: UIControlState.Normal)
        }
        label.setTitleColor(UIColor(hex: Configuration.getColorTheme()["topRightFont"]!), forState: UIControlState.Normal)
        label.titleLabel?.adjustsFontSizeToFitWidth = true
        //label.addTarget(self, action: "onSelect:", forControlEvents: UIControlEvents.TouchDown)
        return cell
    }
    
    func reloadData(){
        for data in self.datasource{
            println(data)
        }
    }
    func clear(){
        strInput = ""
        updateInputLabel()
        //updateTop()
        self.datasource = []
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //self.selectCollectionView.reloadData()
            UIView.setAnimationsEnabled(false)
            self.selectCollectionView.performBatchUpdates({ () -> Void in
                self.selectCollectionView.reloadSections(NSIndexSet(index: 0))
                }, { (finished:Bool) -> Void in
                    UIView.setAnimationsEnabled(true)
            })
            
            
        })
    }
    var lastType = ""
    //var lastTypeTime:NSTimeInterval!
    
    func onSelect(sender:UIButton){
        (self.textDocumentProxy as UIKeyInput).insertText((sender.titleLabel?.text)!)
        lastType = (sender.titleLabel?.text)!
        clear()
    }
    
    func onBlank(){
        dispatch_async(fastQueue, { () -> Void in
            if ( countElements(self.strInput) == 0){
                (self.textDocumentProxy as UIKeyInput).insertText(" ")
            }else{
                if(self.datasource.count > 0){
                    (self.textDocumentProxy as UIKeyInput).insertText(self.datasource[0]["ZTARGET"] as String)
                    self.clear()
                }
            }
        })
    }
    var backTimer:NSTimer!
    func onBack(){
        //keyClickSound()
        onBackDelete()
        var n = countElements(strInput)
            if((backTimer) != nil && backTimer.valid){
                backTimer.invalidate()
            }
            var fireDate:NSDate = NSDate(timeIntervalSinceNow: 0.6)
            backTimer = NSTimer(fireDate: fireDate, interval: 0.1, target: self, selector: "onBackTimer", userInfo: nil, repeats: true)
            NSRunLoop.currentRunLoop().addTimer(backTimer, forMode: NSDefaultRunLoopMode)
    }
    func onBackDelete(){
        var n = countElements(strInput)
        if (n > 0){
            strInput = strInput.substring(0, length: n - 1)
            updateTop()
        }else{
            (self.textDocumentProxy as UIKeyInput).deleteBackward()
        }
    }
    func onBackTimer(){
        keyClickSound()
        onBackDelete()
    }
    func onBackUp(){
        if((backTimer) != nil && backTimer.valid){
            backTimer.invalidate()
        }
        backTimer = nil
    }
    var dotTimer:NSTimeInterval!
    func onDot2(){
        var toType = "#"
        if((dotTimer) == nil){
        }else{
            if(NSDate().timeIntervalSince1970 - dotTimer < 0.5){
                //if(dotTimer.valid){
                if(lastType == "#"){
                    toType = "+"
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                }else if (lastType == "+"){
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                    toType = "="
                }else if (lastType == "="){
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                    toType = "#"
                }
            }else{
                toType = "#"
            }
            //dotTimer.invalidate()
        }
        dotTimer = NSDate().timeIntervalSince1970
        (self.textDocumentProxy as UIKeyInput).insertText(toType)
        lastType = toType
        
    }
    func onDot(){
        var toType = "，"
        if((dotTimer) == nil){
        }else{
            if(NSDate().timeIntervalSince1970 - dotTimer < 0.5){
                //if(dotTimer.valid){
                if(lastType == "，"){
                    toType = "。"
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                }else if (lastType == "。"){
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                    toType = "？"
                }else if (lastType == "？"){
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                    toType = "！"
                }else if (lastType == "！"){
                    (self.textDocumentProxy as UIKeyInput).deleteBackward()
                    toType = "，"
                }
            }else{
                toType = "，"
            }
            //dotTimer.invalidate()
        }
        dotTimer = NSDate().timeIntervalSince1970
        (self.textDocumentProxy as UIKeyInput).insertText(toType)
        lastType = toType
        
    }
    func emptyFunc(){
        
    }
    private func updateInputLabel(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if(Configuration.getPinyinEnabled() == 0){
                
            var count = countElements(self.strInput)
            for i in 0...3{
                if(i < count){
                    //strInput.substringWithRange(1 .. 2)
                    self.inputLabelArray[i].text = self.strInput.substring(i, length: 1)
                }else{
                    self.inputLabelArray[i].text = ""
                }
            }
            }else{
                self.inputLabelArray[0].text = self.strInput
            }
        })
    }
    func updateTop(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateInputLabel()
            self.updateSelect()
        })
    }
    func quickUpdateTop(){
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.updateInputLabel()
            //self.quickUpdateSelect()
            self.updateSelect()
        })
    }
    let lastSelectDate:NSDate!
    var timer:NSTimer!
    func updateSelect(){
        onTimer()
        //if((timer)==nil){
        //    self.timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "onTimer", userInfo: nil, repeats: false)
        //}else{
        //    if(self.timer.valid){
        //        self.timer.invalidate()
        //        self.timer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "onTimer", userInfo: nil, repeats: false)
        //    }
        //}
    }
    //func quickUpdateSelect(){
    //    let tmpInput = self.strInput.lowercaseString
    //    dispatch_async(fastQueue, { () -> Void in
    //        let results = ZeeSQLiteHelper.readQueryFromDB("select * from ZTIUSERWORD where ZSHORTCUT = '" + tmpInput + "' limit 1 offset 0")
    //        self.keyTapQuerying = false
    //        if(results.count>0){
    //            self.datasource = results
    //            println("quickUpdateSelect")
    //            dispatch_async(dispatch_get_main_queue(), { () -> Void in
    //                //self.selectCollectionView.reloadData()
    //                UIView.setAnimationsEnabled(false)
    //                self.selectCollectionView.performBatchUpdates({ () -> Void in
    //                    self.selectCollectionView.reloadSections(NSIndexSet(index: 0))
    //                    }, { (finished:Bool) -> Void in
    //                        UIView.setAnimationsEnabled(true)
    //                })
    //                
    //                
    //            })
    //        }
    //    })
    //}
    func fastQueryAndInsertFirst(){
        let tmpInput = self.strInput.lowercaseString
        dispatch_async(fastQueue, { () -> Void in
            let results = ZeeSQLiteHelper.readQueryFromDB("select * from ZTIUSERWORD where ZSHORTCUT = '" + tmpInput + "' limit 1 offset 0")
            if(results.count>0){
                (self.textDocumentProxy as UIKeyInput).insertText(results[0]["ZTARGET"] as String)
            }
        })
        clear()
    }
    var wubiSearchComplete = 0
    var pinyinSearchComplete = 0
    
    func onTimer(){
        wubiSearchComplete = 0
        pinyinSearchComplete = 0
        self.timer = nil
        if(Configuration.getPinyinEnabled() == 1){
            
        dispatch_async(keyboardQueue, { () -> Void in
            var count = countElements(self.strInput)
            var results:Array<AnyObject> = []
            if(count == 0){
                return
            }
            if(count > 0 ){
                let tmpStrInputLowerCase = self.strInput.lowercaseString
                println(tmpStrInputLowerCase)
                results = ZeeSQLiteHelper.readQueryFromDB("select VALUE ZTARGET from PINYIN_TERM where KEY between '" + tmpStrInputLowerCase + "' and '" + tmpStrInputLowerCase + "{' limit 30 offset 0")
                self.pinyinSearchComplete = 1
                println(results.count)
                self.keyTapQuerying = false
            }
            if(countElements(self.strInput) == 0){//reset blank strInput by fastQueryAndInsertFirst()
                return
            }
            if(self.wubiSearchComplete == 1){
                var pinyinData = results
                var wubiData = self.datasource
                if(wubiData.count >= pinyinData.count){
                    if(pinyinData.count > 0){
                    for var i=0; i < wubiData.count; i = i+2{
                        wubiData.insert(pinyinData.removeAtIndex(0), atIndex: i+1)
                        if(pinyinData.count == 0){
                            break
                        }
                    }
                    }
                    results = wubiData
                }else{
                    if(wubiData.count > 0){
                    for var i=0; i < pinyinData.count; i = i+2{
                        pinyinData.insert(wubiData.removeAtIndex(0), atIndex: i+1)
                        if(wubiData.count == 0){
                            break;
                        }
                    }
                    }
                    results = pinyinData
                }
            }
            
            self.datasource = results
            if(self.wubiSearchComplete == 1){
                self.reloadSelectView(self.datasource)
            }
        })
        }else{
            self.pinyinSearchComplete = 1
        }
        dispatch_async(keyboardQueue, { () -> Void in
            var count = countElements(self.strInput)
            var results:Array<AnyObject> = []
            if(count == 0){
                return
            }
            if(count > 0 ){
                let tmpStrInputLowerCase = self.strInput.lowercaseString
                println(tmpStrInputLowerCase)
                results = ZeeSQLiteHelper.readQueryFromDB("select ZTARGET from ZTIUSERWORD where ZSHORTCUT between '" + tmpStrInputLowerCase + "' and '" + tmpStrInputLowerCase + "{' limit 30 offset 0")
                self.wubiSearchComplete = 1
                println(results.count)
                self.keyTapQuerying = false
            }
            if(countElements(self.strInput) == 0){//reset blank strInput by fastQueryAndInsertFirst()
                return
            }
            if(self.pinyinSearchComplete == 1){
                var wubiData = results
                var pinyinData = self.datasource
                if(wubiData.count >= pinyinData.count){
                    if(pinyinData.count > 0){
                    for var i=0; i < wubiData.count; i = i+2{
                        wubiData.insert(pinyinData.removeAtIndex(0), atIndex: i+1)
                        if(pinyinData.count == 0){
                            break
                        }
                    }
                    }
                    results = wubiData
                }else{
                    if(wubiData.count > 0){
                    for var i=0; i < pinyinData.count; i = i+2{
                        pinyinData.insert(wubiData.removeAtIndex(0), atIndex: i+1)
                        if(wubiData.count == 0){
                            break;
                        }
                    }
                    }
                    results = pinyinData
                }
            }
            self.datasource = results
            if(self.pinyinSearchComplete == 1){
                self.reloadSelectView(results)
            }
        })
    }
    func reloadSelectView(results:Array<AnyObject>){
        //if(countElements(self.strInput) == 0){//reset blank strInput by fastQueryAndInsertFirst()
        //    return
        //}
        //println("onTimer:" + "strInput:" + self.strInput)
        self.datasource = results
        println("onTimer:load datasource")
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            //self.selectCollectionView.reloadData()
            UIView.setAnimationsEnabled(false)
            self.selectCollectionView.performBatchUpdates({ () -> Void in
                self.selectCollectionView.reloadSections(NSIndexSet(index: 0))
                }, { (finished:Bool) -> Void in
                    UIView.setAnimationsEnabled(true)
            })
            
            
        })
    }
    
    var keyboardStat = 0//wubi
    func onChangeToNum(sender:UIButton){
        keyboardStat = 1
        self.clear()
        self.wubiView.removeFromSuperview()
        
        if((self.numberView) == nil){
            var arr:Array = (NSBundle.mainBundle().loadNibNamed("WubiView", owner: self, options: nil))
            println(arr.count)
            self.numberView = arr[0] as UIView
            self.view.addSubview(numberView)
            numberView.frame = CGRectMake(0, 40, 320, 200)
            
            let l1:Array = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "0"]
            let l2:Array = ["-", "/", ":", ";", "(", ")", "$", "&", "@", "\""]
            let l3:Array = [".", ",", "?", "!", "'", "*", "%"]
            for i in 0...l1.count - 1 {
                var b:UIButton = UIButton()
                b.setTitle(l1[i], forState: UIControlState.Normal)
                b.frame = CGRectMake(32.0 * (CGFloat)(i) + 2.0, 5, 28, 40.0);
                configureBtn(b)
                
                numberView.addSubview(b)
            }
            for i in 0...l2.count - 1 {
                var b:UIButton = UIButton()
                b.setTitle(l2[i], forState: UIControlState.Normal)
                b.frame = CGRectMake(32.0 * (CGFloat)(i) + 2.0, 50, 28, 40.0);
                configureBtn(b)
                
                numberView.addSubview(b)
            }
            for i in 0...l3.count - 1 {
                var b:UIButton = UIButton()
                b.setTitle(l3[i], forState: UIControlState.Normal)
                b.frame = CGRectMake(32.0 * (CGFloat)(i) + 17.0 + 32.0, 95, 28, 40.0);
                configureBtn(b)
                numberView.addSubview(b)
            }
            numberView.backgroundColor = UIColor.groupTableViewBackgroundColor()
            let nextBtn:UIButton = numberView.viewWithTag(10) as UIButton
            nextBtn.addTarget(self, action: "advanceToNextInputMode", forControlEvents: .TouchUpInside)
            var numBtn:UIButton = numberView.viewWithTag(11) as UIButton
            var blankBtn:UIButton = numberView.viewWithTag(12) as UIButton
            var backBtn:UIButton = numberView.viewWithTag(13) as UIButton
            var dotBtn:UIButton = numberView.viewWithTag(14) as UIButton
            var backBtn2:UIButton = numberView.viewWithTag(15) as UIButton
            var backBtn3:UIButton = numberView.viewWithTag(16) as UIButton
            //configureBtnStyle(numBtn)
            configureBtnStyle(blankBtn)
            configureBtnStyle(backBtn)
            configureBtnStyle(dotBtn)
            configureBtnStyle(backBtn2)
            configureBtnStyle(backBtn3)
            blankBtn.addTarget(self, action: "onBlank:", forControlEvents: UIControlEvents.TouchDown)
            backBtn.addTarget(self, action: "onBack:", forControlEvents: UIControlEvents.TouchDown)
            backBtn.addTarget(self, action: "onBackUp:", forControlEvents: UIControlEvents.TouchUpOutside)
            backBtn.addTarget(self, action: "onBackUp:", forControlEvents: UIControlEvents.TouchUpInside)
            backBtn2.addTarget(self, action: "onBack:", forControlEvents: UIControlEvents.TouchDown)
            backBtn3.addTarget(self, action: "onBack:", forControlEvents: UIControlEvents.TouchDown)
            dotBtn.addTarget(self, action: "onDot:", forControlEvents: UIControlEvents.TouchDown)
            numBtn.addTarget(self, action: "onChangeToWubi:", forControlEvents: UIControlEvents.TouchDown)
            numBtn.setTitle("五", forState: UIControlState.Normal)
            var enterBtn:UIButton = numberView.viewWithTag(17) as UIButton
            enterBtn.addTarget(self, action: "onEnterBtn:", forControlEvents: UIControlEvents.TouchDown)
            
        }else{
            self.view.addSubview(self.numberView)
            
        }
        
    }
    func onChangeToWubi(sender:UIButton){
        keyboardStat = 0
        self.numberView.removeFromSuperview()
        self.view.addSubview(self.wubiView)
    }
    
    //override func viewDidAppear(animated: Bool) {
    //    var const:NSLayoutConstraint = NSLayoutConstraint(item: self.view, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1.0, constant: 214)
    //    //var const2:NSLayoutConstraint = NSLayoutConstraint(item: self.topView, attribute: .Top, relatedBy: .Equal, toItem: self.view, attribute: .Top, multiplier: 1.0, constant: 0)
    //    self.view.addConstraint(const)
    //    
    //    super.viewDidAppear(animated)
    //}
    
    func onEnterBtn(sender:UIButton){
        (self.textDocumentProxy as UIKeyInput).insertText("\n")
    }
    
    func onTimerTest(){
        if(self.datasource.count > 0){
            self.datasource = []
        }else{
            self.datasource = [["ZTARGET": "我"], ["ZTARGET": "是"], ["ZTARGET": "开"], ["ZTARGET": "发者"]]
        }
        UIView.setAnimationsEnabled(false)
        self.selectCollectionView.performBatchUpdates({ () -> Void in
            self.selectCollectionView.reloadSections(NSIndexSet(index: 0))
            }, { (finished:Bool) -> Void in
                UIView.setAnimationsEnabled(true)
        })
        //self.reloadData()
    }
    
    
    ///MARK: Keyboard Datasource
    override public func numberOfRowsInKeyboardView(keyboardView: KeyboardView) -> Int {
        if (self.mode == .NumberSymbols1){
            return numKeys.count
        }else if(self.mode == .Alphabet){
            return englishKeys.count
        }else if(self.mode == .Wubi){
            return wubiKeys.count
        }
        return 0
    }
    
    override public func keyboardView(keyboardView: KeyboardView, numberOfKeysInRow row:Int) -> Int {
        if (self.mode == .NumberSymbols1){
            return numKeys[row].count
        }else if(self.mode == .Alphabet){
            return englishKeys[row].count
        }else if(self.mode == .Wubi){
            return wubiKeys[row].count
        }
        return 0
    }
    
    override public func keyboardView(keyboardView: KeyboardView, keyAtIndexPath indexPath: NSIndexPath) -> KeyboardKeyView? {
        var key = ""
        if (self.mode == .NumberSymbols1){
            key = numKeys[indexPath.section][indexPath.row]
        }else if(self.mode == .Alphabet){
            key = englishKeys[indexPath.section][indexPath.row]
        }else if(self.mode == .Wubi){
            key = wubiKeys[indexPath.section][indexPath.row]
        }
        let rowIndex = indexPath.section
        var type: KeyboardKeyView.KeyType!
        
        switch key {
        case "shift":
            type = .Shift
        case "简单五笔":
            type = .Space
        case "next":
            type = .KeyboardChange
        case "backspace":
            type = .Backspace
        case "123":
            type = .ModeChange
        case "ABC":
            type = .ModeChange
        case "return":
            type = .Return
        case "backspace":
            type = .Backspace
        case "blankType1":
            type = .BlankType1
        default:
            type = .Character
        }
        
        if(self.mode == .Wubi && type == .Character){
            type = .WubiKeyType
        }
        var keyCap = key
        if(Configuration.isEnableWubiKey()){
            if wubiKeyMap[key] != nil{
                keyCap = wubiKeyMap[key]!
            }
        }
        
        let keyboardKey = KeyboardKeyView(type: type, keyCap: keyCap, outputText: key)
        switch(rowIndex){
        case 0:
            keyboardKey.textColor = UIColor(hex: Configuration.getColorTheme()["keyLineOneFont"]!)
            keyboardKey.color = UIColor(hex: Configuration.getColorTheme()["keyLineOne"]!)
            keyboardKey.selectedColor = UIColor(hex: Configuration.getColorTheme()["keyLineOneSelected"]!)
        case 1:
            keyboardKey.textColor = UIColor(hex: Configuration.getColorTheme()["keyLineTwoFont"]!)
            keyboardKey.color = UIColor(hex: Configuration.getColorTheme()["keyLineTwo"]!)
            keyboardKey.selectedColor = UIColor(hex: Configuration.getColorTheme()["keyLineTwoSelected"]!)
        case 2:
            keyboardKey.textColor = UIColor(hex: Configuration.getColorTheme()["keyLineThreeFont"]!)
            keyboardKey.color = UIColor(hex: Configuration.getColorTheme()["keyLineThree"]!)
            keyboardKey.selectedColor = UIColor(hex: Configuration.getColorTheme()["keyLineThreeSelected"]!)
        case 3:
            keyboardKey.textColor = UIColor(hex: Configuration.getColorTheme()["keyLineFourFont"]!)
            keyboardKey.color = UIColor(hex: Configuration.getColorTheme()["keyLineFour"]!)
            keyboardKey.selectedColor = UIColor(hex: Configuration.getColorTheme()["keyLineFourSelected"]!)
        default:
            let a = 1
        }
        
        
        if keyboardKey.type == KeyboardKeyView.KeyType.KeyboardChange {
            let img = UIImage(named:"KBSkinGlobeForeground")
            keyboardKey.imageView.contentMode = .Center
            keyboardKey.shouldColorImage = true
            keyboardKey.image = img
        } else if keyboardKey.type == KeyboardKeyView.KeyType.Backspace {
            let img = UIImage(named:"delete")
            keyboardKey.image = img
            keyboardKey.imageView.contentMode = .Center
            keyboardKey.shouldColorImage = true
        } else if keyboardKey.type == KeyboardKeyView.KeyType.Return {
            let img = UIImage(named:"enter")
            keyboardKey.image = img
            keyboardKey.imageView.contentMode = .Center
            keyboardKey.shouldColorImage = true
        }
        return keyboardKey
    }
    
    func keyClickSound(){

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), { () -> Void in
            //UIDevice.currentDevice().playInputClick()
            AudioServicesPlaySystemSound (1104)
            })
    }
    
    ///MARK: Key Actions
    override public func keyPressed(key: KeyboardKeyView) {
        //keyClickSound()
        if(self.mode != .Wubi){
            if("#+=" == key.keyCap!){
                self.onDot2()
            }else{
                super.keyPressed(key)
            }
        }else if(key.type == .WubiKeyType){
            if(key.keyCap == "，。？！"){
                self.onDot()
            }else{
                self.onKeyTap(key.outputText!)
            }
        }
    }
    
    /** 
    Default action is to delete the last character.
    */
    override public func backspaceKeyPressed(key: KeyboardKeyView) {
        self.onBack()
    }
    override public func backspaceKeyUp(key: KeyboardKeyView){
        self.onBackUp()
    }
    
    /**
    Default action is to insert one blank "space" character.
    */
    override public func spaceKeyPressed(key: KeyboardKeyView) {
        //keyClickSound()
        if(self.mode != .Wubi){
            super.spaceKeyPressed(key)
        }else{
            self.onBlank()
        }
    }
    
    override public func returnKeyPressed(key: KeyboardKeyView) {
        if countElements(self.strInput) == 0{
            super.returnKeyPressed(key)
        }else{
            (self.textDocumentProxy as UIKeyInput).insertText(self.strInput)
            self.strInput = ""
            clear()
        }
    }
    func collectionView(collectionView : UICollectionView,layout collectionViewLayout:UICollectionViewLayout,sizeForItemAtIndexPath indexPath:NSIndexPath) -> CGSize
    {
        
        return CGSizeMake(66, 58)
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath){
        keyClickSound()
        (self.textDocumentProxy as UIKeyInput).insertText((datasource[indexPath.row]["ZTARGET"]) as String)
        //lastType = datasource[indexPath.row]["ZTARGET"] as? String!
        clear()
    }
    //func enableInputClicksWhenVisible() -> Bool{
    //    return true
    //}
}
class WubiView:UIView{
    
}


class ts:UICollectionView{
    
}