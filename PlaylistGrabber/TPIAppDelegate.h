//
//  TPIAppDelegate.h
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPIAppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;

@property (nonatomic, retain) NSMutableArray *windowControllers;
@end
