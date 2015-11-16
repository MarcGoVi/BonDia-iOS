//
//  ContactUsViewController.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "ContactUsViewController.h"
#import <Google/Analytics.h>

@implementation ContactUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Contacta'ns"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self setTitle:@"Contacta'ns"];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel·lar" style:UIBarButtonItemStylePlain target:self action:@selector(cancel:)];
    [[self navigationItem] setRightBarButtonItem:cancelButton];
    
    NSArray *keys = [[NSArray alloc] initWithObjects:(id)kCTForegroundColorAttributeName,(id)kCTUnderlineStyleAttributeName
                     , nil];
    UIColor *colorLink =[UIColor colorWithRed:0/255.0 green:86/255.0 blue:115/255.0 alpha:1.0];
    NSArray *objectsLink = [[NSArray alloc] initWithObjects:colorLink,[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *linkAttributes = [[NSDictionary alloc] initWithObjects:objectsLink forKeys:keys];
    
    UIColor *colorActiveLink =[UIColor colorWithRed:0/255.0 green:151/255.0 blue:195/255.0 alpha:1.0];
    NSArray *objectsActiveLink = [[NSArray alloc] initWithObjects:colorActiveLink,[NSNumber numberWithInt:kCTUnderlineStyleNone], nil];
    NSDictionary *activeLinkAttributes = [[NSDictionary alloc] initWithObjects:objectsActiveLink forKeys:keys];
    
    [telefon setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
    [email setEnabledTextCheckingTypes:NSTextCheckingTypeLink];
    
    [telefon setLinkAttributes:linkAttributes];
    [telefon setActiveLinkAttributes:activeLinkAttributes];
    NSRange linkRange = [[telefon text] rangeOfString:@"+376 80 88 88"];
    [telefon addLinkToPhoneNumber:@"+376808888" withRange:linkRange];
    
    [email setLinkAttributes:linkAttributes];
    [email setActiveLinkAttributes:activeLinkAttributes];
    linkRange = [[email text] rangeOfString:@"bondia@bondia.ad"];
    [email addLinkToURL:[NSURL URLWithString:@"mailto:bondia@bondia.ad"] withRange:linkRange];
}

#pragma mark - TTTAttributedLabelDelegate methods

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithPhoneNumber:(NSString *)phoneNumber {
    urlForCalling = [NSURL URLWithString:[NSString stringWithFormat:@"tel:%@", phoneNumber]];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_Warning", nil) message:[NSString stringWithFormat:NSLocalizedString(@"_SureYouWantCall %@", nil),phoneNumber] delegate:self cancelButtonTitle:NSLocalizedString(@"_Cancel",nil) otherButtonTitles:NSLocalizedString(@"_Call", nil), nil];
    [alertView show];
}

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    if ([[url absoluteString] isEqualToString:@"mailto:bondia@bondia.ad"]) {
        if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mailto:bondia@bondia.ad"]]) {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"mailto:bondia@bondia.ad"]];
        } else {
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bondia.ad/contact"]];
        }
    }
}

#pragma mark - UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != 0) {
        [[UIApplication sharedApplication] openURL:urlForCalling];
    }
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

- (IBAction)goBonDia:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.bondia.ad"]];
}

- (IBAction)goFacebook:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"fb://profile/79542937744"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"fb://profile/79542937744"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://facebook.com/diaribondia"]];
    }
}

- (IBAction)goTwitter:(id)sender {
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString: @"twitter://user?id=12394182"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"twitter://user?id=12394182"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString: @"http://twitter.com/bondia"]];
    }
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end