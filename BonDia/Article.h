//
//  Article.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/10/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface Article : NSManagedObject

@property (nonatomic) int32_t idArticle;
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * dateString;
@property (nonatomic) double dateTimestamp;
@property (nonatomic, retain) NSString * author;
@property (nonatomic, retain) NSString * section;
@property (nonatomic) int32_t sectionInt;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSData * image;
@property (nonatomic, retain) NSData * image2;
@property (nonatomic, retain) NSString * urlImage;
@property (nonatomic, retain) NSString * urlImage2;
@property (nonatomic, retain) NSString * urlArticle;
@property (nonatomic) BOOL loadingImage;

- (void)setDataFromDictionary:(NSDictionary *)dict;

- (NSString *)parseImageURL:(NSString *)imageURL;

- (void)setDataFromAirDrop:(NSDictionary *)dict;

@end