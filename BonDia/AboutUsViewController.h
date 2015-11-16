//
//  AboutUsViewController.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AboutUsViewController : UIViewController {
    IBOutlet UIButton *mail_bt;
    IBOutlet UIButton *twitter_bt;
    IBOutlet UIButton *web_bt;
    IBOutlet UILabel *label_by;
}

- (IBAction)goMail:(id)sender;

- (IBAction)goTwitter:(id)sender;

- (IBAction)goWeb:(id)sender;

- (IBAction)cancel:(id)sender;

@end