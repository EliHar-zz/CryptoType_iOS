//
//  DecryptViewController.h
//  Crypto
//
//  Created by Elias Haroun on 2014-06-30.
//  Copyright (c) 2014 Elias Haroun. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>
#import "MainViewController.h"


#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kOFFSET_FOR_KEYBOARD 80.0;


@interface DecryptViewController : UIViewController <ADBannerViewDelegate, UINavigationControllerDelegate, UITextViewDelegate, UIActionSheetDelegate, UITextFieldDelegate>

@end

# pragma mark - ******* Global Variables *******
// Global Values (shared between the different view controllers)
extern NSString *beforeText; // Pasted Text to be decrypted
extern NSString *afterText; // decrypted read-only text

extern BOOL mainTextEdited; // indicates if the main text been accessed for typing
extern BOOL beforeTextEdited; // indicates if the before text been accessed for typing

extern NSString *decryptionPassword; // user-entered password to match sender's password

extern NSString *senderPassword; // password extracted from the message

extern int decryptionPasswordValue; // numerical value of the decryption password

extern float height; // Screen height
extern float width; // Screen width

extern float slideView_center_Y; // Center Y value of the slide view

extern int sliderTapCounter; // tap counter for the info slider

extern BOOL keyboardIsUp;

extern BOOL didDecrypt;

extern BOOL keysMatched;

extern BOOL isInKeyViewController;