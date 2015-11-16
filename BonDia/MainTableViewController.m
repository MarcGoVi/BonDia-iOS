//
//  MainTableViewController.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/2/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "MainTableViewController.h"
#import "AppDelegate.h"
#import "Article.h"
#import "MainTableViewCell.h"
#import "SectionTableViewController.h"
#import "DetailArticleViewController.h"
#import "AboutUsViewController.h"
#import "Tools.h"
#import "AFHTTPRequestOperation.h"

static const NSString *URLWebService = @"http://www.bondia.ad/rest/articles?section=";
static const NSTimeInterval timeOut = NSTimeIntervalSince1970 + 10;
static const NSInteger limitArticleList = 25;

@implementation MainTableViewController

@synthesize sectionSelected;

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set the appDelegate on the local variable
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    // Set title on the navigation bar
    [self setTitle:NSLocalizedString(@"_Recents", nil)];
    // Set the navigation bar style
    [[[self navigationController] navigationBar] setBarStyle:UIBarStyleBlackTranslucent];
    
    // Initialization the RefreshControl
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(updateArticles) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    [self setSectionSelected:@"Recents"];
    
    labelNoArticles = [[UITextView alloc] init];
    [self.tableView addSubview:labelNoArticles];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    // Prepare Notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshListNotification:) name:@"refreshMainTableViewController" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(airDropDetailArticleNotification:) name:@"airDropDetailArticleNotification" object:nil];
    
    networkQueue = [[NSOperationQueue alloc] init];
    imagesQueue = [[NSOperationQueue alloc] init];
    arrayTemporalArticles = [[NSMutableArray alloc] init];
    
    // Fetch actual data from the sql
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"MainTableViewController - Impossible read event list. Details: %@, %@", error, [error userInfo]);
		abort();
	}
    
    [self updateArticles];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self fetchedResultsController];
    [[self tableView] reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    // Initialization of label that appears when there is no article available
    NSString *textNoArticles = NSLocalizedString(@"_NoArticles", nil);
    NSString *textSwipteDown = NSLocalizedString(@"_SwipeDownToRefresh", nil);
    
    NSMutableAttributedString *finalString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@\n\n\n%@", textNoArticles, textSwipteDown]];
    [finalString addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"Helvetica Neue" size:20.0]
                        range:NSMakeRange(0, [textNoArticles length])];
    
    [finalString addAttribute:NSFontAttributeName
                        value:[UIFont fontWithName:@"Helvetica Neue" size:13.0]
                        range:NSMakeRange([textNoArticles length]+1,[textSwipteDown length])];
    [labelNoArticles setAttributedText:finalString];
    [labelNoArticles setTextAlignment:NSTextAlignmentCenter];
    [labelNoArticles setTextContainerInset:UIEdgeInsetsMake(150,0,0,0)];
    [labelNoArticles setFrame:CGRectMake(0, 0, self.tableView.frame.size.width, 300)];
}

#pragma mark - Notification methods

- (void)refreshListNotification:(NSNotification*)notification {
    [self setSectionSelected:[[notification userInfo] objectForKey:@"sectionSelected"]];
    [self refreshListAccordingCategory];
}

- (void)airDropDetailArticleNotification:(NSNotification*)notification {
    // Get data passed from AirDrop and parse
    NSString *articleString = [[NSString alloc] initWithData:[[notification userInfo] objectForKey:@"fileDataNotification"] encoding:NSUTF8StringEncoding];
    NSArray *objects = [articleString componentsSeparatedByString:@"_?_"];
    
    if ([objects count] > 9) {
        NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
        for (int x = 0; x < [objects count]; x=x+2) {
            [dict setObject:[objects objectAtIndex:x+1] forKey:[objects objectAtIndex:x]];
        }
        
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"Article" inManagedObjectContext:[appDelegate managedObjectContext]];
        Article *article = [[Article alloc] initWithEntity:entity insertIntoManagedObjectContext:nil];
        [article setDataFromAirDrop:dict];
        
        // Cancel all kind of comunication
        [[self navigationController] popToRootViewControllerAnimated:FALSE];
        [networkQueue cancelAllOperations];
        [self restoreVariablesCommunication];
        
        // Show the details of the article
        UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BonDia" bundle:nil];
        DetailArticleViewController* nc = [sb instantiateViewControllerWithIdentifier:@"DetailArticleViewController"];
        [nc setArticle:article];
        [[self navigationController] pushViewController:nc animated:TRUE];
    } else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No s'ha pogut obrir la notícia rebuda per AirDrop." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
        [alertView show];
    }
}

#pragma mark - Comunication

