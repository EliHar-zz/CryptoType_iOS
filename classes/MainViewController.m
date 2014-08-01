//
//  MainViewController.m
//  Crypto
//
//  Created by Elias Haroun on 2014-06-20.
//  Copyright (c) 2014 Elias Haroun. All rights reserved.
//

#import "MainViewController.h"

@interface MainViewController ()

#pragma mark Properties: UITextViews
@property (nonatomic, strong) IBOutlet UITextView *mainTextView; // Text view to type the original message
@property (nonatomic, strong) IBOutlet UIButton *doneEditingButton; // textview to paste the encrypted message

#pragma mark Properties: Key
@property (nonatomic, strong) IBOutlet UILabel *keyLabel; // label to say Enter key OR key Entered
@property (nonatomic, strong) IBOutlet UITextField *keyTextField; // textfield to type the key
@property (nonatomic, strong) IBOutlet UIView *keyView; // Container View


#pragma mark Properties: Segmented Views
@property (nonatomic, strong) IBOutlet UISegmentedControl *segmentedControl; // Segmented control in view controller 1

@property (strong, nonatomic) IBOutlet UILabel *statusLabel; // Label to confirm message copied or not

#pragma mark Properties: Buttons
@property (nonatomic, strong) IBOutlet UIButton *sendButton; // Send as SMS or mail
@property (nonatomic, strong) IBOutlet UIButton *reCopyEncryptedButton; // Encrypts and copies message to clipboard
@property (strong, nonatomic) UIActionSheet *popup; // Action shee containing the send options

#pragma mark Properties: iAd
@property (strong, nonatomic) IBOutlet ADBannerView *adView; // ad Banner

#pragma mark Properties: Key lock mechanism
@property (nonatomic, strong) IBOutlet UIButton *key; // key button for animation
@property (nonatomic, strong) IBOutlet UIButton *Lock; // lock button for animation
@property (nonatomic, strong) IBOutlet UIView *swipeView; // view containing the key and the swipe label
@property (nonatomic, strong) IBOutlet UILabel *swipeLabel;// Swipe with increasing arrows label

#pragma mark Properties: Info slide view
@property (nonatomic, strong) IBOutlet UIButton *infoButton;// Image of the button explained
@property (nonatomic, strong) IBOutlet UIView *slideView; // outer view that slides up and down
@property (nonatomic, strong) IBOutlet UIView *slideViewInner; // inner view that contains the elements that chnage
@property (nonatomic, strong) IBOutlet UIImageView *message; // Message for the user to read
@property (nonatomic, strong) IBOutlet UIImageView *button;// Image of the button explained
@property (nonatomic, strong) IBOutlet UILabel *sliderStatus;// Image of the button explained

@end

@implementation MainViewController

# pragma mark - ******* Global Variables *******
// Global Values (shared between the different view controllers)
NSString *mainText; // original message text
NSString *beforeText; // Pasted Text to be decrypted
NSString *afterText; // decrypted read-only text

BOOL mainTextEdited; // indicates if the main text been accessed for typing
BOOL beforeTextEdited; // indicates if the before text been accessed for typing

NSString *password; // user-entered password
NSString *decryptionPassword; // user-entered password to match sender's password

NSString *encryptedPassword;
NSString *senderPassword;
int passwordValue; // int value obtained from converting the password
int decryptionPasswordValue;

float height; // Screen height
float width; // Screen width

float slideView_center_Y = 0.0; // Center Y value of the slide view

int sliderTapCounter = 1; // tap counter for the info slider

BOOL openedBefore = NO; // if the app was opened before (used to launch things for the first time only once)

BOOL keyboardIsUp = NO;

BOOL didDecrypt = NO;

BOOL keysMatched = NO;

#pragma mark - <<<< View Methods >>>>

