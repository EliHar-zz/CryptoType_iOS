//
//  DecryptViewController.m
//  Crypto
//
//  Created by Elias Haroun on 2014-06-30.
//  Copyright (c) 2014 Elias Haroun. All rights reserved.
//

#import "DecryptViewController.h"

@interface DecryptViewController ()

#pragma mark Properties: UITextViews
@property (nonatomic, strong) IBOutlet UITextView *beforeTextView; // textview to paste the encrypted message
@property (nonatomic, strong) IBOutlet UIButton *doneEditingButton; // textview to paste the encrypted message

#pragma mark Properties: Key
@property (nonatomic, strong) IBOutlet UILabel *keyLabel; // label to say Enter key OR key Entered
@property (nonatomic, strong) IBOutlet UITextField *senderKeyTextField; // textfield to type the sender key
@property (nonatomic, strong) IBOutlet UIView *keyView; // Container View

@property (strong, nonatomic) IBOutlet UILabel *statusLabel; // Label to confirm message copied or not

#pragma mark Properties: Buttons
@property (nonatomic, strong) IBOutlet UIButton *decryptButton; // Decrypt

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
@property (nonatomic, strong) IBOutlet UILabel *instruction; // Message for the user to read
@property (nonatomic, strong) IBOutlet UIImageView *button;// Image of the button explained
@property (nonatomic, strong) IBOutlet UILabel *sliderStatus;// Image of the button explained

@end

@implementation DecryptViewController

#pragma mark - <<<< View Methods >>>>

- (void) viewDidDisappear:(BOOL)animated {
    
    [_adView removeFromSuperview];
    _adView.delegate = nil;
    _adView = nil;
    [super viewDidDisappear:animated];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (_beforeTextView.text.length == 0) {
        _beforeTextView.text = @"\n\n\n\nPaste The Ecrypted Message Here";
        if (IS_IPHONE)
            [_beforeTextView setFont:[UIFont systemFontOfSize:15]];
        else if (IS_IPAD)
            [_beforeTextView setFont:[UIFont systemFontOfSize:25]];
        _beforeTextView.textAlignment = NSTextAlignmentCenter;
        _beforeTextView.textColor = [UIColor grayColor];
    }
    
    if (decryptionPassword.length != 0) {
        _senderKeyTextField.secureTextEntry = YES;
        _senderKeyTextField.text = [NSString stringWithFormat:@"%@",decryptionPassword];
        decryptionPasswordValue = [self getPsswrdValue:decryptionPassword];
        _keyLabel.text = @"Key Saved";
        [_Lock setBackgroundImage:[UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
        
        if (senderPassword.length != 0) {
            
            if (keysMatched) {
                [_key setBackgroundImage:[UIImage imageNamed:@"greenKey.png"]
                                forState:UIControlStateNormal];
            } else {
                [_key setBackgroundImage:[UIImage imageNamed:@"redKey.png"]
                                forState:UIControlStateNormal];
            }
        } else {
            [_key setBackgroundImage:[UIImage imageNamed:@"key.png"]
                            forState:UIControlStateNormal];
        }
    } else {
        _senderKeyTextField.secureTextEntry = NO;
        _senderKeyTextField.text = @"ex. admin";
        _keyLabel.text = @"Enter Key";
        [_Lock setBackgroundImage:[UIImage imageNamed:@"unlocked.png"] forState:UIControlStateNormal];
        [_key setBackgroundImage:[UIImage imageNamed:@"key.png"]
                        forState:UIControlStateNormal];
    }
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if (decryptionPassword.length == 0 && !isInKeyViewController) {
        isInKeyViewController = YES;
        [self performSegueWithIdentifier:@"toKey" sender:self];
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
    
    if ([[UIScreen mainScreen] bounds].size.height != 568.0f) {
        CGRect newframe = _doneEditingButton.frame;
        newframe.origin.y -= 88.0f;
        _doneEditingButton.frame = newframe;
    }
    
    height = self.view.frame.size.height;
    width = self.view.frame.size.width;
    
    [[self navigationController] setNavigationBarHidden:YES];
    
    _adView.delegate = self;
    
    _senderKeyTextField.delegate = self;
    
    
    _decryptButton.layer.cornerRadius = 10;
    _beforeTextView.layer.cornerRadius = 10;
    _doneEditingButton.layer.cornerRadius = 10;
    
    //[self.statusLabel setBackgroundColor:[UIColor darkGrayColor]];
    
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
    
    _beforeTextView.delegate = self;
    if (IS_IPHONE)
        [_beforeTextView setFont:[UIFont systemFontOfSize:15]];
    else if (IS_IPAD)
        [_beforeTextView setFont:[UIFont systemFontOfSize:25]];
    
    if (!didDecrypt) {
        _beforeTextView.text = @"\n\n\n\nPaste The Ecrypted Message Here";
        _beforeTextView.textAlignment = NSTextAlignmentCenter;
        _beforeTextView.textColor = [UIColor grayColor];
        
        if (beforeTextEdited) {
            _beforeTextView.text = beforeText;
            _beforeTextView.textAlignment = NSTextAlignmentLeft;
            _beforeTextView.textColor = [UIColor whiteColor];
        }
        
        _beforeTextView.editable = YES;
        _beforeTextView.selectable = YES;
        _beforeTextView.dataDetectorTypes = UIDataDetectorTypeNone;
        
        [_decryptButton setBackgroundImage:[UIImage imageNamed:@"button_decrypt.png"] forState:UIControlStateNormal];
    } else {
        _beforeTextView.text = afterText;
        
        _beforeTextView.editable = NO;
        _beforeTextView.selectable = YES;
        _beforeTextView.dataDetectorTypes = UIDataDetectorTypeAll;
        
        [_decryptButton setBackgroundImage:[UIImage imageNamed:@"button_copy.png"] forState:UIControlStateNormal];
        
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(limitTextField2:) name:@"UITextFieldTextDidChangeNotification" object:_senderKeyTextField];
    
    
    
    UIPanGestureRecognizer *drag = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(move:)];
    [drag setMaximumNumberOfTouches:1];
    [drag setMinimumNumberOfTouches:1];
    [_key addGestureRecognizer:drag];
    
    
    UIPanGestureRecognizer *dragSliderView = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveSliderView:)];
    [dragSliderView setMaximumNumberOfTouches:1];
    [dragSliderView setMinimumNumberOfTouches:1];
    [_slideView addGestureRecognizer:dragSliderView];
    
    [self swipeLabelAnimator];
    
}

