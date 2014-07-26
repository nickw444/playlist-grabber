//
//  TPICheckboxTableCellView.m
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import "TPICheckboxTableCellView.h"

@implementation TPICheckboxTableCellView
@synthesize delegate;

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect
{
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)cellWasChanged:(id)sender {
    [delegate CellTickedWasChanged:self row:self.row];
}

@end