- (void) viewDidDisappear:(BOOL)animated {
    
    [_adView removeFromSuperview];
    _adView.delegate = nil;
    _adView = nil;
    [super viewDidDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_mainTextView.text.length == 0) {
        
        _mainTextView.text = @"\n\n\n\nTap to Start Typing";
        if (IS_IPHONE)
            [_mainTextView setFont:[UIFont systemFontOfSize:15]];
        else if (IS_IPAD)
            [_mainTextView setFont:[UIFont systemFontOfSize:25]];
        _mainTextView.textAlignment = NSTextAlignmentCenter;
        _mainTextView.textColor = [UIColor grayColor];
        
    }
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    _slideView.backgroundColor = [UIColor lightGrayColor];
    _slideView.alpha = .95;
    _slideViewInner.backgroundColor = [UIColor whiteColor];
    _slideViewInner.alpha = 1;
    _slideViewInner.layer.cornerRadius = 5;
    
    _doneEditingButton.alpha = 0;
    _doneEditingButton.hidden = YES;
    
    height = self.view.frame.size.height;
    width = self.view.frame.size.width;
    
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    NSUserDefaults *savedData = [NSUserDefaults new];
    
    password = [savedData stringForKey:@"password"];
    
    openedBefore = [savedData boolForKey:@"openedBefore"];
    
    if (!openedBefore) {
        [self sliderUp];
    }
    
    _adView.delegate = self;
    
    if (password.length != 0) {
        _keyTextField.secureTextEntry = YES;
        _keyTextField.text = [NSString stringWithFormat:@"%@",password];
        passwordValue = [self getPsswrdValue:password];
        _keyLabel.text = @"Key Saved";
        [_Lock setBackgroundImage:[UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
        
    } else {
        _keyTextField.secureTextEntry = NO;
        _keyTextField.text = @"ex. pizza";
        _keyLabel.text = @"Enter Key";
        [_Lock setBackgroundImage:[UIImage imageNamed:@"unlocked.png"] forState:UIControlStateNormal];
        
    }
    
    _keyTextField.delegate = self;
    
    _reCopyEncryptedButton.layer.cornerRadius = 10;
    _sendButton.layer.cornerRadius = 10;
    _mainTextView.layer.cornerRadius = 10;
    _doneEditingButton.layer.cornerRadius = 10;
    
    self.statusLabel.alpha = 0.0;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc]
                                                    initWithTarget:self
                                                    action:@selector(handleTap:)];
    [tapGestureRecognizer setNumberOfTapsRequired:1];
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    UITapGestureRecognizer *tapToSwitchSlide = [[UITapGestureRecognizer alloc]
                                                initWithTarget:self
                                                action:@selector(handleSingleTapToSlide:)];
    [tapToSwitchSlide setNumberOfTapsRequired:1];
    [_slideView addGestureRecognizer:tapToSwitchSlide];
    
    _mainTextView.delegate = self;
    _mainTextView.text = @"\n\n\n\nTap to Start Typing";
    _mainTextView.textAlignment = NSTextAlignmentCenter;
    _mainTextView.textColor = [UIColor grayColor];
    
    if (mainTextEdited) {
        _mainTextView.text = mainText;
        _mainTextView.textAlignment = NSTextAlignmentLeft;
        _mainTextView.textColor = [UIColor whiteColor];
    }
    
    
    if (IS_IPHONE)
        [_mainTextView setFont:[UIFont systemFontOfSize:15]];
    else if (IS_IPAD)
        [_mainTextView setFont:[UIFont systemFontOfSize:25]];
    
    // Segmented control
    [_segmentedControl addTarget:self
                          action:@selector(pickOne:)
                forControlEvents:UIControlEventValueChanged];
    
    // Action sheet to send the encrypted message
    _popup = [[UIActionSheet alloc] initWithTitle:nil delegate:self
                                cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:
              @"Messages",
              @"Mail",
              nil];
    _popup.tag = 1;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField:) name:@"UITextFieldTextDidChangeNotification" object:_keyTextField];
    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [drag setMaximumNumberOfTouches:1];
    [drag setMinimumNumberOfTouches:1];
    [_key addGestureRecognizer:drag];
    
    if (openedBefore) {
        
        UIPanGestureRecognizer *dragSliderView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSliderView:)];
        [dragSliderView setMaximumNumberOfTouches:1];
        [dragSliderView setMinimumNumberOfTouches:1];
        [_slideView addGestureRecognizer:dragSliderView];
    }
    
    [self swipeLabelAnimator];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    
    // remove keyTextfield character limiting observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:_keyTextField];
    
    if (keyboardIsUp) {
        [self textViewUp:_mainTextView willMoveUp:NO];
    }
    
    // dismisses current view controller
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [super viewWillDisappear:animated];
}

