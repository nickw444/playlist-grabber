//
//  TPISelectFileWindowController.h
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface TPISelectFileWindowController : NSWindowController
- (IBAction)continueButtonPressed:(id)sender;
- (IBAction)fileSelectButtonPressed:(id)sender;
@property (weak) IBOutlet NSTextField *filenameLabel;
@property (weak) IBOutlet NSButton *continueButton;
@property (nonatomic, retain) NSURL *lastURL;
@end
