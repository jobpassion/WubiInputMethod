//
//  KNThirdViewController.h
//  KNSemiModalViewControllerDemo
//
//  Created by Kent Nguyen on 2/5/12.
//  Copyright (c) 2012 Kent Nguyen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KNThirdViewController : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *bgImage1;

@property (unsafe_unretained, nonatomic) IBOutlet UILabel *helpLabel;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *dismissButton;
@property (unsafe_unretained, nonatomic) IBOutlet UIButton *resizeButton;
@property UIViewController * parent;
@property NSString * themeId;

- (IBAction)dismissButtonDidTouch:(id)sender;
- (IBAction)resizeSemiModalView:(id)sender;

@end