# pragma mark - Info Button/Slider methods

// Press the info button
-(IBAction)infoButtonPressed:(UIButton*)sender{
    [UIView animateWithDuration:.3 animations:^(void){
        _infoButton.alpha = 0;
    }];
    sliderTapCounter = 1;
    _sliderStatus.text = @"Tap for Next >>>";
    _message.image = [UIImage imageNamed:@"copyMSG.png"];
    _button.image = [UIImage imageNamed:@"copy.png"];
    [self sliderUp];
}

// Pushes slider up
-(void) sliderUp {
    
    _slideView.alpha = 0.0;
    
    [UIView animateWithDuration:.6 animations:^(void){
        
        _slideView.hidden = NO;
        
        CGRect newSlideViewFrame = _slideView.frame;
        newSlideViewFrame.origin.y = (77.0/568)*height;
        _slideView.frame = newSlideViewFrame;
        
        _slideView.alpha = .90;
        
    }completion:^(BOOL finished) {
        slideView_center_Y = _slideView.center.y; // original center
    }];
}

// Pushes slider down
-(void) sliderDown {
    
    [UIView animateWithDuration:.6 animations:^(void){
        
        CGRect newSlideViewFrame = _slideView.frame;
        newSlideViewFrame.origin.y = height;
        _slideView.frame = newSlideViewFrame;
        
        _slideView.alpha = 0.0;
        
    }completion:^(BOOL finished) {
        _slideView.hidden = YES;
        
        // display button again
        [UIView animateWithDuration:.6 animations:^(void){
            _infoButton.alpha = .8;
        }];
    }];
}

// two line button on top of slider pushed down
-(IBAction)pushSliderDown:(UIButton*)sender{
    if (openedBefore) {
        [self sliderDown];
    }
}

// Tap to change images in slider info
- (void)handleSingleTapToSlide:(UITapGestureRecognizer *)recognizer {
    
    sliderTapCounter++;
    
    switch (sliderTapCounter) {
        case 1:{
            _sliderStatus.text = @"Tap for Next >>>";
            _message.image = [UIImage imageNamed:@"copyMSG.png"];
            _button.image = [UIImage imageNamed:@"copy.png"];
        }
            break;
        case 2:{
            _message.image = [UIImage imageNamed:@"sendMSG.png"];
            _button.image = [UIImage imageNamed:@"send.png"];
            
        }
            break;
        case 3:{
            _message.image = [UIImage imageNamed:@"lockedMSG.png"];
            _button.image = [UIImage imageNamed:@"locked.png"];
            
        }
            break;
        case 4:{
            _message.image = [UIImage imageNamed:@"unlockedMSG.png"];
            _button.image = [UIImage imageNamed:@"unlocked.png"];
            
        }
            break;
        case 5:{
            _message.image = [UIImage imageNamed:@"keyMSG.png"];
            _button.image = [UIImage imageNamed:@"key.png"];
            
        }
            break;
        case 6:{
            _sliderStatus.text = @"Slide down to hide";
            _message.image = [UIImage imageNamed:@"sameKeyMSG.png"];
            _button.image = [UIImage imageNamed:@"key.png"];
            sliderTapCounter = 0;
            
            NSUserDefaults *savedData = [NSUserDefaults new];
            if (!openedBefore) {
                openedBefore = YES;
                [savedData setBool:openedBefore forKey:@"openedBefore"];
                [savedData synchronize];
                
                UIPanGestureRecognizer *dragSliderView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSliderView:)];
                [dragSliderView setMaximumNumberOfTouches:1];
                [dragSliderView setMinimumNumberOfTouches:1];
                [_slideView addGestureRecognizer:dragSliderView];
            }
        }
            break;
    }
}

