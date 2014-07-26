//
//  TPICheckboxTableCellView.h
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol TPICheckboxTableCellViewDelegate <NSObject>

-(void)CellTickedWasChanged:(id)cell row:(NSInteger)row;

@end

@interface TPICheckboxTableCellView : NSTableCellView
@property (nonatomic, retain) IBOutlet NSButton *checkbox;
@property (nonatomic) NSInteger row;
@property (nonatomic, retain) id <TPICheckboxTableCellViewDelegate> delegate;
-(IBAction)cellWasChanged:(id)sender;

@end
