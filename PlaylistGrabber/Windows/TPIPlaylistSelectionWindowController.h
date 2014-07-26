//
//  TPIPlaylistSelectionWindowController.h
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPIPlaylistSelectionWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate>
- (IBAction)copyMusicButton:(id)sender;
- (IBAction)generateM3UButton:(id)sender;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;
@property (nonatomic, retain) NSURL *itunesURL;
@property (nonatomic, retain) NSDictionary *itunesData;
@property (nonatomic, retain) NSMutableArray *playlists;
@end