// Handler method to the UIPanGestureRecognizer to slide the view vertically
- (void) moveSliderView: (id)sender {
    
    NSLog(@"moveSliderView recognized gesture");
    
    float x = width/2; // mid width
    float translation = 0.0;
    
    // slide down if slider is not all the way on top
    if ([(UIPanGestureRecognizer*) sender state] == UIGestureRecognizerStateEnded && [sender translationInView: _slideView.superview].y > 0) {
        [self sliderDown];
    }
    
    // Handle movement
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        if ([sender translationInView: _slideView.superview].y <= 0) {
            [_slideView setCenter:CGPointMake(x, slideView_center_Y)];
        } else{
            translation = [sender translationInView: _slideView.superview].y;
            
            float currentCenter = translation + slideView_center_Y;
            
            _slideView.alpha = (slideView_center_Y/currentCenter)-.1;
            
            NSLog(@"translation In View is: %f",translation);
            NSLog(@"New Center Location is: %f",currentCenter);
            
            [UIView animateWithDuration:.2 animations:^{
                [_slideView setCenter:CGPointMake(x, currentCenter)];
            }];
        }
    }
}

#pragma mark - Key&Lock Mechanism

- (void) swipeLabelAnimator {
    
    _swipeLabel.text = @"Swipe";
    
    [self performSelector:@selector(swipe1) withObject:self afterDelay:.8];
}

- (void) swipe1 {
    
    _swipeLabel.text = @"Swipe >";
    
    [self performSelector:@selector(swipe2) withObject:self afterDelay:.7];
}

- (void) swipe2 {
    
    _swipeLabel.text = @"Swipe > >";
    
    [self performSelector:@selector(swipe3) withObject:self afterDelay:.6];
}

- (void) swipe3 {
    
    _swipeLabel.text = @"Swipe > > >";
    
    [self performSelector:@selector(swipeLabelAnimator) withObject:self afterDelay:.5];
}

// Handles the key swipe movement
- (void) move: (id) sender {
    NSLog(@"object is moving");
    
    float firstY = [[sender view] center].y; // Y-Coordinate of the center of the key
    
    // if movement ends and key is not at either proximities, return the key sliding back
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded && [sender locationInView: _key.superview].x < width*(150.0/320) && [sender locationInView: _key.superview].x > width*(23.0/320)) {
        
        [UIView animateWithDuration:.5 animations:^(void){
            [_key setCenter:CGPointMake(width*(23.0/320), firstY)]; // returns key back
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:.7 animations:^(void){
                _swipeLabel.hidden = NO;
                _swipeLabel.alpha = .8; // display the swipe animation again
            }];
        }];
    }
    
    // handles key movement
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateChanged) {
        
        // if key reaches the lock
        if ([sender locationInView: _key.superview].x >= width*(150.0/320)) {
            
            // hide key and lock then return key to its original place
            _Lock.hidden = YES;
            _key.hidden = YES;
            [_key setCenter:CGPointMake(width*(23.0/320), firstY)];
            
            _Lock.alpha = 0;
            _key.alpha = 0;
            
            [self enterkey]; // brings in the key textfield to enter/change key
            
            // keep key in place if user tries to slide it left of origin
        } else if ([sender locationInView: _key.superview].x <= width*(23.0/320)) {
            [_key setCenter:CGPointMake(width*(23.0/320), firstY)];
            
            [UIView animateWithDuration:.7 animations:^(void){
                _swipeLabel.hidden = NO;
                _swipeLabel.alpha = .8;
            }];
            
        } else {
            // If key is moving
            [_key setCenter:CGPointMake([sender locationInView: _key.superview].x, firstY)];
            [UIView animateWithDuration:.7 animations:^(void){
                
                _swipeLabel.alpha = 0; // hide the swipe label
                
            } completion:^(BOOL finished){
                _swipeLabel.hidden = YES;
            }];
        }
    }
}

// Animate display key and lock and swipe label
-(void) showKeyNLock{
    
    [UIView animateWithDuration:1 animations:^(void){
        
        _Lock.hidden = NO;
        _key.hidden = NO;
        _swipeLabel.hidden = NO;
        
        _Lock.alpha = 1;
        _key.alpha = 1;
        _swipeLabel.alpha = .8;
        
    }];
}

