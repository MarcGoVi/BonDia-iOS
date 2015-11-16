//
//  DetailArticleViewController.m
//  NewsAnd
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 1/4/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "DetailArticleViewController.h"
#import "Article.h"
#import "WebPageViewController.h"
#import <Google/Analytics.h>
#import <Photos/Photos.h>
#import "Tools.h"
#import "AFHTTPRequestOperation.h"
#import "AppDelegate.h"
#import "ArticleActivityItemSource.h"
#import "JTSImageInfo.h"
#import "SVProgressHUD.h"

@interface DetailArticleViewController()
- (void)alertSaveImage;
- (void)handleLongPress:(UILongPressGestureRecognizer *)sender;
- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo;
@end

@implementation DetailArticleViewController

@synthesize article;

#pragma mark - View methods

- (void)viewDidLoad {
    [super viewDidLoad];
    
    appDelegate = [[UIApplication sharedApplication] delegate];
    
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker set:kGAIScreenName value:@"Noticia"];
    [tracker send:[[GAIDictionaryBuilder createScreenView] build]];
    
    [self setTitle:@"Notícia"];
    
    networkQueue = [[NSOperationQueue alloc] init];
    
    //UIBarButtonItem *webViewButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"web_button"] style:UIBarButtonItemStylePlain target:self action:@selector(goWebView:)];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(goShare:)];
    NSArray *arrayButtonItems = [[NSArray alloc] initWithObjects:shareButton, nil];
    
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] init];
    [tapRecognizer addTarget:self action:@selector(imageViewTapped:)];
    [imageView addGestureRecognizer:tapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer = [[UILongPressGestureRecognizer alloc] init];
    [longPressRecognizer addTarget:self action:@selector(handleLongPress:)];
    [imageView addGestureRecognizer:longPressRecognizer];
    
    [[self navigationItem] setRightBarButtonItems:arrayButtonItems];
    [progressView setProgress:0.0];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self refreshView];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self loadNoticia];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [networkQueue cancelAllOperations];
}

- (void)refreshView {
    if (!([[article title] isEqual:@""]) && ([article title] != nil)) {
        [articleTitle setText:[[article title] uppercaseString]];
        [articleTitle sizeToFit];
    }
    
    if (!([[article dateString] isEqual:@""]) && ([article dateString] != nil)) {
        [date setText:[article dateString]];
        [date sizeToFit];
    }
    
    if (!([[article section] isEqual:@""]) && ([article section] != nil)) {
        [section setText:[article section]];
        [section sizeToFit];
    }
    
    if (([article urlImage] != nil) && ([article urlImage2] != nil)) {
        if ([article image2] != nil) {
            [progressView setHidden:TRUE];
            [imageView setImage:[Tools imageWithImage:[UIImage imageWithData:[article image2]] scaledToWidth:300]];
        } else {
            if ([article image] != nil) {
                [imageView setImage:[Tools imageWithImage:[UIImage imageWithData:[article image]] scaledToWidth:300]];
            } else {
                [imageView setImage:[Tools imageWithImage:[UIImage imageNamed:@"NoImage"] scaledToWidth:133]];
            }
            NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[article urlImage2]]];
            AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
            [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
                UIImage *image = [Tools imageWithImage:[UIImage imageWithData:responseObject] scaledToWidth:300];
                [article setImage2:UIImagePNGRepresentation(image)];
                [appDelegate saveContext];
                [self refreshView];
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            }];
            [operation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead){
                float progress = (((float)totalBytesRead * 100) / (float)totalBytesExpectedToRead) / 100;
                [progressView setProgress:progress animated:TRUE];
            }];
            [networkQueue addOperation:operation];
        }
    } else {
        [imageView removeFromSuperview];
        [progressView removeFromSuperview];
    }
    
    [self updateConstraints];
}

- (void)loadNoticia {
    if (!([[article author] isEqual:@""]) && ([article author] != nil)) {
        [author setFont:[UIFont fontWithName:@"Helvetica Neue" size:13.0]];
        NSString *strAuthor = [[article author] stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                         author.font.fontName,
                                                                         author.font.pointSize]];
        
        NSString *writeBy = @"<strong>Escrit per: </strong>";
        NSString *finalString = [writeBy stringByAppendingString:strAuthor];
        
        [author setAttributedText:[[NSAttributedString alloc] initWithData:[finalString dataUsingEncoding:NSUnicodeStringEncoding]
                                                                   options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                        documentAttributes:nil
                                                                     error:nil]];
        
        [author setTextAlignment:NSTextAlignmentLeft];
        [author sizeToFit];
    }
    
    if (!([[article body] isEqual:@""]) && ([article body] != nil)) {
        [body setFont:[UIFont fontWithName:@"Helvetica Neue" size:15.0]];
        NSString *strBody = [[article body] stringByAppendingString:[NSString stringWithFormat:@"<style>body{font-family: '%@'; font-size:%fpx;}</style>",
                                                                     body.font.fontName,
                                                                     body.font.pointSize]];
        
        [body setAttributedText:[[NSAttributedString alloc] initWithData:[strBody dataUsingEncoding:NSUnicodeStringEncoding]
                                                                 options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
                                                      documentAttributes:nil
                                                                   error:nil]];
        
        [body setTextAlignment:NSTextAlignmentJustified];
        [body sizeToFit];
    }
    [self updateConstraints];
}

