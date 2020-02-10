//
//  ViewController.h
//  PNGEncodeDecode
//
//  Created by Wei WEI on 2020/2/9.
//  Copyright © 2020 Wei WEI. No rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UISwitch* ShowPwd;
@property (weak, nonatomic) IBOutlet UITextField* Input_Key;
@property (weak, nonatomic) IBOutlet UITextView* Input_Detail;
@property (weak, nonatomic) IBOutlet UILabel* Label_Help;

@end