#pragma mark - Key TextField entry

// KeyTextField entry
-(void) enterkey {
    
    [UIView animateWithDuration:.7 animations:^(void) {
        
        CGRect keyViewFrame = _keyView.frame;
        keyViewFrame.origin.x = 0.0;
        _keyView.frame = keyViewFrame;
        
    }completion:^(BOOL finished){
        
    }];
}

// KeyTextField exit
- (void) keyEntered {
    
    [UIView animateWithDuration:.7 animations:^(void) {
        
        CGRect keyViewFrame = _keyView.frame;
        keyViewFrame.origin.x = width;
        _keyView.frame = keyViewFrame;
        
    }completion:^(BOOL finished){
        
    }];
    
}

// Not more than 5 characters allowed
- (void)limitTextField:(NSNotification *)note {
    int limit = 5;
    if (_keyTextField.text.length > limit) {
        _keyTextField.text = [_keyTextField.text substringToIndex:limit];
    }
}

// When user taps textField for editing
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @""; // empties textfield
    textField.secureTextEntry = YES; // asteriks letters
}

// When keyboard dismisses
-(void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (_keyTextField.text.length == 5)
        password = _keyTextField.text;
    else
        password = @"";
    
    NSLog(@"the encryption key is %@",password);
    passwordValue = [self getPsswrdValue:password]; // gets the numerical value of the password
    
    NSLog(@"password value is %d",passwordValue);
    
    [self keyEntered]; // hides textfield
    
    [self performSelector:@selector(showKeyNLock) withObject:self afterDelay:.7]; // shows key n lock again
}

// If user presses return button
- (BOOL) textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder]; // hides keyboard
    return YES;
}

#pragma mark - TextViews Methods

// Done editing
-(IBAction)doneEditingButton:(UIButton*)sender {
    [_mainTextView resignFirstResponder];
    _doneEditingButton.alpha = 0;
    _doneEditingButton.hidden = YES;
}

//  tap handler on the TextViews (dismisses all keyboards)
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [_mainTextView resignFirstResponder];
    [_keyTextField resignFirstResponder];
    
    _doneEditingButton.alpha = 0;
    _doneEditingButton.hidden = YES;
    
    if ([_mainTextView.text isEqualToString:@""]) {
        
        _mainTextView.text = @"\n\n\n\nTap to Start Typing";
        if (IS_IPHONE)
            [_mainTextView setFont:[UIFont systemFontOfSize:15]];
        else if (IS_IPAD)
            [_mainTextView setFont:[UIFont systemFontOfSize:25]];
        _mainTextView.textAlignment = NSTextAlignmentCenter;
        _mainTextView.textColor = [UIColor grayColor];
    }
}
- (void) textViewUp: (UITextView*) textview willMoveUp:(BOOL) will {
    
    if (will) {
        [UIView animateWithDuration:.3 animations:^{
            CGRect textViewFrame = textview.frame;
            textViewFrame.size.height = textview.frame.size.height - kOFFSET_FOR_KEYBOARD;
            textview.frame = textViewFrame;
        } completion:^(BOOL finished) {
            
        }];
    } else {
        [UIView animateWithDuration:.2 animations:^{
            CGRect textViewFrame = textview.frame;
            textViewFrame.size.height = textview.frame.size.height + kOFFSET_FOR_KEYBOARD;
            textview.frame = textViewFrame;
        } completion:^(BOOL finished) {
            
        }];
    }
}

