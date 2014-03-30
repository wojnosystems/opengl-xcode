//
//  AppDelegate.h
//  OpenGLBook
//
//  Created by Christopher Richard Wojno on 2014/3/22.
//  Copyright (c) 2014 Christopher Richard Wojno. All rights reserved.
//

#import <Cocoa/Cocoa.h>
@class MyOpenGLView;

@interface AppDelegate : NSObject <NSApplicationDelegate,NSWindowDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet MyOpenGLView *gl;

@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;

- (IBAction)saveAction:(id)sender;


@end
