//
//  MainTableViewCell.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/2/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Article;

@interface MainTableViewCell : UITableViewCell

@property (nonatomic, assign) Article *article;
@property (nonatomic, strong) IBOutlet UILabel *titleCell;
@property (nonatomic, strong) IBOutlet UILabel *dateCell;
@property (nonatomic, strong) IBOutlet UILabel *seccioCell;
@property (nonatomic, strong) IBOutlet UIImageView *imageViewCell;
@property (nonatomic, strong) IBOutlet UIProgressView *progressView;

@end