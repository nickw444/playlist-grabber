//
//  TPIPlaylistSelectionWindowController.h
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "TPICheckboxTableCellView.h"
@interface TPIPlaylistSelectionWindowController : NSWindowController <NSTableViewDataSource, NSTableViewDelegate, TPICheckboxTableCellViewDelegate>
- (IBAction)copyMusicButton:(id)sender;
@property (weak) IBOutlet NSTableView *tableView;
@property (weak) IBOutlet NSProgressIndicator *activityIndicator;

@property (weak) IBOutlet NSTextField *statusText;
- (IBAction)saveSelected:(id)sender;

@property (nonatomic, retain) NSURL *itunesURL;
@property (nonatomic, retain) NSDictionary *itunesData;
@property (nonatomic, retain) NSMutableArray *playlists;
@end