-(void) viewWillDisappear:(BOOL)animated {
    
    // remove keyTextfield character limiting observer
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UITextFieldTextDidChangeNotification" object:_senderKeyTextField];
    
    
    // Brings TextView to original size upon view change
    if (keyboardIsUp) {
        [self textViewUp:_beforeTextView willMoveUp:NO];
    }
    
    [super viewWillDisappear:animated];
}

// hide status bar
- (BOOL)prefersStatusBarHidden {
    return YES;
}

# pragma mark - Info Button/Slider methods

// Press the info button
-(IBAction)infoButtonPressed:(UIButton*)sender{
    [UIView animateWithDuration:.3 animations:^(void){
        _infoButton.alpha = 0;
    }];
    sliderTapCounter = 1;
    _sliderStatus.text = @"Tap for Next >>>";
    _button.image = [UIImage imageNamed:@"main.png"];
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
        
        _slideView.alpha = .99;
        
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
    [self sliderDown];
}

// Tap to change images in slider info
- (void)handleSingleTapToSlide:(UITapGestureRecognizer *)recognizer {
    
    sliderTapCounter++;
    
    switch (sliderTapCounter) {
        case 1:{
            CGRect labelFrame = _instruction.frame;
            labelFrame.origin.y -= 75.0f;
            _instruction.frame = labelFrame;
            
            _sliderStatus.text = @"Tap for Next >>>";
            _button.image = [UIImage imageNamed:@"main.png"];
            _instruction.text = @"";
            
        }
            break;
        case 2:{
            _button.image = [UIImage imageNamed:@"corner_lock_unlocked.png"];
            _instruction.text = @"Indicates no key entered";
            
            
        }
            break;
        case 3:{
            _button.image = [UIImage imageNamed:@"key_tut.png"];
            _instruction.text = @"Press this button to enter or change the key";
            
            
        }
            break;
        case 4:{
            _button.image = [UIImage imageNamed:@"enterkey.png"];
            _instruction.text = @"";
            
            
        }
            break;
        case 5:{
            _button.image = [UIImage imageNamed:@"corner_lock_locked.png"];
            _instruction.text = @"Indicates key entered";
            
            
        }
            break;
        case 6:{
            _button.image = [UIImage imageNamed:@"clear1.png"];
            _instruction.text = @"Clears the typed message";
            
            
        }
            break;
        case 7:{
            _button.image = [UIImage imageNamed:@"copy1.png"];
            _instruction.text = @"Encrypts and copies the encrypted text to clipboard";
            
            
        }
            break;
        case 8:{
            _button.image = [UIImage imageNamed:@"send1.png"];
            _instruction.text = @"Gives choice to send encrypted text as SMS or Email";
            
            
        }
            break;
        case 9:{
            _button.image = [UIImage imageNamed:@"decrypt_main.png"];
            _instruction.text = @"";
            
            
        }
            break;
        case 10:{
            _button.image = [UIImage imageNamed:@"decrypt1.png"];
            _instruction.text = @"Decrypts the encrypted message";
            
            
        }
            break;
        case 11:{
            _button.image = [UIImage imageNamed:@"red1.png"];
            _instruction.text = @"If the decryption key doesn't match that of the sender";
            
            
        }
            break;
        case 12:{
            _button.image = [UIImage imageNamed:@"green1.png"];
            _instruction.text = @"If the decryption key matches that of the sender";
            
            
        }
            break;
        case 13:{
            _button.image = [UIImage imageNamed:@"message_main.png"];
            _instruction.text = @"Received encrypted message";
            _instruction.backgroundColor = [UIColor darkGrayColor];
            
            CGRect labelFrame = _instruction.frame;
            labelFrame.origin.y += 75.0f;
            _instruction.frame = labelFrame;
        }
            break;
        case 14:{
            _button.image = [UIImage imageNamed:@"message.png"];
            _instruction.text = @"Received encrypted message";
            _instruction.backgroundColor = nil;
            
            
            
        }
            break;
        case 15:{
            _button.image = [UIImage imageNamed:@"message_copy.png"];
            _instruction.text = @"Copy Entire message";
            
            
        }
            break;
        case 16:{
            NSString *arrow = [[NSString alloc] initWithUTF8String:"\xE2\x87\xA3"];
            _sliderStatus.text = [NSString stringWithFormat:@"%@ Slide down to hide %@",arrow,arrow];
            _button.image = [UIImage imageNamed:@"tap_link.png"];
            _instruction.text = @"Tap the CryptoType link to open the app and go to the decrypt screen";
            
            sliderTapCounter = 0;
        }
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
- (IBAction)keyPressed:(UIButton *)sender {
    isInKeyViewController = YES;
    [self performSegueWithIdentifier:@"toKey" sender:self];
}


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
    if ([(UIPanGestureRecognizer*)sender state] == UIGestureRecognizerStateEnded && [sender locationInView: _key.superview].x < width*(244.0f/320) && [sender locationInView: _key.superview].x > width*(42.0f/320)) {
        
        [UIView animateWithDuration:.5 animations:^(void){
            [_key setCenter:CGPointMake(width*(42.0f/320), firstY)]; // returns key back
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
        if ([sender locationInView: _key.superview].x >= width*(244.0f/320)) {
            
            // hide key and lock then return key to its original place
            _Lock.hidden = YES;
            _key.hidden = YES;
            [_key setCenter:CGPointMake(width*(42.0f/320), firstY)];
            
            _Lock.alpha = 0;
            _key.alpha = 0;
            
            [self enterkey]; // brings in the key textfield to enter/change key
            
            // keep key in place if user tries to slide it left of origin
        } else if ([sender locationInView: _key.superview].x <= width*(42.0f/320)) {
            [_key setCenter:CGPointMake(width*(42.0f/320), firstY)];
            
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
        
        _Lock.alpha = .7;
        _key.alpha = .7;
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
        if (decryptionPassword.length != 0) {
            isInKeyViewController = NO;
            [self dismissViewControllerAnimated:YES completion:nil];
        }
        
    }];
    
}

// Not more than 5 characters allowed
- (void)limitTextField2:(NSNotification *)note {
    int limit = 5;
    if (_senderKeyTextField.text.length > limit) {
        _senderKeyTextField.text = [_senderKeyTextField.text substringToIndex:limit];
    }
}

// When user taps textField for editing
- (void) textFieldDidBeginEditing:(UITextField *)textField {
    textField.text = @""; // empties textfield
    textField.secureTextEntry = YES; // asteriks letters
}

// When keyboard dismisses
-(void) textFieldDidEndEditing:(UITextField *)textField {
    
    if (_senderKeyTextField.text.length == 5)
        decryptionPassword = _senderKeyTextField.text;
    else
        decryptionPassword = @"";
    
    NSLog(@"the decryption key is %@",decryptionPassword);
    
    decryptionPasswordValue = [self getPsswrdValue:decryptionPassword]; // gets the numerical value of the password
    NSLog(@"decryption Password Value is %d",decryptionPasswordValue);
    
    
    if (senderPassword.length != 0) {
        
        if (decryptionPassword.length != 0) {
            
            if (![decryptionPassword isEqualToString: senderPassword]) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your decryption key doesn't match the sender's encryption key"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                
                keysMatched = NO;
                [_key setBackgroundImage:[UIImage imageNamed:@"redKey.png"]
                                forState:UIControlStateNormal];
            } else {
                keysMatched = YES;
                [_key setBackgroundImage:[UIImage imageNamed:@"greenKey.png"]
                                forState:UIControlStateNormal];
            }
        }
    }
    
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
    [_beforeTextView resignFirstResponder];
    _doneEditingButton.alpha = 0;
    _doneEditingButton.hidden = YES;
}

//  tap handler on the TextViews (dismisses all keyboards)
- (void)handleTap:(UITapGestureRecognizer *)recognizer {
    [_beforeTextView resignFirstResponder];
    [_senderKeyTextField resignFirstResponder];
    
    _doneEditingButton.alpha = 0;
    _doneEditingButton.hidden = YES;
    
    if ([_beforeTextView.text isEqualToString:@""]) {
        _beforeTextView.text = @"\n\n\n\nPaste The Ecrypted Message Here";
        senderPassword = @"";
        if (IS_IPHONE)
            [_beforeTextView setFont:[UIFont systemFontOfSize:15]];
        else if (IS_IPAD)
            [_beforeTextView setFont:[UIFont systemFontOfSize:25]];
        _beforeTextView.textAlignment = NSTextAlignmentCenter;
        _beforeTextView.textColor = [UIColor grayColor];
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
    
    if ([textView.text isEqualToString:@"\n\n\n\nPaste The Ecrypted Message Here"]) {
        _beforeTextView.text = @"";
        senderPassword = @"";
        _beforeTextView.textAlignment = NSTextAlignmentLeft;
        _beforeTextView.textColor = [UIColor whiteColor];
        beforeTextEdited = YES;
    }
}

- (void) textViewDidEndEditing:(UITextView *)textView {
    
    [self textViewUp:textView willMoveUp:NO]; // bring down textview
    
    keyboardIsUp = NO;
    
    beforeText = _beforeTextView.text;
    
    if (textView.text.length != 0) {
        
        if (textView.text.length >= 5) {
            
            if (textView.text.length > 13 && [[textView.text substringToIndex:13] isEqualToString:@"CryptoType://"]){
                beforeText = [self trimText:_beforeTextView.text];
                _beforeTextView.text = beforeText;
            } else {
                NSString *tempPassword = [beforeText substringWithRange:NSMakeRange(0, 5)];
                
                [self decryptPassword:tempPassword];
                
                if (decryptionPassword.length != 0) {
                    
                    if (![decryptionPassword isEqualToString: senderPassword]) {
                        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your decryption key doesn't match the sender's encryption key"
                                                                       delegate:self
                                                              cancelButtonTitle:@"OK"
                                                              otherButtonTitles:nil, nil];
                        [alert show];
                        keysMatched = NO;
                        [_key setBackgroundImage:[UIImage imageNamed:@"redKey.png"]
                                        forState:UIControlStateNormal];
                        
                    } else {
                        keysMatched = YES;
                        [_key setBackgroundImage:[UIImage imageNamed:@"greenKey.png"]
                                        forState:UIControlStateNormal];
                    }
                } else {
                    [_key setBackgroundImage:[UIImage imageNamed:@"key.png"]
                                    forState:UIControlStateNormal];
                }
            }
        }else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Incomplete Text"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            
            [self resetTextView];
        }
    }
}

- (void) resetTextView {
    beforeText = @"";
    afterText = @"";
    _beforeTextView.text = @"\n\n\n\nPaste The Ecrypted Message Here";
    senderPassword = @"";
    keysMatched = NO;
    if (IS_IPHONE)
        [_beforeTextView setFont:[UIFont systemFontOfSize:15]];
    else if (IS_IPAD)
        [_beforeTextView setFont:[UIFont systemFontOfSize:25]];
    _beforeTextView.textAlignment = NSTextAlignmentCenter;
    _beforeTextView.textColor = [UIColor grayColor];
    [_key setBackgroundImage:[UIImage imageNamed:@"key.png"]
                    forState:UIControlStateNormal];
}

#pragma mark - UI Buttons

- (IBAction)back:(UIBarButtonItem *)sender {
    //isInKeyViewController = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

// Decrypts the text in the beforeTextView
- (IBAction)decrypt:(UIButton*)sender {
    
    if (!didDecrypt) {
        
        if (decryptionPassword.length == 0) {
            UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                      message: @"Insert Key"
                                                                     delegate: nil
                                                            cancelButtonTitle: @"OK"
                                                            otherButtonTitles: nil];
            
            [noTextAlertView show]; // display error mesage
            
        }else if (![_beforeTextView.text isEqualToString:@"\n\n\n\nPaste The Ecrypted Message Here"] && _beforeTextView.text.length != 0){
            if (keysMatched) {
                [self decryptProcess:_beforeTextView];
                
                
                didDecrypt = YES; // Decryption occured
                
                _beforeTextView.text = afterText;
                _beforeTextView.editable = NO;
                _beforeTextView.selectable = YES;
                _beforeTextView.dataDetectorTypes = UIDataDetectorTypeAll;
                
                [_decryptButton setBackgroundImage:[UIImage imageNamed:@"button_copy.png"] forState:UIControlStateNormal];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"Your decryption key doesn't match the sender's encryption key"
                                                               delegate:self
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil, nil];
                [alert show];
            }
        } else {
            UIAlertView *noTextAlertView = [[UIAlertView alloc] initWithTitle: @"Oops!"
                                                                      message: @"No Text to Decrypt"
                                                                     delegate: nil
                                                            cancelButtonTitle: @"OK"
                                                            otherButtonTitles: nil];
            
            [noTextAlertView show]; // display error mesage
        }
        
    } else {
        [self copyDecryptedMessage];
    }
}

