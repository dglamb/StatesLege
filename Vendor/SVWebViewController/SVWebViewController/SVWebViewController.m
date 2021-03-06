//
//  SVWebViewController.m
//
//  Created by Sam Vermette on 08.11.10.
//  Copyright 2010 Sam Vermette. All rights reserved.
//

#import "SVWebViewController.h"
#import "SLFTheme.h"
#import "AFNetworkActivityIndicatorManager.h"

@interface SVWebViewController (private)

- (void)layoutSubviews;
- (void)setupToolbar;
- (void)setupTabletToolbar;
- (void)stopLoadingNetwork;
- (void)stopLoadingAndResetToolbar;

@end

@implementation SVWebViewController

@synthesize webView = rWebView;
@synthesize urlString;

- (void)dealloc {
    navItem = nil;
    SLFRelease(backBarButton);
    SLFRelease(forwardBarButton);
    SLFRelease(actionBarButton);
    if (rWebView) {
        rWebView.delegate = nil;
        [rWebView removeFromSuperview];
    }
    SLFRelease(rWebView);
    [super dealloc];
}

- (SVWebViewController*)initWithAddress:(NSString*)string {
    
    self = [super initWithNibName:nil bundle:[NSBundle mainBundle]];
    if (self) {
        self.urlString = string;
        if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
            deviceIsTablet = YES;
    }
    return self;
}

- (void)viewDidUnload {
    if (rWebView) {
        rWebView.delegate = nil;
        [rWebView removeFromSuperview];
    }
    SLFRelease(rWebView);
    SLFRelease(backBarButton);
    SLFRelease(forwardBarButton);
    SLFRelease(actionBarButton);
    [super viewDidUnload];
}

