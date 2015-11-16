//
//  SectionTableViewController.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/3/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface SectionTableViewController : UITableViewController {
    AppDelegate *appDelegate;
    NSArray *arraySectionFromIndex;
}

@property (nonatomic, strong) NSString *sectionSelected;

- (IBAction)cancel:(id)sender;

@end