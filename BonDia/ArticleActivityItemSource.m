//
//  ArticleActivityItemSource.m
//  BonDia
//
//  Created by Marc Gomez on 4/10/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import "ArticleActivityItemSource.h"
#import "Article.h"

@implementation ArticleActivityItemSource

#pragma mark - Initialization method

- (id)initWithArticle:(Article *)_article {
    self = [super init];
    if (self != nil) {
        article = _article;
    }
    return self;
}

#pragma mark - UIActivityItemSource delegate

- (id)activityViewController:(UIActivityViewController *)activityViewController itemForActivityType:(NSString *)activityType {
    if ([activityType isEqualToString:UIActivityTypePostToTwitter]) {
        NSString *twitterText = [[NSString alloc] init];
        if ([[article title] length] > 106) {
            twitterText = [NSString stringWithFormat:@"%@...",[[article title] substringWithRange:NSMakeRange(0, 106)]];
        } else {
            twitterText = [article title];
        }
        twitterText = [twitterText stringByAppendingString:[NSString stringWithFormat:@" %@ @bondia", [article urlArticle]]];
        return twitterText;
    } else if ([activityType isEqualToString:UIActivityTypePostToFacebook]) {
        NSString *facebookString = [[NSString alloc] initWithFormat:@"%@ %@ - Diari Bondia", [article title], [article urlArticle]];
        return facebookString;
    } else if ([activityType isEqualToString:UIActivityTypeMessage]) {
        NSString *messageString = [[NSString alloc] initWithFormat:@"%@ %@ - Diari Bondia", [article title], [article urlArticle]];
        return messageString;
    } else if ([activityType isEqualToString:UIActivityTypeMail]) {
        NSString *mailString = [[NSString alloc] initWithFormat:@"%@ %@ - Diari Bondia", [article title], [article urlArticle]];
        return mailString;
    } else if ([activityType isEqualToString:UIActivityTypeCopyToPasteboard]) {
        NSString *copyPasteString = [[NSString alloc] initWithFormat:@"%@ %@ - Diari Bondia", [article title], [article urlArticle]];
        return copyPasteString;
    } else if ([activityType isEqualToString:UIActivityTypeAirDrop]) {
        
        NSURL *cache = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory
                                                              inDomain:NSUserDomainMask
                                                     appropriateForURL:nil
                                                                create:YES
                                                                 error:nil];
        NSURL *scratchFolder = [cache URLByAppendingPathComponent:@"airdrop_scratch"];
        [[NSFileManager defaultManager] removeItemAtURL:scratchFolder error:nil];
        [[NSFileManager defaultManager] createDirectoryAtURL:scratchFolder withIntermediateDirectories:YES attributes:@{} error:nil];
        
        // You can't put '/' in a filename. Replace it with a unicode character
        // that looks quite a lot like a /.
        NSString *safeFilename = [[article title] stringByReplacingOccurrencesOfString:@"/" withString:@"\u2215"];
        
        // The file on disk has to end with a custom file extension that we have defined.
        // Check "Document Types" and "Exported UTIs" in the project settings to see
        // where this file extension is defined.
        NSURL *tempPath = [scratchFolder URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.airdropbondia", safeFilename]];
        
        // Write the URL into the file, and return the file to be shared.
        NSString *articleString = [[NSString alloc] init];
        articleString = [articleString stringByAppendingFormat:@"idArticle_?_%d",[article idArticle]];
        if (([article title] != nil) && ([[article title] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_title_?_%@",[article title]];
        }
        if (([article author] != nil) && ([[article author] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_author_?_%@",[article author]];
        }
        if (([article section] != nil) && ([[article section] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_section_?_%@",[article section]];
        }
        if (([article body] != nil) && ([[article body] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_body_?_%@",[article body]];
        }
        articleString = [articleString stringByAppendingFormat:@"_?_timestamp_?_%f",[article dateTimestamp]];
        articleString = [articleString stringByAppendingFormat:@"_?_loadingImage_?_%i",[article loadingImage]];
        if (([article urlImage2] != nil) && ([[article urlImage2] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_urlImage2_?_%@",[article urlImage2]];
        }
        if (([article urlImage] != nil) && ([[article urlImage] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_urlImage_?_%@",[article urlImage]];
        }
        if (([article urlArticle] != nil) && ([[article urlArticle] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_urlArticle_?_%@",[article urlArticle]];
        }
        if (([article dateString] != nil) && ([[article dateString] length] != 0)) {
            articleString = [articleString stringByAppendingFormat:@"_?_dateString_?_%@",[article dateString]];
        }
        if ([article image] != nil) {
            articleString = [articleString stringByAppendingFormat:@"_?_image_?_%@",[[article image] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
        }
        if ([article image2] != nil) {
            articleString = [articleString stringByAppendingFormat:@"_?_image2_?_%@",[[article image2] base64EncodedStringWithOptions:NSDataBase64Encoding64CharacterLineLength]];
        }
        
        NSError *error;
        bool done = [articleString writeToURL:tempPath atomically:YES encoding:NSUTF8StringEncoding error:&error];
        if (!done) {
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error" message:@"No s'ha pogut enviar la notícia per AirDrop." delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles:nil];
            [alertView show];
            return nil;
        } else {
            return tempPath;
        }
    } else {
        NSString *textString = [[NSString alloc] initWithFormat:@"%@ %@ - Diari Bondia", [article title], [article urlArticle]];
        return textString;
    }
    return nil;
}

- (id)activityViewControllerPlaceholderItem:(UIActivityViewController *)activityViewController {
    return @"";
}

- (NSString *)activityViewController:(UIActivityViewController *)activityViewController subjectForActivityType:(NSString *)activityType {
    return @"Notícia Diari Bondia";
}

- (UIImage *)activityViewController:(UIActivityViewController *)activityViewController thumbnailImageForActivityType:(NSString *)activityType suggestedSize:(CGSize)size {
    if ([activityType isEqualToString:UIActivityTypeAirDrop]) {
        // this is the preview image in the "Accept airdrop" dialog. We're using the
        // app icon here (there is no app icon in this bundle, so it will still be
        // blank) but you can use anything, even customize to the content.
        return [UIImage imageNamed:@"BonDia_airDrop"];
    }
    return nil;
}

@end