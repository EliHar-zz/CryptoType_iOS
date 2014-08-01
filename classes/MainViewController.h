//
//  MainViewController.h
//  Crypto
//
//  Created by Elias Haroun on 2014-06-20.
//  Copyright (c) 2014 Elias Haroun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <iAd/iAd.h>


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kOFFSET_FOR_KEYBOARD 80.0;


@interface MainViewController : UIViewController <ADBannerViewDelegate, UINavigationControllerDelegate, UITextViewDelegate, MFMessageComposeViewControllerDelegate, MFMailComposeViewControllerDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@end
