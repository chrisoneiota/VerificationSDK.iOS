//
//  ViewController.h
//  UnidaysSampleAppObjc
//
//  Created by Adam Mitchell on 29/01/2018.
//  Copyright © 2018 MyUNiDAYS. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *subdomainTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *channelSegmentedControl;
@property (weak, nonatomic) IBOutlet UIImageView *barcodeImageView;
@property (weak, nonatomic) IBOutlet UILabel *errorLabel;
@property (weak, nonatomic) IBOutlet UITextField *codeTextField;
@end