// clears the decryption text views
- (IBAction)clearBeforeTextView:(UIButton*)sender {
    
    [self resetTextView];
    
    didDecrypt = NO;
    
    _beforeTextView.editable = YES;
    _beforeTextView.selectable = YES;
    _beforeTextView.dataDetectorTypes = UIDataDetectorTypeNone;
    
    [_decryptButton setBackgroundImage:[UIImage imageNamed:@"button_decrypt.png"] forState:UIControlStateNormal];
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
    
    int total = 0;
    
    if (passwordString.length > 5 || passwordString.length < 5) {
        
        
        UIAlertView *message = [[UIAlertView alloc] initWithTitle:@"Oops!" message:@"key must be 5 characters" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        
        [message show];
        
        _senderKeyTextField.secureTextEntry = NO;
        _senderKeyTextField.text = @"ex. admin";
        
        _keyLabel.text = @"Enter Key";
        passwordString = @"";
        
        [_Lock setBackgroundImage:[UIImage imageNamed:@"unlocked.png"] forState:UIControlStateNormal];
        [_key setBackgroundImage:[UIImage imageNamed:@"key.png"]forState:UIControlStateNormal];
        NSLog(@"No key entered");
        
    } else {
        
        [_Lock setBackgroundImage:[UIImage imageNamed:@"locked.png"] forState:UIControlStateNormal];
        
        _keyLabel.text = @"Key Saved";
        
        
        for (int i = 0; i<[passwordString length]; i++){
            
            total +=([passwordString characterAtIndex:i]*(i+1));
        }
        
        NSLog(@"decryption password value before processing: %d", total);
        
        total +='x';
        
        total *= 0.35427;
        
        total = (int) total;
        
        NSLog(@"decryption password value after processing: %d", total);
        
    }
    return total;
}

// Encrypt the text and store the result as a string
- (void) decryptPassword: (NSString *) passowrdString {
    
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
        
        c  -= (int)defaultPasswordValue;
        
        temp = [NSString stringWithFormat:@"%c", c];
        
        [afterTextString appendString:temp];
    }
    
    senderPassword = afterTextString;
    
    NSLog(@"the sender's key is: %@", senderPassword);
}