- (void)updateArticles {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:TRUE];
    
    // If it's not refreshing we start the refreshing action on the UI
    if (![refreshControl isRefreshing]) {
        [refreshControl beginRefreshing];
        if (self.tableView.contentOffset.y == 0) {
            [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^(void){
                self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
            } completion:^(BOOL finished){
            }];
        }
    }
    
    NSMutableArray *mutableOperations = [NSMutableArray array];
    numberOfErrors = 0;
    [arrayTemporalArticles removeAllObjects];
    
    for (int x = 0; x < 9; x++) {
        NSMutableString *url = [[NSMutableString alloc] initWithString:[NSString stringWithFormat:@"%@%@",URLWebService, [self getSectionInt:x]]];
        [[NSURLCache sharedURLCache] removeAllCachedResponses];
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:url] cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:timeOut];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            [self dataReceived:responseObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            numberOfErrors++;
            errorHTTPRequest = error;
        }];
        [mutableOperations addObject:operation];
    }
    
    NSArray *array = [AFURLConnectionOperation batchOfRequestOperations:mutableOperations progressBlock: ^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
    } completionBlock:^(NSArray *operations) {
        if (numberOfErrors != 0) {
            [self errorOccurred:[NSString stringWithFormat:@"%@",[errorHTTPRequest localizedDescription]]];
        } else {
            [self allDataReceived];
        }
    }];
    
    [networkQueue addOperations:array waitUntilFinished:NO];
}

- (void)dataReceived:(id)responseObject {
    NSError *error = nil;
    NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&error];
    
    // If we have received data, we store temporaly on a NSMutableArray
    if (!((!jsonArray) || (jsonArray == nil) || ([jsonArray count] == 0))) {
        [arrayTemporalArticles addObjectsFromArray:jsonArray];
    }
}

- (void)allDataReceived {
    if (!arrayTemporalArticles || (arrayTemporalArticles == nil) || [arrayTemporalArticles count] == 0) {
        [self infoOccurred:NSLocalizedString(@"_NoArticles", nil)];
    } else {
        [self removeAllArticleManagedObject];
        
        for (NSDictionary *articleDict in arrayTemporalArticles) {
            Article *article = (Article *)[NSEntityDescription insertNewObjectForEntityForName:@"Article" inManagedObjectContext:appDelegate.managedObjectContext];
            [article setDataFromDictionary:articleDict];
        }
        
        // We save the data
        NSError *error = nil;
        if (![appDelegate.managedObjectContext save:&error]) {
            NSLog(@"MainTableViewController - Impossible write/read article list. Details: %@, %@", error, [error userInfo]);
            abort();
        }
        
        [self restoreVariablesCommunication];
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ca"];
        [formatter setLocale:locale];
        [formatter setDateFormat:@"EEE',' dd/MM/yyyy HH:mm"];
        NSString *lastUpdated = [NSString stringWithFormat:NSLocalizedString(@"_LastUpdate", nil),[formatter stringFromDate:[NSDate date]]];
        [refreshControl setAttributedTitle:[[NSAttributedString alloc] initWithString:lastUpdated]];
        
        [self refreshListAccordingCategory];
    }
}

- (NSString *)getSectionInt:(int)x {
    switch (x) {
        case 0:
            return @"12"; // Societat
        case 1:
            return @"2"; // Economia
        case 2:
            return @"10"; // Politica
        case 3:
            return @"11"; // Successos
        case 4:
            return @"13"; // Cultura
        case 5:
            return @"15"; // Esports
        case 6:
            return @"4"; // Editorial
        case 7:
            return @"63"; // Entrevistes
        case 8:
            return @"7"; // Opinio
    }
    return @"0";
}

- (void)errorOccurred:(NSString *)error {
    [self restoreVariablesCommunication];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_Error", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"_Ok", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)infoOccurred:(NSString *)error {
    [self restoreVariablesCommunication];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"_Information", nil) message:error delegate:nil cancelButtonTitle:NSLocalizedString(@"_Ok", nil) otherButtonTitles:nil];
    [alertView show];
}

