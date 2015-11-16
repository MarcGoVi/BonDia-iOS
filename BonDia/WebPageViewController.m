//
//  WebPageViewController.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "WebPageViewController.h"
#import "SVProgressHUD.h"
#import <Google/Analytics.h>

@implementation WebPageViewController

@synthesize titleWebView, url;

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:titleWebView];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self setTitle:titleWebView];
    
    [myWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:url]]];
}

- (void)viewWillDisappear:(BOOL)animated {
    [myWebView setDelegate:nil];
    [myWebView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
	[super viewWillDisappear:animated];
}

#pragma mark - UIWebViewDelegate methods

-(void)webViewDidStartLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    [SVProgressHUD showWithStatus:NSLocalizedString(@"_LoadingWebView",nil) maskType:SVProgressHUDMaskTypeNone];
}

-(void)webViewDidFinishLoad:(UIWebView *)webView {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
}

-(void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    [myWebView stopLoading];
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [SVProgressHUD dismiss];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_Error", nil) message:[error localizedDescription] delegate:nil cancelButtonTitle:NSLocalizedString(@"_Ok", nil) otherButtonTitles:nil];
    [alertView show];
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    [[self navigationController] popViewControllerAnimated:TRUE];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end