- (void)updateConstraints {
    [self.view setNeedsLayout];
    [self.view layoutIfNeeded];
    float totalSize = 8 + articleTitle.frame.size.height + 8 + date.frame.size.height + 8 + progressView.frame.size.height + imageView.frame.size.height + 8 + author.frame.size.height + 8 + body.frame.size.height;
    contentViewHeightConstraint.constant = totalSize;
    scrollViewTopConstraint.constant = -64;
}

#pragma mark - JTSImageViewController

- (IBAction)imageViewTapped:(id)sender {
    if ([article image2] != nil) {
        JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
        imageInfo.image = [UIImage imageWithData:[article image2]];
        imageInfo.referenceRect = imageView.frame;
        imageInfo.referenceView = imageView.superview;
        imageInfo.referenceContentMode = imageView.contentMode;
        imageInfo.referenceCornerRadius = imageView.layer.cornerRadius;
        
        // Setup view controller
        JTSImageViewController *imageViewer = [[JTSImageViewController alloc]
                                               initWithImageInfo:imageInfo
                                               mode:JTSImageViewControllerMode_Image
                                               backgroundStyle:JTSImageViewControllerBackgroundOption_Scaled];
        [imageViewer setInteractionsDelegate:self];
        
        // Present the view controller.
        [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
    }
}

- (void)imageViewerDidLongPress:(JTSImageViewController *)imageViewer atRect:(CGRect)rect {
    [self alertSaveImage];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if ([article image2] != nil) {
        if (sender.state == UIGestureRecognizerStateBegan){
            [self alertSaveImage];
        }
    }
}

#pragma mark - AlertView

- (void)alertSaveImage {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Guardar imatge"
                                                    message:@"Voleu guardar la imatge?"
                                                   delegate:self
                                          cancelButtonTitle:@"No"
                                          otherButtonTitles:@"Sí",nil];
    [alert setTag:1];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1 && alertView.tag == 1) {
        PHAuthorizationStatus status = [PHPhotoLibrary authorizationStatus];
        if (status == PHAuthorizationStatusDenied || status == PHAuthorizationStatusRestricted) {
            if (UIApplicationOpenSettingsURLString != NULL) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenció" message:@"Cal que doneu permís a aquesta aplicació per accedir a la seva biblioteca de fotos." delegate:self cancelButtonTitle:@"Tancar" otherButtonTitles:@"Donar permís", nil];
                [alert setTag:2];
                [alert show];
            } else {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Atenció" message:@"Cal que doneu permís en l'apartat de configuració del telèfon per poder accedir a la seva biblioteca de fotos." delegate:nil cancelButtonTitle:@"Tancar" otherButtonTitles:nil, nil];
                [alert show];
            }
        } else if (status == PHAuthorizationStatusNotDetermined || status == PHAuthorizationStatusAuthorized) {
            [SVProgressHUD show];
            UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:[article image2]], self, @selector(image:didFinishSavingWithError:contextInfo:), nil);
        }
    }
    if (buttonIndex == 1 && alertView.tag == 2) {
        NSURL *url = [NSURL URLWithString:UIApplicationOpenSettingsURLString];
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Image

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo: (void *)contextInfo {
    if (!error) {
        [SVProgressHUD showSuccessWithStatus:@"Imatge guardada!"];
    } else {
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }
}

#pragma mark - IBAction

- (IBAction)goWebView:(id)sender {
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"BonDia" bundle:nil];
    WebPageViewController* vc = [sb instantiateViewControllerWithIdentifier:@"WebPageViewController"];
    [vc setUrl:[article urlArticle]];
    [vc setTitleWebView:@"BonDia"];
    [[self navigationController] pushViewController:vc animated:TRUE];
}

- (IBAction)goShare:(id)sender {
    ArticleActivityItemSource *activityIS = [[ArticleActivityItemSource alloc] initWithArticle:article];
    
    NSArray *objectsToShare;
    //objectsToShare = @[self, [NSURL URLWithString:[article urlArticle]]];
    objectsToShare = @[activityIS];
    
    UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:objectsToShare applicationActivities:nil];
    
    NSArray *excludedActivities = @[UIActivityTypePostToWeibo,
                                    UIActivityTypePrint,
                                    UIActivityTypeAssignToContact, UIActivityTypeSaveToCameraRoll,
                                    UIActivityTypePostToFlickr,
                                    UIActivityTypePostToVimeo, UIActivityTypePostToTencentWeibo];
    activityVC.excludedActivityTypes = excludedActivities;
    
    [self presentViewController:activityVC animated:YES completion:nil];
    
    [activityVC setCompletionWithItemsHandler:^(NSString *act, BOOL done, NSArray *returnedItems, NSError *activityError) {
        NSString *ServiceMsg = nil;
        if ([act isEqualToString:UIActivityTypeCopyToPasteboard]) {
            ServiceMsg = @"Copiat!";
        }
        if ((done) && (ServiceMsg != nil)) {
            [SVProgressHUD showSuccessWithStatus:ServiceMsg];
        }
    }];
}

#pragma mark - Memory management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end