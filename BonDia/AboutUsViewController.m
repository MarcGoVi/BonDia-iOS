//
//  AboutUsViewController.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "AboutUsViewController.h"
#import <Google/Analytics.h>

@implementation AboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"About Us"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [self setTitle:@"Autor"];
}

#pragma mark - IBAction

- (IBAction)goMail:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto:marc.gomez.vidal@gmail.com"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:marc.gomez.vidal@gmail.com"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.marcgomez.work"]];
    }
}

- (IBAction)goTwitter:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: @"twitter://user?id=258800672"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"twitter://user?id=258800672"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://twitter.com/MarcGoVi"]];
    }
}


- (IBAction)goWeb:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.marcgomez.work"]];
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end