- (void)restoreVariablesCommunication {
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:FALSE];
    [refreshControl endRefreshing];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [[fetchedResultsController sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *array = [[NSBundle mainBundle] loadNibNamed:@"MainTableViewCell" owner:self options:nil];
    MainTableViewCell *cell = [array objectAtIndex:0];
    
    Article *article = [fetchedResultsController objectAtIndexPath:indexPath];
    
    [cell setArticle:article];
    
    if (!([[article title] isEqual:@""]) && ([article title] != nil)) {
        [[cell titleCell] setText:[[article title] uppercaseString]];
    }
    
    if (!([[article dateString] isEqual:@""]) && ([article dateString] != nil)) {
        [[cell dateCell] setText:[article dateString]];
    }
    
    if (!([[article section] isEqual:@""]) && ([article section] != nil)) {
        [[cell seccioCell] setText:[article section]];
    }
    
    if ([article image] != nil) {
        [[cell imageViewCell] setHidden:FALSE];
        [[cell progressView] setHidden:TRUE];
        UIImage *image = [Tools imageWithImage:[UIImage imageWithData:[article image]] scaledToWidth:300];
        [[cell imageViewCell] setImage:image];
        
    } else if ([article urlImage] != nil) {
        [[cell imageViewCell] setHidden:FALSE];
        [[cell progressView] setHidden:FALSE];
        UIImage *image = [Tools imageWithImage:[UIImage imageNamed:@"NoImage"] scaledToWidth:133];
        [[cell imageViewCell] setImage:image];
        
        if (![article loadingImage]) {
            [article setLoadingImage:TRUE];
            
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[article urlImage]]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIImage *imageArticle = [Tools imageWithImage:[UIImage imageWithData:responseObject] scaledToWidth:300];
                
                [article setImage:UIImagePNGRepresentation(imageArticle)];
                [article setLoadingImage:FALSE];
                [[cell progressView] setHidden:TRUE];
                [appDelegate saveContext];
                [[cell imageViewCell] setImage:imageArticle];
                [cell setNeedsLayout];
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                [article setLoadingImage:FALSE];
                [[cell progressView] setHidden:TRUE];
                [appDelegate saveContext];
            }];
            
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
                float progress = (((float)totalBytesRead * 100) / (float)totalBytesExpectedToRead) / 100;
                
                [[cell progressView] setProgress:progress animated:TRUE];
                [cell setNeedsLayout];
            }];
            
            [imagesQueue addOperation:operation];
        }
    } else {
        [[cell imageViewCell] setHidden:TRUE];
        [[cell progressView] setHidden:TRUE];
    }
    
    return cell;
}

- (UIImage *)getImageArticle:(NSString *)url {
    return [UIImage imageWithData: [NSData dataWithContentsOfURL:[NSURL URLWithString:url]]];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [networkQueue cancelAllOperations];
    [self restoreVariablesCommunication];
    [[self tableView] deselectRowAtIndexPath:indexPath animated:TRUE];
    
    [self performSegueWithIdentifier:@"showDetailArticle" sender:indexPath];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    DetailArticleViewController *nc = segue.destinationViewController;
    [nc setArticle:[fetchedResultsController objectAtIndexPath:sender]];
}

#pragma mark - IBActions

- (IBAction)showSections:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BonDia" bundle:nil];
    UINavigationController* nc = [sb instantiateViewControllerWithIdentifier:@"SectionNavigationViewController"];
    SectionTableViewController *sectionTableViewController = nc.viewControllers[0];
    [sectionTableViewController setSectionSelected:sectionSelected];
    [self presentViewController:nc animated:TRUE completion:nil];
}

- (IBAction)showAbout:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BonDia" bundle:nil];
    AboutUsViewController* nc = [sb instantiateViewControllerWithIdentifier:@"AboutUsNavigationViewController"];
    [self presentViewController:nc animated:TRUE completion:nil];
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController {
    if (fetchedResultsController == nil) {
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        [fetchRequest setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:appDelegate.managedObjectContext]];
        
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"dateTimestamp" ascending:NO];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor,nil];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:appDelegate.managedObjectContext sectionNameKeyPath:nil cacheName:nil];
        [[fetchedResultsController fetchRequest] setFetchLimit:limitArticleList];
        [fetchedResultsController setDelegate:self];
    }
    
    if ([[fetchedResultsController fetchedObjects] count] == 0) {
        [labelNoArticles setHidden:FALSE];
    } else {
        [labelNoArticles setHidden:TRUE];
    }
    
    return fetchedResultsController;
}

- (void)removeAllArticleManagedObject {
    NSError *error = nil;
    NSFetchRequest *allArticles = [[NSFetchRequest alloc] init];
    [allArticles setEntity:[NSEntityDescription entityForName:@"Article" inManagedObjectContext:appDelegate.managedObjectContext]];
    [allArticles setIncludesPropertyValues:NO];
    NSArray *arrayArticle = [appDelegate.managedObjectContext executeFetchRequest:allArticles error:&error];
    for (NSManagedObject *article in arrayArticle) {
        [appDelegate.managedObjectContext deleteObject:article];
    }
}

- (void)refreshListAccordingCategory {
    [[self navigationItem] setTitle:sectionSelected];
    
    NSPredicate *predicate;
    if ([sectionSelected isEqualToString:@"Recents"]) {
        predicate = [NSPredicate predicateWithFormat:@"section != %@", sectionSelected];
    } else {
        predicate = [NSPredicate predicateWithFormat:@"section = %@", sectionSelected];
    }
    [[fetchedResultsController fetchRequest] setPredicate:predicate];
    [[fetchedResultsController fetchRequest] setFetchLimit:limitArticleList];
    
    NSError *error = nil;
    if (![[self fetchedResultsController] performFetch:&error]) {
        NSLog(@"MainTableViewController - Impossible write/read article list. Details: %@, %@", error, [error userInfo]);
        abort();
    }
    if ([[fetchedResultsController fetchedObjects] count] == 0) {
        [labelNoArticles setHidden:FALSE];
    } else {
        [labelNoArticles setHidden:TRUE];
    }
    [[self tableView] reloadData];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end