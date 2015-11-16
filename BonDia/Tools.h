//
//  Tools.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 1/8/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Tools : NSObject

+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToWidth:(float)i_width;

+ (UIImage *)imageWithImage:(UIImage *)sourceImage scaledToHeight:(float)i_height;

@end