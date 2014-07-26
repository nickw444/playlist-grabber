//
//  TPISelectFileWindowController.m
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import "TPISelectFileWindowController.h"
#import "TPIPlaylistSelectionWindowController.h"
#import "TPIAppDelegate.h"
@interface TPISelectFileWindowController ()

@end

@implementation TPISelectFileWindowController

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}

- (IBAction)continueButtonPressed:(id)sender {

    TPIPlaylistSelectionWindowController *next = [[TPIPlaylistSelectionWindowController alloc] initWithWindowNibName:@"TPIPlaylistSelectionWindowController"];
    
    TPIAppDelegate *delegate = (TPIAppDelegate *)[[NSApplication sharedApplication]delegate];
    next.itunesURL = self.lastURL;
    NSLog(@"%@", self.lastURL);
    [delegate.windowControllers addObject:next];
    [next.window makeKeyWindow];
    [self.window orderOut:self];
    [delegate.windowControllers removeObjectAtIndex:0];
}

- (IBAction)fileSelectButtonPressed:(id)sender {
    
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:YES];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:NO];
    
    // Change "Open" dialog button to "Select"
    [openDlg setPrompt:@"Select"];
    [openDlg setAllowsMultipleSelection:NO];
    [openDlg setAllowedFileTypes:@[@"xml"]];

    
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    if ( [openDlg runModal] == NSOKButton )
    {
        // Get an array containing the full filenames of all
        // files and directories selected.
        NSArray* files = [openDlg URLs];
        if ([files count] != 1) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"Please Try Again" defaultButton:@"Try Again" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You must only select one file"];
            [alert runModal];
            return;
        }
        
        NSURL* fileName = [files objectAtIndex:0];
        NSString *file = [[fileName absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""];
        
        [self.filenameLabel setStringValue:file];
        [self.continueButton setEnabled:TRUE];
        self.lastURL = fileName;
        
    }
    
    
}

@end
