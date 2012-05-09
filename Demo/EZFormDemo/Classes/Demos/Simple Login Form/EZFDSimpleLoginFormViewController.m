//
//  EZFDSimpleLoginFormViewController.m
//  EZFormDemo
//
//  Created by Chris Miles on 3/05/12.
//  Copyright (c) 2012 Chris Miles. All rights reserved.
//

#import "EZFDSimpleLoginFormViewController.h"
#import <QuartzCore/QuartzCore.h>

#define kFormInvalidIndicatorViewSize 16.0f

static NSString * const EZFDLoginFormPasswordKey = @"password";
static NSString * const EZFDLoginFormUsernameKey = @"username";


@interface EZFDSimpleLoginFormViewController ()
@property (nonatomic, retain) EZForm *loginForm;
@end


@implementation EZFDSimpleLoginFormViewController

@synthesize loginButton = _loginButton;
@synthesize loginFormView = _loginFormView;
@synthesize loginForm = _loginForm;
@synthesize passwordTextField = _passwordTextField;
@synthesize usernameTextField = _usernameTextField;
@synthesize invalidIndicatorKeyView = _invalidIndicatorKeyView;

- (void)awakeFromNib
{
    [self initializeForm];
}

- (void)initializeForm
{
    /* Create EZForm instance to manage the form.
     */
    _loginForm = [[EZForm alloc] init];
    _loginForm.inputAccessoryType = EZFormInputAccessoryTypeStandard;
    _loginForm.delegate = self;
    
    /* Add an EZFormTextField instance to handle the username field.
     * Enables a validation rule of 1 character minimum.
     * Limits the input text field to 32 characters maximum (when hooked up to a control).
     */
    EZFormTextField *usernameField = [[[EZFormTextField alloc] initWithKey:EZFDLoginFormUsernameKey] autorelease];
    usernameField.validationMinCharacters = 1;
    usernameField.inputMaxCharacters = 32;
    usernameField.invalidIndicatorView = [EZForm formInvalidIndicatorViewForType:EZFormInvalidIndicatorViewTypeTriangleExclamation size:CGSizeMake(kFormInvalidIndicatorViewSize, kFormInvalidIndicatorViewSize)];
    [_loginForm addFormField:usernameField];
    
    /* Add an EZFormTextField instance to handle the password field.
     * Enables a validation rule of 3 character minimum.
     * Limits the input text field to 32 characters maximum (when hooked up to a control).
     */
    EZFormTextField *passwordField = [[[EZFormTextField alloc] initWithKey:EZFDLoginFormPasswordKey] autorelease];
    passwordField.validationMinCharacters = 4;
    passwordField.inputMaxCharacters = 32;
    passwordField.invalidIndicatorView = [EZForm formInvalidIndicatorViewForType:EZFormInvalidIndicatorViewTypeTriangleExclamation size:CGSizeMake(kFormInvalidIndicatorViewSize, kFormInvalidIndicatorViewSize)];
    [_loginForm addFormField:passwordField];
}

- (void)dealloc
{
    [_loginButton release];
    [_loginForm release];
    [_passwordTextField release];
    [_usernameTextField release];
    
    [_loginFormView release];
    [_invalidIndicatorKeyView release];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    /* Wire up form fields to user interface elements.
     * This needs to be done after the views are loaded (e.g. in viewDidLoad).
     */
    EZFormTextField *usernameField = (EZFormTextField *)[self.loginForm formFieldForKey:EZFDLoginFormUsernameKey];
    [usernameField useTextField:self.usernameTextField];
    EZFormTextField *passwordField = (EZFormTextField *)[self.loginForm formFieldForKey:EZFDLoginFormPasswordKey];
    [passwordField useTextField:self.passwordTextField];
    
    /* Automatically scroll (or move) the given view if needed to
     * keep the active form field control visible.
     */
    [self.loginForm autoScrollViewForKeyboardInput:self.loginFormView];
    
    /* Add some padding around views that are auto scrolled for visibility.
     */
    self.loginForm.autoScrollForKeyboardInputPaddingSize = CGSizeMake(0.0f, 89.0f);
    
    
    /* Setup rest of the views to look nice (not form specific)
     */
    
    self.loginFormView.layer.cornerRadius = 10.0f;
    self.loginFormView.layer.shadowOffset = CGSizeMake(0.0f, 3.0f);
    self.loginFormView.layer.shadowOpacity = 0.7f;
    
    [self.invalidIndicatorKeyView addSubview:[EZForm formInvalidIndicatorViewForType:EZFormInvalidIndicatorViewTypeTriangleExclamation size:CGSizeMake(kFormInvalidIndicatorViewSize, kFormInvalidIndicatorViewSize)]];
    [self updateViewsForFormValidity];
}

- (void)viewDidUnload
{
    [self setLoginButton:nil];
    [self setPasswordTextField:nil];
    [self setUsernameTextField:nil];
    
    [self setLoginFormView:nil];
    [self setInvalidIndicatorKeyView:nil];
    [super viewDidUnload];
    
    /* Unwire (and release) all user views from the form fields.
     */
    [self.loginForm unwireUserViews];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
	return YES;
    }
    else {
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}


#pragma mark - Login button status

- (void)updateViewsForFormValidity
{
    if ([self.loginForm isFormValid]) {
	self.loginButton.enabled = YES;
	self.loginButton.alpha = 1.0f;
	
	self.invalidIndicatorKeyView.hidden = YES;
    }
    else {
	self.loginButton.enabled = NO;
	self.loginButton.alpha = 0.4f;
	
	self.invalidIndicatorKeyView.hidden = NO;
    }
}


#pragma mark - EZFormDelegate methods

- (void)form:(EZForm *)form didUpdateValueForField:(EZFormField *)formField modelIsValid:(BOOL)isValid
{
    [self updateViewsForFormValidity];
}

- (void)formInputFinishedOnLastField:(EZForm *)form
{
    if ([form isFormValid]) {
	[self loginAction:nil];
    }
}


#pragma mark - Control actions

- (IBAction)loginAction:(id)sender
{
    [[[[UIAlertView alloc] initWithTitle:@"Success" message:nil delegate:nil cancelButtonTitle:@"Dismiss" otherButtonTitles:nil] autorelease] show];
}

@end