- (void)viewDidLoad {
    
    [super viewDidLoad];
    
    [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];

    CGRect deviceBounds = [[UIApplication sharedApplication] keyWindow].bounds;
    
    if(!deviceIsTablet) {

        backBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/back"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goBack)];
        backBarButton.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        backBarButton.width = 18;
        
        forwardBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPhone/forward"] style:UIBarButtonItemStylePlain target:self.webView action:@selector(goForward)];
        forwardBarButton.imageInsets = UIEdgeInsetsMake(2, 0, -2, 0);
        forwardBarButton.width = 18;
        
        actionBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(showActions)];
        
        if(self.navigationController == nil) {
            
            navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(deviceBounds),44)];
            navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
            [self.view addSubview:navBar];
            [navBar release];
            
            navItem = [[UINavigationItem alloc] initWithTitle:self.title];
            [navBar setItems:[NSArray arrayWithObject:navItem] animated:YES];
            [navItem release];
            
            toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds)-44, CGRectGetWidth(deviceBounds), 44)];
            toolbar.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleWidth;
            [self.view addSubview:toolbar];
            [toolbar release];
        }
        
        else {
            navBar = self.navigationController.navigationBar;
            toolbar = self.navigationController.toolbar;
        }
    }
    
    else {
                
        if(self.navigationController == nil) {
            
            navBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0,0,CGRectGetWidth(deviceBounds),44)];
            navBar.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleBottomMargin;
            [self.view addSubview:navBar];
            [navBar release];
            
            UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
            
            navItem = [[UINavigationItem alloc] initWithTitle:self.title];
            navItem.leftBarButtonItem = doneButton;
            [doneButton release];
            
            [navBar setItems:[NSArray arrayWithObject:navItem] animated:YES];
            [navItem release];
            
            titleLeftOffset = [@"Done" sizeWithFont:[UIFont boldSystemFontOfSize:12]].width+33;
        }
        
        else {
            self.hidesBottomBarWhenPushed = YES;            
            navBar = self.navigationController.navigationBar;
            navBar.autoresizesSubviews = YES;
            
            NSArray* viewCtrlers = self.navigationController.viewControllers;
            UIViewController* prevCtrler = [viewCtrlers objectAtIndex:[viewCtrlers count]-2];
            titleLeftOffset = [prevCtrler.navigationItem.backBarButtonItem.title sizeWithFont:[UIFont boldSystemFontOfSize:12]].width+26;
        }
        
        backButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [backButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/back"] forState:UIControlStateNormal];
        backButton.frame = CGRectZero;
        [backButton addTarget:self.webView action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
        backButton.adjustsImageWhenHighlighted = NO;
        backButton.autoresizingMask = UIViewAutoresizingFlexibleRightMargin;
        backButton.showsTouchWhenHighlighted = YES;
        
        forwardButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [forwardButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/forward"] forState:UIControlStateNormal];
        forwardButton.frame = CGRectZero;
        [forwardButton addTarget:self.webView action:@selector(goForward) forControlEvents:UIControlEventTouchUpInside];
        forwardButton.adjustsImageWhenHighlighted = NO;
        forwardButton.showsTouchWhenHighlighted = YES;
        
        actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [actionButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/action"] forState:UIControlStateNormal];
        actionButton.frame = CGRectZero;
        [actionButton addTarget:self action:@selector(showActions) forControlEvents:UIControlEventTouchUpInside];
        actionButton.adjustsImageWhenHighlighted = NO;
        actionButton.showsTouchWhenHighlighted = YES;
        
        refreshStopButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [refreshStopButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/refresh"] forState:UIControlStateNormal];
        refreshStopButton.frame = CGRectZero;
        refreshStopButton.adjustsImageWhenHighlighted = NO;
        refreshStopButton.showsTouchWhenHighlighted = YES;
        
        titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        titleLabel.font = [UIFont boldSystemFontOfSize:20];
        titleLabel.textColor = [SLFAppearance navBarTextColor];
        titleLabel.shadowColor = [UIColor darkGrayColor];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        titleLabel.textAlignment = UITextAlignmentRight;
        titleLabel.shadowOffset = CGSizeMake(0, -1);

        [navBar addSubview:titleLabel];    
        [titleLabel release];
        
        [navBar addSubview:refreshStopButton];    
        [navBar addSubview:backButton];    
        [navBar addSubview:forwardButton];    
        [navBar addSubview:actionButton];    
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    
    if(!deviceIsTablet)
        [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self setupToolbar];
    [self layoutSubviews];
    
    if(self.modalViewController)
        return;
    
    if (self.urlString) {
        NSURL *searchURL = [NSURL URLWithString:self.urlString];
        [self.webView loadRequest:[NSURLRequest requestWithURL:searchURL]]; // actually creates a webview if needed
    }
    
    if(deviceIsTablet && self.navigationController) {
        titleLabel.alpha = 0;
        refreshStopButton.alpha = 0;
        backButton.alpha = 0;
        forwardButton.alpha = 0;
        actionButton.alpha = 0;
        
        [UIView animateWithDuration:0.3 animations:^{
            titleLabel.alpha = 1;
            refreshStopButton.alpha = 1;
            backButton.alpha = 1;
            forwardButton.alpha = 1;
            actionButton.alpha = 1;
        }];
    }
}


- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    if(self.modalViewController)
        return;
    
    if (self.navigationController)
        [self.navigationController setToolbarHidden:YES animated:YES];
    
    if(deviceIsTablet && self.navigationController) {
        [UIView animateWithDuration:0.3 animations:^{
            titleLabel.alpha = 0;
            refreshStopButton.alpha = 0;
            backButton.alpha = 0;
            forwardButton.alpha = 0;
            actionButton.alpha = 0;
        }];
    }
}


- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    if(self.modalViewController)
        return;
    [self stopLoadingNetwork];
}


#pragma mark -
#pragma mark Layout Methods

- (void)layoutSubviews {
    CGRect deviceBounds = self.view.bounds;

    if(UIInterfaceOrientationIsLandscape(self.interfaceOrientation) && !deviceIsTablet && !self.navigationController) {
        navBar.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), 32);
        toolbar.frame = CGRectMake(0, CGRectGetHeight(deviceBounds)-32, CGRectGetWidth(deviceBounds), 32);
    } else if(UIInterfaceOrientationIsPortrait(self.interfaceOrientation) && !deviceIsTablet && !self.navigationController) {
        navBar.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), 44);
        toolbar.frame = CGRectMake(0, CGRectGetHeight(deviceBounds)-44, CGRectGetWidth(deviceBounds), 44);
    }
    
    if(self.navigationController && deviceIsTablet)
        self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds));
    else if(deviceIsTablet)
        self.webView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetHeight(deviceBounds)-CGRectGetMaxY(navBar.frame));
    else if(self.navigationController && !deviceIsTablet)
        self.webView.frame = CGRectMake(0, 0, CGRectGetWidth(deviceBounds), CGRectGetMaxY(self.view.bounds));
    else if(!deviceIsTablet)
        self.webView.frame = CGRectMake(0, CGRectGetMaxY(navBar.frame), CGRectGetWidth(deviceBounds), CGRectGetMinY(toolbar.frame)-CGRectGetMaxY(navBar.frame));
        
    backButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-180, 0, 44, 44);
    forwardButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-120, 0, 44, 44);
    actionButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-60, 0, 44, 44);
    refreshStopButton.frame = CGRectMake(CGRectGetWidth(deviceBounds)-240, 0, 44, 44);
    titleLabel.frame = CGRectMake(titleLeftOffset, 0, CGRectGetWidth(deviceBounds)-240-titleLeftOffset-5, 44);
}


