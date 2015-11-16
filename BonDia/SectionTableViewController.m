//
//  SectionTableViewController.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/3/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "SectionTableViewController.h"
#import "AppDelegate.h"
#import "SectionTableViewCell.h"
#import "ContactUsViewController.h"
#import <Google/Analytics.h>

@implementation SectionTableViewController

@synthesize sectionSelected;

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    appDelegate = [[UIApplication sharedApplication] delegate];
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    [self setTitle:@"Seccions"];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SectionFromIndex" ofType:@"plist"];
    arraySectionFromIndex = [[NSArray alloc] initWithContentsOfFile:path];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    switch (section) {
        case 0:
            return [arraySectionFromIndex count];
            break;
        case 1:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SectionTableViewCell *cell = (SectionTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"SectionTableViewCell"];
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    switch (indexPath.section) {
        case 0: {
            NSString *section = [NSString stringWithString:[arraySectionFromIndex objectAtIndex:indexPath.row]];
            [[cell textLabel] setText:section];
            if ([sectionSelected isEqualToString:section]) {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
            break;
        case 1:
            switch (indexPath.row) {
                case 0:
                    [[cell textLabel] setText:@"Contacta'ns"];
                    break;
            }
            break;
    }
    
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *sectionHeader = [[UILabel alloc] initWithFrame:CGRectNull];
    switch (section) {
        case 0:
            [sectionHeader setText:[NSString stringWithFormat:@"  Categories"]];
            break;
            
        case 1:
            [sectionHeader setText:[NSString stringWithFormat:@"  Altres"]];
            break;
    }
    return sectionHeader;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[self tableView] deselectRowAtIndexPath:indexPath animated:TRUE];
    
    if ([indexPath section] == 0) {
        SectionTableViewCell *cell = (SectionTableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        
        NSDictionary* dict = [NSDictionary dictionaryWithObject:[[cell textLabel] text] forKey:@"sectionSelected"];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshMainTableViewController" object:nil userInfo:dict];
        
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker set:kGAIScreenName value:[[cell textLabel] text]];
        [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
        
        [self dismissViewControllerAnimated:TRUE completion:nil];
        
    } else if ([indexPath section] == 1) {
        
        switch ([indexPath row]) {
            case 0: {
                UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BonDia" bundle:nil];
                ContactUsViewController* vc = [sb instantiateViewControllerWithIdentifier:@"ContactUsViewController"];
                [[self navigationController] pushViewController:vc animated:TRUE];
            }
                break;
        }
    }
}

#pragma mark - IBAction

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end