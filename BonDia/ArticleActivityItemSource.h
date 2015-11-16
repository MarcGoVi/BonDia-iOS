//
//  ArticleActivityItemSource.h
//  BonDia
//
//  Created by Marc Gomez on 4/10/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Article;

@interface ArticleActivityItemSource : NSObject <UIActivityItemSource> {
    Article *article;
}

- (id)initWithArticle:(Article *)article;

@end