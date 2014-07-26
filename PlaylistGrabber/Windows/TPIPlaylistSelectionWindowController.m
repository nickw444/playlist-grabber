//
//  TPIPlaylistSelectionWindowController.m
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import "TPIPlaylistSelectionWindowController.h"
#import "TPICheckboxTableCellView.h"
@interface TPIPlaylistSelectionWindowController ()

@end

@implementation TPIPlaylistSelectionWindowController
@synthesize itunesData;
@synthesize playlists;

- (id)initWithWindow:(NSWindow *)window
{
    self = [super initWithWindow:window];
    if (self) {
        // Initialization code here.
        playlists = [NSMutableArray array];
    }
    return self;
}

- (void)windowDidLoad
{
    [super windowDidLoad];
    NSLog(@"Fetching plist: %@", [self.itunesURL absoluteString]);
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    

    itunesData = [NSDictionary dictionaryWithContentsOfURL:self.itunesURL];

//    NSLog(@"%@",[plistData objectForKey:@"Playlists"]);
    
    
    for (NSDictionary *playlist in [itunesData objectForKey:@"Playlists"]) {
//        Do something with the playlists. (like show them)
//        [playlist setValue:@"isSelected" forKey:@""]
        [playlist setValue:[NSNumber numberWithBool:NO] forKey:@"isSelected"];
        [playlists addObject:playlist];
    }
    
//    NSLog(@"%@", [[plistData objectForKey:@"Tracks"] objectForKey:@"261"]);
    

    [self.tableView reloadData];
    NSLog(@"DONE");

}

#pragma mark - Tableview 
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [playlists count];
}

-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
//
//    NSView *view = [[NSView alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 120, 20))];
//    NSTextField *label = [[NSTextField alloc] initWithFrame:NSRectFromCGRect(CGRectMake(0, 0, 120, 20))];
//    [label setStringValue:[[self.playlists objectAtIndex:row] objectForKey:@"Name"]];
//    [view addSubview:label];
//    return view;

//    [[NSTableCellView alloc] initWithFrame:]
    
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"firstColumn"]) {
        
        // We pass us as the owner so we can setup target/actions into this main controller object
        TPICheckboxTableCellView *cellView = [tableView makeViewWithIdentifier:@"checkboxCell" owner:self];

        // Then setup properties on the cellView based on the column
//        cellView.textField.stringValue = @"Name";
        cellView.checkbox.title = [[self.playlists objectAtIndex:row] objectForKey:@"Name"];
        return cellView;
    }
    return nil;
}


-(NSArray*)getSelectedPlaylists {
    int i = 0;
    NSMutableArray *selected = [NSMutableArray array];
    for (NSDictionary *playlist in self.playlists) {
        TPICheckboxTableCellView *cell = [self.tableView viewAtColumn:0 row:i makeIfNecessary:NO];
        if ([cell.checkbox state] == 1) {
            [selected addObject:playlist];
        }
        i++;
    }
    return [NSArray arrayWithArray:selected];
}

- (IBAction)copyMusicButton:(id)sender {
    //Show a file picker to place the music in
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    
    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Change "Open" dialog button to "Select"
    [openDlg setPrompt:@"Select"];
    
    NSURL *folderURL;
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
        
        folderURL = [files objectAtIndex:0];
    }
    else {
        //TODO do something if they cancel.
        return;
        
    }
    
    
    
    //Setup base file structure
    NSString *basefolder = [[[folderURL absoluteString] stringByReplacingOccurrencesOfString:@"file://" withString:@""]  stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *musicFolder = [NSString stringWithFormat:@"%@/Collection/", basefolder];
    NSString *playlistFolder = [NSString stringWithFormat:@"%@", basefolder];
    
    NSError *error;
    [[NSFileManager defaultManager]createDirectoryAtPath:musicFolder withIntermediateDirectories:YES attributes:nil error:&error];
    [[NSFileManager defaultManager]createDirectoryAtPath:playlistFolder withIntermediateDirectories:YES attributes:nil error:&error];
    
    
    
    NSArray *selectedPlaylists = [self getSelectedPlaylists];
    
    //Loop through playlists, generate M3U's AND
    NSMutableArray *requiredSongs = [NSMutableArray array];
    for (NSDictionary *playlist in selectedPlaylists) {
        //M3U for this playlist.
        NSString *playlistString = @"#EXTM3U\n";
        for (NSDictionary *song in [playlist objectForKey:@"Playlist Items"]) {
            
            NSNumber *songID = [song objectForKey:@"Track ID"];
            //Make the M3U for this song
            NSDictionary *song = [[itunesData objectForKey:@"Tracks"] objectForKey:[songID stringValue]];
            NSString *artist = [song objectForKey:@"Artist"];
            NSString *album = [song objectForKey:@"Album"];
            NSString *songTitle = [song objectForKey:@"Name"];
            NSString *baseLoc = [[song objectForKey:@"Location"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
            NSString *location = [NSString stringWithFormat:@"./Collection/%@/%@/%@", artist, album, [baseLoc lastPathComponent] ];
            NSString *songM3ULine = [NSString stringWithFormat:@"#EXTINF:%d,%@ - %@\n%@", [songID intValue], songTitle, artist, location];
            playlistString = [playlistString stringByAppendingString:songM3ULine];
            playlistString = [playlistString stringByAppendingString:@"\n"];
            if (![requiredSongs containsObject:songID]) {
                [requiredSongs addObject:songID];
            }
        }
        NSString *playlistFile = [NSString stringWithFormat:@"%@%@.m3u", playlistFolder, [playlist objectForKey:@"Name"]];
        [[NSFileManager defaultManager] createFileAtPath:playlistFile contents:[playlistString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }
    
    
    NSMutableArray *songPathsErrors = [NSMutableArray array];
    for (NSNumber *songID in requiredSongs) {
        //    Look up song locations.
        //    Copy the music to the desired folder.
        //    Easy peasy.
        NSDictionary *song = [[itunesData objectForKey:@"Tracks"] objectForKey:[songID stringValue]];
        
        NSString *basicLocation = [[[song objectForKey:@"Location"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];

        if ([[NSFileManager defaultManager] fileExistsAtPath:basicLocation]) {
            //Song Exists
            
            NSLog(@"Source: %@", basicLocation);
            NSString *filename = [basicLocation lastPathComponent];
            
            NSString *artist = [song objectForKey:@"Artist"];
            NSString *album = [song objectForKey:@"Album"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@/", musicFolder, artist, album] withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *dest = [NSString stringWithFormat:@"%@%@/%@/%@", musicFolder, artist, album, filename];
            NSLog(@"Dest: %@", dest);
            NSError *error;
            [[NSFileManager defaultManager] copyItemAtPath:basicLocation toPath:dest error:&error];
            if (error) {
                [song setValue:error.localizedDescription forKey:@"error"];
            }
        }
        else {
            //Song Doesn't Exist or isn't readable by us
            [song setValue:@"Could not load song" forKey:@"error"];
            [songPathsErrors addObject:song];
        }
    }

    NSLog(@"Errors: %@", songPathsErrors);
    
}

- (IBAction)generateM3UButton:(id)sender {
    [self getSelectedPlaylists];
}
@end
