//
//  ContactUsViewController.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/9/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TTTAttributedLabel.h"

@interface ContactUsViewController : UIViewController <TTTAttributedLabelDelegate, UIAlertViewDelegate> {
    IBOutlet UIButton *BonDiaButton;
    IBOutlet UILabel *carrer;
    IBOutlet UILabel *cp;
    IBOutlet UILabel *pais;
    IBOutlet TTTAttributedLabel *telefon;
    IBOutlet TTTAttributedLabel *email;
    IBOutlet UIButton *facebookButton;
    IBOutlet UIButton *twitterButton;
    
    NSURL *urlForCalling;
}

- (IBAction)goBonDia:(id)sender;

- (IBAction)goFacebook:(id)sender;

- (IBAction)goTwitter:(id)sender;

@end