- (void) textViewDidBeginEditing:(UITextView *)textView {
    [UIView animateWithDuration:1 animations:^(void){
        _doneEditingButton.alpha = 0.5;
        _doneEditingButton.hidden = NO;
    }];
    
    
    [self textViewUp:textView willMoveUp:YES]; // bring up textview
    
    keyboardIsUp = YES;
    
    if ([textView.text isEqualToString:@"\n\n\n\nTap to Start Typing"]) {
        _mainTextView.text = @"";
        _mainTextView.textAlignment = NSTextAlignmentLeft;
        _mainTextView.textColor = [UIColor whiteColor];
        mainTextEdited = YES;
        
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    
    [self textViewUp:textView willMoveUp:NO]; // bring down textview
    
    keyboardIsUp = NO;
    
    mainText = _mainTextView.text;
    
}

#pragma mark - UI Buttons

//Action method executes when user touches the button of segmentedControl
-(void) pickOne:(id)sender{
    UISegmentedControl *segmentedControl = (UISegmentedControl *)sender;
    
    NSString *segmentTitle = [segmentedControl titleForSegmentAtIndex: [_segmentedControl selectedSegmentIndex]];
    
    if ([segmentTitle isEqualToString:@"Decrypt"]) {
        [self performSegueWithIdentifier:@"decrypt" sender:self];
    }
    
    else if ([segmentTitle isEqualToString:@"Encrypt"]) {
        [self performSegueWithIdentifier:@"encrypt" sender:self];
    }
}

// Displays the UIActionSheet containing the send options
- (IBAction)send:(UIButton *)sender {
    if (password.length == 0) {
        UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                  message: @"Insert Key"
                                                                 delegate: nil
                                                        cancelButtonTitle: @"OK"
                                                        otherButtonTitles: nil];
        
        [noTextAlertView show]; // display error mesage
        
    }else if (![_mainTextView.text isEqualToString:@"\n\n\n\nTap to Start Typing"] && _mainTextView.text.length != 0){
        
        [_popup showInView:self.view];// Display actionSheet
    }
    else {
        UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                  message: @"No Text to Encrypt and Send"
                                                                 delegate: nil
                                                        cancelButtonTitle: @"OK"
                                                        otherButtonTitles: nil];
        
        [noTextAlertView show]; // display error mesage
    }
}

