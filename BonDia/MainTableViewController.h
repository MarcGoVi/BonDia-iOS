//
//  MainTableViewController.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/2/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppDelegate;

@interface MainTableViewController : UITableViewController <NSFetchedResultsControllerDelegate> {
    AppDelegate *appDelegate;
    UITextView *labelNoArticles;
    NSMutableArray *arrayTemporalArticles;
    NSOperationQueue *networkQueue;
    int numberOfErrors;
    NSError *errorHTTPRequest;
    NSOperationQueue *imagesQueue;
        
    UIRefreshControl *refreshControl;
    NSFetchedResultsController *fetchedResultsController;
}

@property (nonatomic, strong) NSString *sectionSelected;

- (IBAction)showSections:(id)sender;

- (IBAction)showAbout:(id)sender;

@end