- (void)setupToolbar {
    
    if(!navItem.leftBarButtonItem) {
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(dismissController)];
        [navItem setLeftBarButtonItem:doneButton animated:YES];
        [doneButton release];
    }
    
    NSString *javaTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (!IsEmpty(javaTitle)) {
        if(self.navigationController != nil)
            self.navigationItem.title = javaTitle;
        else
            navItem.title = javaTitle;
    }
    
    if(![self.webView canGoBack])
        backBarButton.enabled = NO;
    else
        backBarButton.enabled = YES;
    
    if(![self.webView canGoForward])
        forwardBarButton.enabled = NO;
    else
        forwardBarButton.enabled = YES;
    
    if(self.webView.loading && !stoppedLoading)
        refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemStop target:self action:@selector(stopLoadingAndResetToolbar)];
    
    else
        refreshStopBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self.webView action:@selector(reload)];
    
    UIBarButtonItem *flexSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    UIBarButtonItem *fixedSpace = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    fixedSpace.width = 5;
    
    NSURLRequest *req = self.webView.request;
    
    if(req && ![req.URL.absoluteString isEqualToString:@""] && [req.URL.absoluteString rangeOfString:@".app"].location == NSNotFound)
        actionBarButton.enabled = YES;
    else
        actionBarButton.enabled = NO;
    
    NSArray *newButtons = [NSArray arrayWithObjects:fixedSpace, backBarButton, flexSpace, forwardBarButton, flexSpace, refreshStopBarButton, flexSpace, actionBarButton, fixedSpace, nil];
    [toolbar setItems:newButtons];
    [toolbar sizeToFit];
        
    [refreshStopBarButton release];
    [flexSpace release];
    [fixedSpace release];
}


