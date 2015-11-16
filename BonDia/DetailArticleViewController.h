//
//  DetailArticleViewController.h
//  NewsAnd
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 1/4/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JTSImageViewController.h"

@class Article;
@class AppDelegate;

@interface DetailArticleViewController : UIViewController <JTSImageViewControllerInteractionsDelegate, UIAlertViewDelegate> {
    AppDelegate *appDelegate;
    
    IBOutlet UIView *contentView;
    IBOutlet UIScrollView *scrollView;
    IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
    IBOutlet NSLayoutConstraint *scrollViewTopConstraint;
    
    IBOutlet UILabel *articleTitle;
    IBOutlet UILabel *date;
    IBOutlet UILabel *section;
    IBOutlet UIImageView *imageView;
    IBOutlet UIImageView *imageViewFull;
    IBOutlet UITextView *author;
    IBOutlet UITextView *body;
    IBOutlet UIProgressView *progressView;
    NSOperationQueue *networkQueue;
}

@property (nonatomic, strong) Article *article;

@end