// ActionSheet Options
- (void)actionSheet:(UIActionSheet *)popup clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    switch (popup.tag) {
        case 1: {
            switch (buttonIndex) {
                case 0:{
                    
                    MFMessageComposeViewController *controller;
                    
                    if([MFMessageComposeViewController canSendText])
                    {
                        controller = [[MFMessageComposeViewController alloc] init];
                        
                        [self process:_mainTextView]; // encrypts text in mainTextView
                        [self encryptPassword:password]; // encrypts the password
                        
                        // Message content
                        controller.body = [NSString stringWithFormat:@"Encrypted-Message://%ld \n\n>> %@%@ << \n\n Sent with CryptoType\n\n http://appstore.com/cryptotype", (long)_mainTextView.text.length, encryptedPassword, afterText];
                        
                        controller.messageComposeDelegate = self;
                        
                        [self presentViewController:controller animated:YES completion:nil];
                    }else {
                        NSLog(@"cannot send SMS");
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CryptoType" message:@"The device can't send message"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                    }
                }break;
                case 1:{
                    
                    MFMailComposeViewController *controller;
                    
                    if([MFMailComposeViewController canSendMail])
                    {
                        
                        controller = [[MFMailComposeViewController alloc] init];
                        
                        [self process:_mainTextView]; // encrypts text in mainTextView
                        [self encryptPassword:password]; // encrypts password
                        
                        //Email subject
                        [controller setSubject:@"Encrypted Message - CryptoType iOS App"];
                        
                        // Email content
                        [controller setMessageBody:[NSString stringWithFormat:@"Encrypted-Message://%ld \n\n>> %@%@ << \n\n Sent with CryptoType\n\n http://appstore.com/cryptotype", (long)_mainTextView.text.length, encryptedPassword, afterText] isHTML:NO];
                        
                        controller.mailComposeDelegate = self;
                        
                        [self presentViewController:controller animated:YES completion:nil];
                    } else {
                        NSLog(@"cannot send mail");
                        
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CryptoType" message:@"The device can't send mail"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                    }
                    
                }break;
            }
        }
    }
}

// Handle event after mail compser closed
- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    
    switch (result) {
        case MFMailComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MFMailComposeResultFailed: {
            NSLog(@"error");
            
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CryptoType" message:@"Unknown Error"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case MFMailComposeResultSent: {
            NSLog(@"sent");
        }
            break;
        case MFMailComposeResultSaved: {
            NSLog(@"saved");
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
    
}

// Handle event after msg compser closed
- (void) messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    
    switch (result) {
        case MessageComposeResultCancelled: {
            NSLog(@"Cancelled");
        }
            break;
        case MessageComposeResultFailed: {
            NSLog(@"error");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"CryptoType" message:@"Unknown Error"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
        }
            break;
        case MessageComposeResultSent: {
            NSLog(@"sent");
            
        }
            break;
        default:
            break;
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Encrypts and copies text to clipboard
- (IBAction)copyEncrypted:(UIButton*)sender {
    
    // if no password entered
    if (password.length == 0) {
        UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                  message: @"Insert Key"
                                                                 delegate: nil
                                                        cancelButtonTitle: @"OK"
                                                        otherButtonTitles: nil];
        
        [noTextAlertView show]; // display error mesage
        
        // if default text is still there
    }else if (![_mainTextView.text isEqualToString:@"\n\n\n\nTap to Start Typing"] && _mainTextView.text.length != 0){
        
        // copy to general Pasteboard
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        [self process:_mainTextView];
        
        [self encryptPassword:password]; // encrypts password
        
        pasteboard.string = [NSString stringWithFormat: @"%@%@", encryptedPassword, afterText];
        
        [_mainTextView resignFirstResponder]; // dismisses keyboard
        
        // Display message that image is saved
        self.statusLabel.hidden = NO;
        self.statusLabel.text = @"Message Copied";
        self.statusLabel.alpha = 1;
        self.statusLabel.layer.cornerRadius = 7;
        self.statusLabel.enabled = YES;
        
        [self performSelector:@selector(hideMessage) withObject:nil afterDelay: 2];
        
        
        
    } else {
        UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                  message: @"No Text to Encrypt and Copy"
                                                                 delegate: nil
                                                        cancelButtonTitle: @"OK"
                                                        otherButtonTitles: nil];
        
        [noTextAlertView show]; // display error mesage
    }
}

// clears main
- (IBAction)clearMainTextView:(UIButton*)sender {
    
    mainText = @"";
    
    _mainTextView.text = @"\n\n\n\nTap to Start Typing";
    
    if (IS_IPHONE)
        [_mainTextView setFont:[UIFont systemFontOfSize:15]];
    else if (IS_IPAD)
        [_mainTextView setFont:[UIFont systemFontOfSize:25]];
    
    _mainTextView.textAlignment = NSTextAlignmentCenter;
    _mainTextView.textColor = [UIColor grayColor];
}

// Copies the decrypted message from the TextView
- (void)copyDecryptedMessage {
    UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
    pasteboard.string = afterText;
    
    // Display message that image is saved
    self.statusLabel.hidden = NO;
    self.statusLabel.text = @"Message Copied";
    self.statusLabel.alpha = 1;
    self.statusLabel.layer.cornerRadius = 7;
    self.statusLabel.enabled = YES;
    [self performSelector:@selector(hideMessage) withObject:nil afterDelay: 2];
    
}
// Event to occur after the delay
- (void)hideMessage {
    [UIView animateWithDuration:1 animations:^(void) {
        self.statusLabel.alpha = 0;
    }completion:^(BOOL finished) {
        self.statusLabel.hidden = YES;
    }];
}

#pragma mark - Logic Methods

- (int) getPsswrdValue: (NSString*) passwordString {
    
    NSUserDefaults *savedData = [NSUserDefaults new];
    
    int total = 0;
    
    if (passwordString.length > 5 || passwordString.length < 5) {
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"CryptoType" message:@"key must be 5 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [message show];
        
        
        _keyTextField.secureTextEntry = NO;
        _keyTextField.text = @"ex. pizza";
        
        _keyLabel.text = @"Enter Key";
        passwordString = @"";
        [savedData setObject:passwordString forKey:@"password"];
        [savedData synchronize];
        [_Lock setBackgroundImage:[UIImage imageNamed:@"unlocked.png"] forState:UIControlStateNormal];
    } else {
        
        [savedData setObject:password forKey:@"password"];
        [savedData synchronize];
        [_Lock setBackgroundImage:[UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
        
        _keyLabel.text = @"Key Saved";
        
        
        for (int i = 0; i<[passwordString length]; i++){
            
            total +=([passwordString characterAtIndex:i]*(i+1));
        }
        
        NSLog(@"password value before processing: %d", total);
        
        total +='x';
        
        total *= 0.35427;
        
        total = (int) total;
        
        NSLog(@"password value after processing: %d", total);
        
    }
    return total;
}

// Encrypt the text and store the result as a string
- (void) encryptPassword: (NSString *) passowrdString {
    
    int defaultPasswordValue = 514;
    char c;
    NSMutableString *afterTextString = [NSMutableString stringWithCapacity:[passowrdString length]];
    NSString *temp;
    
    double tempPasswordValue1 = defaultPasswordValue * 1;
    double tempPasswordValue2 = defaultPasswordValue * 2;
    double tempPasswordValue3 = defaultPasswordValue * 3;
    double tempPasswordValue4 = defaultPasswordValue * 4;
    double tempPasswordValue5 = defaultPasswordValue * 5;
    
    for (int i = 0; i<[passowrdString length]; i++){
        
        c =[passowrdString characterAtIndex:i];
        
        switch (i) {
            case 0:
                defaultPasswordValue = tempPasswordValue1;
                break;
            case 1:
                defaultPasswordValue = tempPasswordValue2;
                
                break;
            case 2:
                defaultPasswordValue = tempPasswordValue3;
                
                break;
            case 3:
                defaultPasswordValue = tempPasswordValue4;
                
                break;
            case 4:
                defaultPasswordValue = tempPasswordValue5;
                
                break;
        }
        
        c  += (int)defaultPasswordValue;
        
        temp = [NSString stringWithFormat:@"%c", c];
        
        [afterTextString appendString:temp];
    }
    
    encryptedPassword = afterTextString;
    
    NSLog(@"the encrypted password is: %@",encryptedPassword);
}

// Encrypt the text and store the result as a string
- (void) process: (UITextView *) textView {
    
    NSString *beforeTextString = textView.text;
    
    char c;
    NSMutableString *afterTextString = [NSMutableString stringWithCapacity:[beforeTextString length]];
    NSString *temp;
    double tempPasswordValue1, tempPasswordValue2, tempPasswordValue3, tempPasswordValue5, tempPasswordValue7, tempPasswordValue13;
    
    int tempPasswordValue = (int)passwordValue;
    
    tempPasswordValue1 = passwordValue * 1;
    tempPasswordValue2 = passwordValue * 2;
    tempPasswordValue3 = passwordValue * 3;
    tempPasswordValue5 = passwordValue * 4;
    tempPasswordValue7 = passwordValue * 5;
    tempPasswordValue13 = passwordValue * 6;
    
    for (int i = 0; i<[beforeTextString length]; i++){
        
        c =[beforeTextString characterAtIndex:i];
        
        if (i % 2 == 0) {
            tempPasswordValue = tempPasswordValue2;
        } if (i % 3 == 0) {
            tempPasswordValue = tempPasswordValue3;
        }if (i % 5 == 0) {
            tempPasswordValue = tempPasswordValue5;
        }if (i % 7 == 0) {
            tempPasswordValue = tempPasswordValue7;
        }if (i % 13 == 0) {
            tempPasswordValue = tempPasswordValue13;
        }else {
            tempPasswordValue = tempPasswordValue1;
        }
        
        c  += (int)tempPasswordValue;
        
        temp = [NSString stringWithFormat:@"%c", c];
        
        [afterTextString appendString:temp];
    }
    
    
    NSLog(@"%@",afterTextString);
    
    afterText = afterTextString;
}

#pragma mark - iAd Delegate Methods

- (void) bannerViewDidLoadAd:(ADBannerView *)banner {
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition: UIViewAnimationTransitionCurlUp forView:banner cache:NO];
    [banner setAlpha:1];
    [UIView commitAnimations];
    
}

- (void) bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error {
    
    [banner setAlpha:0];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:1];
    [UIView setAnimationTransition: UIViewAnimationTransitionCurlDown forView:banner cache:NO];
    [UIView commitAnimations];
}

@end