- (void)setupTabletToolbar {
    
    NSString *javaTitle = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
    if (!IsEmpty(javaTitle))
        titleLabel.text = javaTitle;
    
    if(![self.webView canGoBack])
        backButton.enabled = NO;
    else
        backButton.enabled = YES;
    
    if(![self.webView canGoForward])
        forwardButton.enabled = NO;
    else
        forwardButton.enabled = YES;
    
    if(self.webView.loading && !stoppedLoading) {
        [refreshStopButton removeTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        [refreshStopButton addTarget:self action:@selector(stopLoadingAndResetToolbar) forControlEvents:UIControlEventTouchUpInside];
        [refreshStopButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/stop"] forState:UIControlStateNormal];
    }
    
    else {
        [refreshStopButton removeTarget:self action:@selector(stopLoadingAndResetToolbar) forControlEvents:UIControlEventTouchUpInside];
        [refreshStopButton addTarget:self.webView action:@selector(reload) forControlEvents:UIControlEventTouchUpInside];
        [refreshStopButton setBackgroundImage:[UIImage imageNamed:@"SVWebViewController.bundle/iPad/refresh"] forState:UIControlStateNormal];
    }
}


#pragma mark -
#pragma mark Orientation Support

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    
    return YES;
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation duration:(NSTimeInterval)duration {
    [self layoutSubviews];
}


#pragma mark -
#pragma mark UIWebViewDelegate

- (UIWebView*)webView {
    
    if (!rWebView && self.isViewLoaded) {
        rWebView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        rWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleBottomMargin;
        rWebView.delegate = self;
        rWebView.scalesPageToFit = YES;
        [self.view addSubview:rWebView];
    }
    
    return rWebView;
}


- (void)webViewDidStartLoad:(UIWebView *)webView {
    
    stoppedLoading = NO;
    [[AFNetworkActivityIndicatorManager sharedManager] incrementActivityCount];

    if(!deviceIsTablet)
        [self setupToolbar];
    else
        [self setupTabletToolbar];
}


- (void)webViewDidFinishLoad:(UIWebView *)webView {
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];

    if(!deviceIsTablet)
        [self setupToolbar];
    else
        [self setupTabletToolbar];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}


#pragma mark -
#pragma mark Action Methods

- (void)stopLoadingNetwork {
    stoppedLoading = YES;
    if (rWebView)
        [rWebView stopLoading];
    [[AFNetworkActivityIndicatorManager sharedManager] decrementActivityCount];
}

- (void)stopLoadingAndResetToolbar {
    [self stopLoadingNetwork];
    if (!self.isViewLoaded)
        return;
    if(!deviceIsTablet)
        [self setupToolbar];
    else
        [self setupTabletToolbar];
}

- (void)didReceiveMemoryWarning {
    if (self.isViewLoaded)
        [self stopLoadingAndResetToolbar]; // clean house!
    [super didReceiveMemoryWarning];
}

- (void)showActions {
    
    UIActionSheet *actionSheet = [[UIActionSheet alloc] 
                          initWithTitle: nil
                          delegate: self 
                          cancelButtonTitle: nil   
                          destructiveButtonTitle: nil   
                          otherButtonTitles: NSLocalizedString(@"Open in Safari", @"SVWebViewController"), nil]; 
    
    
    if([MFMailComposeViewController canSendMail])
        [actionSheet addButtonWithTitle:NSLocalizedString(@"Mail Link to this Page", @"SVWebViewController")];
    
    [actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel",@"SVWebViewController")];
    actionSheet.cancelButtonIndex = [actionSheet numberOfButtons]-1;
    
    if(!deviceIsTablet)
        [actionSheet showFromToolbar:toolbar];
    else if(!self.navigationController)
        [actionSheet showFromRect:CGRectOffset(actionButton.frame, 0, -5) inView:self.view animated:YES];
    else if(self.navigationController)
        [actionSheet showFromRect:CGRectOffset(actionButton.frame, 0, -49) inView:self.view animated:YES];
        
    [actionSheet release];
}


- (void)dismissController {
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark -
#pragma mark UIActionSheetDelegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Open in Safari", @"SVWebViewController")])
        [[UIApplication sharedApplication] openURL:self.webView.request.URL];
    
    else if([[actionSheet buttonTitleAtIndex:buttonIndex] isEqualToString:NSLocalizedString(@"Mail Link to this Page", @"SVWebViewController")]) {
        
        MFMailComposeViewController *emailComposer = [[MFMailComposeViewController alloc] init]; 
        [emailComposer setMailComposeDelegate: self]; 
        NSString *title = [self.webView stringByEvaluatingJavaScriptFromString:@"document.title"];
        [emailComposer setSubject:title];
        [emailComposer setMessageBody:self.webView.request.URL.absoluteString isHTML:NO];
        emailComposer.modalPresentationStyle = UIModalPresentationFormSheet;
        UIViewController * rootVC = [[[UIApplication sharedApplication] keyWindow] rootViewController];
        [rootVC presentModalViewController:emailComposer animated:YES];
        [emailComposer release];
    }
    
}

#pragma mark -
#pragma mark MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
    [controller dismissModalViewControllerAnimated:YES];
}


@end