// Encrypt the text and store the result as a string
- (void) decryptProcess: (UITextView *) textView {
    
    NSString *beforeTextString = [textView.text substringFromIndex:5];
    
    char c;
    NSMutableString *afterTextString = [NSMutableString stringWithCapacity:[beforeTextString length]];
    NSString *temp;
    double tempPasswordValue1, tempPasswordValue2, tempPasswordValue3, tempPasswordValue5, tempPasswordValue7, tempPasswordValue13;
    
    int tempPasswordValue = (int)decryptionPasswordValue;
    
    tempPasswordValue1 = decryptionPasswordValue * 1;
    tempPasswordValue2 = decryptionPasswordValue * 2;
    tempPasswordValue3 = decryptionPasswordValue * 3;
    tempPasswordValue5 = decryptionPasswordValue * 4;
    tempPasswordValue7 = decryptionPasswordValue * 5;
    tempPasswordValue13 = decryptionPasswordValue * 6;
    
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
        
        c  -= (int)tempPasswordValue;
        
        temp = [NSString stringWithFormat:@"%c", c];
        
        [afterTextString appendString:temp];
    }
    
    NSLog(@"%@",afterTextString);
    
    afterText = afterTextString;
}

// Trim message
- (NSString*) trimText:(NSString*) pastedText{
    
    NSString *text = pastedText;// text including encrypted text
    NSMutableString *textLengthString = [NSMutableString new];
    
    NSString *temp;
    int counter = 0;
    
    for (int i = 13; i<[pastedText length]; i++){
        
        char c = [text characterAtIndex:i];
        
        if (c >= '0' && c <= '9') {
            temp = [NSString stringWithFormat:@"%c",c];
        } else
            break;
        
        [textLengthString appendString:temp];
    }
    
    NSInteger textLength = [textLengthString intValue];
    
    NSLog(@"message length is: %@",textLengthString);
    
    for (int i = 0; i<[pastedText length]; i++){
        
        char c = [text characterAtIndex:i];
        
        if (c != '[') {
            counter++;
        } else
            break;
    }
    
    NSLog(@"%d",counter);
    NSLog(@"%ld",counter+3+textLength);
    
    NSRange range = NSMakeRange(counter+3, textLength+5);
    
    NSString *finalString;
    
    if (pastedText.length >= range.length+range.location) {
        finalString = [pastedText substringWithRange:range];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!!" message:@"Incomplete Text"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
    }
    
    NSLog(@"decrypted msg including psswrd%@",finalString);
    
    NSString *tempPassword = [finalString substringWithRange:NSMakeRange(0, 5)];
    
    [self decryptPassword:tempPassword];
    
    if (decryptionPassword.length != 0) {
        
        if (![decryptionPassword isEqualToString: senderPassword]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!!" message:@"Your decryption key doesn't match the sender's encryption key"
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil, nil];
            [alert show];
            keysMatched = NO;
            [_key setBackgroundImage:[UIImage imageNamed:@"redKey.png"]
                            forState:UIControlStateNormal];
        } else {
            keysMatched = YES;
            [_key setBackgroundImage:[UIImage imageNamed:@"greenKey.png"]
                            forState:UIControlStateNormal];
        }
    }
    return finalString;
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
