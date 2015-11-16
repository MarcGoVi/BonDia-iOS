//
//  WebPageViewController.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WebPageViewController : UIViewController <UIWebViewDelegate, UIAlertViewDelegate> {
    IBOutlet UIWebView *myWebView;
}

@property (nonatomic, strong) NSString *titleWebView;
@property (nonatomic, strong) NSString *url;

@end