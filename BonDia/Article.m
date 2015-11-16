//
//  Article.m
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/10/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "Article.h"
#import "GTMNSString+HTML.h"

@implementation Article

@dynamic idArticle;
@dynamic title;
@dynamic dateString;
@dynamic dateTimestamp;
@dynamic author;
@dynamic section;
@dynamic sectionInt;
@dynamic body;
@dynamic image;
@dynamic image2;
@dynamic urlImage;
@dynamic urlImage2;
@dynamic urlArticle;
@dynamic loadingImage;

static const NSString *pathUrlArticle = @"http://www.bondia.ad/node/";

- (void)setDataFromDictionary:(NSDictionary *)dict {
    [self setIdArticle:[[dict valueForKey:@"nid"] intValue]];
    [self setTitle:[self stringByDecodingHTMLEntities:[dict valueForKey:@"títol"]]];
    [self setAuthor:[dict valueForKey:@"node_author"]];
    [self setSection:[dict valueForKey:@"section"]];
    [self setBody:[self clearBodyHTML:[dict valueForKey:@"body"]]];
    [self setDateString:[dict valueForKey:@"created"]];
    [self setLoadingImage:FALSE];
    
    [self setUrlImage2:[self parseImageURL:[dict valueForKey:@"image2"]]];
    [self setUrlImage:[self parseImageURL:[dict valueForKey:@"imatge"]]];
    
    [self setUrlArticle:[NSString stringWithFormat:@"%@%i", pathUrlArticle, [self idArticle]]];
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ca"];
    [formatter setLocale:locale];
    [formatter setDateFormat:@"EEE',' dd/MM/yyyy - HH:mm"];
    NSDate *date = [formatter dateFromString:[self dateString]];
    NSTimeInterval interval  = [date timeIntervalSince1970] ;
    [self setDateTimestamp:interval];
}

- (NSString *)parseImageURL:(NSString *)imageURL {
    @try {
        NSRange rangeFront = [imageURL rangeOfString:@" src=\""];
        NSRange rangeBack = [imageURL rangeOfString:@"\" width=\""];
        
        if ((rangeFront.length != NSNotFound) && (rangeBack.length != NSNotFound)) {
            NSRange range = NSMakeRange(rangeFront.location + rangeFront.length, rangeBack.location - rangeFront.location - rangeFront.length);
            return [imageURL substringWithRange:range];
        }
        return nil;
    }
    @catch (NSException *exception) {
        return nil;
    }
}

- (void)setDataFromAirDrop:(NSDictionary *)dict {
    if ([dict valueForKey:@"idArticle"] != nil) [self setIdArticle:[[dict valueForKey:@"idArticle"] doubleValue]];
    if ([dict valueForKey:@"title"] != nil) [self setTitle:[dict valueForKey:@"title"]];
    if ([dict valueForKey:@"author"] != nil) [self setAuthor:[dict valueForKey:@"author"]];
    if ([dict valueForKey:@"section"] != nil) [self setSection:[dict valueForKey:@"section"]];
    if ([dict valueForKey:@"body"] != nil) [self setBody:[dict valueForKey:@"body"]];
    if ([dict valueForKey:@"timestamp"] != nil) [self setDateTimestamp:[[dict valueForKey:@"timestamp"] doubleValue]];
    if ([dict valueForKey:@"loadingImage"] != nil) [self setLoadingImage:[[dict valueForKey:@"loadingImage"] boolValue]];
    if ([dict valueForKey:@"urlImage2"] != nil) [self setUrlImage2:[dict valueForKey:@"urlImage2"]];
    if ([dict valueForKey:@"urlImage"] != nil) [self setUrlImage:[dict valueForKey:@"urlImage"]];
    if ([dict valueForKey:@"urlArticle"] != nil) [self setUrlArticle:[dict valueForKey:@"urlArticle"]];
    if ([dict valueForKey:@"dateString"] != nil) [self setDateString:[dict valueForKey:@"dateString"]];
    if ([dict valueForKey:@"image"] != nil) [self setImage:[[NSData alloc] initWithBase64EncodedString:[dict valueForKey:@"image"] options:NSDataBase64DecodingIgnoreUnknownCharacters]];
    if ([dict valueForKey:@"image2"] != nil) [self setImage2:[[NSData alloc] initWithBase64EncodedString:[dict valueForKey:@"image2"] options:NSDataBase64DecodingIgnoreUnknownCharacters]];
}


- (NSString *)stringByDecodingHTMLEntities:(NSString *)myString {
    myString = [myString gtm_stringByUnescapingFromHTML];
    myString = [myString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return myString;
}

- (NSString *)clearBodyHTML:(NSString *)myString {
    myString = [myString stringByReplacingOccurrencesOfString:@"<p> </p>" withString:@""];
    myString = [myString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    return myString;
}

@end