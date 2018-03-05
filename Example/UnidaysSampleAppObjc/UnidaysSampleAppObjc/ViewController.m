//
//  ViewController.m
//  UnidaysSampleAppObjc
//
//  Created by Adam Mitchell on 29/01/2018.
//  Copyright © 2018 MyUNiDAYS. All rights reserved.
//

#import "ViewController.h"
@import UnidaysVerificationSDK;

@interface ViewController ()

@end

@implementation ViewController

- (IBAction)getCode:(id)sender {
    NSError *error = nil;
    UnidaysConfig *config = [[UnidaysConfig alloc] initWithScheme:@"sampleapp" customerSubdomain:self.subdomainTextField.text];
    [[UnidaysSDK sharedInstance] setupWithSettings:config error: &error];
    if (!error) {
        UnidaysChannel channel = self.channelSegmentedControl.selectedSegmentIndex == 1 ? UnidaysChannelOnline : UnidaysChannelInstore;
        self.barcodeImageView.image = nil;
        [[UnidaysSDK sharedInstance] getCodeWithChannel:channel   withSuccessHandler:^(id<CodeResultProtocol> _Nonnull result) {
            self.codeTextField.text = result.code;
            if (result.imageUrl != nil) {
                [self downloadImage:result.imageUrl];
            }
        } withErrorHandler:^(NSError * _Nonnull error) {
            self.errorLabel.text = error.localizedDescription;
        }];
    }
}

- (void)downloadImage:(NSURL*)withUrl {
    dispatch_async(dispatch_get_global_queue(0,0), ^{
        NSData * data = [[NSData alloc] initWithContentsOfURL: withUrl];
        if ( data == nil )
            return;
        dispatch_async(dispatch_get_main_queue(), ^{
            self.barcodeImageView.image = [UIImage imageWithData: data];
        });
    });
}

@end
