//
//  AppDelegate.h
//  BonDia
//
//  Created by Marc Gomez <marc.gomez.vidal@gmail.com> on 2/2/14.
//  Copyright (c) 2014 www.marcgomez.work. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (nonatomic, strong) UIWindow *window;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

/**
 *  Save all the data when we close the app.
 */
- (void)saveContext;

/**
 *  Returns the URL to the application's Documents directory.
 */
- (NSURL *)applicationDocumentsDirectory;

@end