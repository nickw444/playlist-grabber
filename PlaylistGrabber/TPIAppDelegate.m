//
//  TPIAppDelegate.m
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import "TPIAppDelegate.h"
#import "TPISelectFileWindowController.h"
@implementation TPIAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    self.windowControllers = [NSMutableArray array];
    // Insert code here to initialize your application
        TPISelectFileWindowController *first = [[TPISelectFileWindowController alloc] initWithWindowNibName:@"TPISelectFileWindowController"];
    [self.windowControllers addObject:first];
    [first showWindow:first.window];
}
- (BOOL) applicationShouldTerminateAfterLastWindowClosed: (NSApplication *) theApplication {
    return YES;
}
@end
