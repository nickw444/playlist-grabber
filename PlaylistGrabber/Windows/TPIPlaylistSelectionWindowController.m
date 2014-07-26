//
//  TPIPlaylistSelectionWindowController.m
//  PlaylistGrabber
//
//  Created by Nicholas Whyte on 26/07/2014.
//  Copyright (c) 2014 twopicode. All rights reserved.
//

#import "TPIPlaylistSelectionWindowController.h"

#import "TPITextCellView.h"
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
    [self.statusText setStringValue:@"Loading Library..."];
    [self.activityIndicator startAnimation:nil];;
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
    
    //Loop through last selected playlists just so we can restore the last synced ones.
    for (NSDictionary *playlist in [[NSUserDefaults standardUserDefaults] objectForKey:@"LastPlaylists"]) {
        for (NSDictionary *loadedPlaylist in playlists) {
            if ([[playlist objectForKey:@"Playlist Persistent ID"] isEqualToString:[loadedPlaylist objectForKey:@"Playlist Persistent ID"]]) {
                [loadedPlaylist setValue:[NSNumber numberWithBool:YES] forKeyPath:@"isSelected"];
            }
        }
    }
    

    [self.tableView reloadData];
    [self.activityIndicator stopAnimation:nil];
    [self.statusText setStringValue:@"Ready for export."];
//    [self.loadingBar setHidden:YES];


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
    NSDictionary *playlist = [self.playlists objectAtIndex:row];
    // In IB the tableColumn has the identifier set to the same string as the keys in our dictionary
    NSString *identifier = [tableColumn identifier];
    
    if ([identifier isEqualToString:@"firstColumn"]) {
        
        // We pass us as the owner so we can setup target/actions into this main controller object
        TPICheckboxTableCellView *cellView = [tableView makeViewWithIdentifier:@"checkboxCell" owner:self];

        // Then setup properties on the cellView based on the column
//        cellView.textField.stringValue = @"Name";
        cellView.checkbox.title = [[self.playlists objectAtIndex:row] objectForKey:@"Name"];
        cellView.row = row;
        cellView.delegate = self;
        if ([[playlist objectForKey:@"isSelected"] boolValue]) {
            [cellView.checkbox setState:1];
        }
        else {
            [cellView.checkbox setState:0];
        }
        return cellView;
    }
    if ([identifier isEqualToString:@"iconColumn"]) {
        
        // We pass us as the owner so we can setup target/actions into this main controller object
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"titleCell" owner:self];
        
        // Then setup properties on the cellView based on the column
        //        cellView.textField.stringValue = @"Name";
        
        cellView.textField.stringValue = [playlist objectForKey:@"Name"];
        
        NSString *imageString = @"";
        
        if ([[playlist objectForKey:@"Name"] isEqualToString:@"Library"]) {
            imageString = @"library";
        }
        
        if ([[playlist objectForKey:@"Folder"] boolValue]) {
            imageString = @"folder";
        }
        else if (![playlist objectForKey:@"Folder"] && ![playlist objectForKey:@"Parent Persistent ID"]) {
            imageString = @"playlist";
        }
        
//        Determine how many levels this playlist is nested.
        NSInteger depth = [self nestedLevels:playlist currentLevel:0];
        NSString *depthString = @"";

        for (int i = 0; i < depth; i++) {
            cellView.imageView.layer.opacity = 0.5;
            depthString = [depthString stringByAppendingString:@"     "];
        }
        cellView.textField.stringValue = [depthString stringByAppendingString:[playlist objectForKey:@"Name"]];
        
        
        
        int distinguishedKind = [[playlist objectForKey:@"Distinguished Kind"] intValue];
        switch (distinguishedKind) {
            case 3:
                imageString = @"tv";
                break;
                
            case 2:
                imageString = @"movie";
                break;
                
            case 10:
                imageString = @"podcast";
                break;
                
            case 26:
                imageString = @"genius";
                break;
                
            case 4:
                imageString = @"music";
                break;
                
                
            default:
                break;
        }
        
        cellView.imageView.image = [NSImage imageNamed:imageString];
        return cellView;
    }
    else if ([identifier isEqualToString:@"countColumn"]) {
        NSTableCellView *cellView = [tableView makeViewWithIdentifier:@"countCell" owner:self];
        cellView.backgroundStyle = NSBackgroundStyleDark;
        NSArray *items = [[self.playlists objectAtIndex:row] objectForKey:@"Playlist Items"];
        cellView.textField.stringValue = [NSString stringWithFormat:@"%ld Items", [items count]];
        return cellView;
    }
    return nil;
}

#pragma mark - Data Stuff

-(NSArray*)getSelectedPlaylists {
    NSMutableArray *selected = [NSMutableArray array];
    for (NSDictionary *playlist in self.playlists) {
        if ([[playlist objectForKey:@"isSelected"] boolValue] == TRUE) {
            [selected addObject:playlist];
        }
    }
    return [NSArray arrayWithArray:selected];
}

- (IBAction)copyMusicButton:(id)sender {
    //probs should re-write for async.
    [self doCopyMusic];
    
    
}

-(void) saveSelectedPlaylists {
    NSArray *pls = [self getSelectedPlaylists];
    [[NSUserDefaults standardUserDefaults] setObject:pls forKey:@"LastPlaylists"];
    [[NSUserDefaults standardUserDefaults]synchronize];
    [self.statusText setStringValue:@"Selected Playlists Saved"];

}
-(void)doCopyMusic {
    [self saveSelectedPlaylists];
    [self.activityIndicator startAnimation:nil];
    
    [self.statusText setStringValue:@"Waiting for selection of destination folder..."];
    
    //Show a file picker to place the music in
    NSOpenPanel* openDlg = [NSOpenPanel openPanel];
    
    // Enable the selection of files in the dialog.
    [openDlg setCanChooseFiles:NO];
    [openDlg setCanCreateDirectories:YES];

    // Enable the selection of directories in the dialog.
    [openDlg setCanChooseDirectories:YES];
    
    // Change "Open" dialog button to "Select"
    [openDlg setPrompt:@"Select"];
    
    NSURL *folderURL;
    // Display the dialog.  If the OK button was pressed,
    // process the files.
    [self.statusText setStringValue:@"Exporting Music. This can take a while..."];
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
        [self.statusText setStringValue:@"Export Cancelled. User did not select a destination"];
        [self.activityIndicator stopAnimation:nil];
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
            NSString *location = [NSString stringWithFormat:@"./Collection  s/%@/%@/%@", artist, album, [baseLoc lastPathComponent] ];
            NSString *songM3ULine = [NSString stringWithFormat:@"#EXTINF:%d,%@ - %@\n%@", [songID intValue], songTitle, artist, location];
            playlistString = [playlistString stringByAppendingString:songM3ULine];
            playlistString = [playlistString stringByAppendingString:@"\n"];
            if (![requiredSongs containsObject:songID]) {
                [requiredSongs addObject:songID];
            }
        }
        NSString *playlistFile = [NSString stringWithFormat:@"%@%@.m3u", playlistFolder, [playlist objectForKey:@"Name"]];
        [[NSFileManager defaultManager] createFileAtPath:playlistFile contents:[playlistString dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        
        
        //        Update progress bar.
        
    }
    
    
    [self.statusText setStringValue:@"Copying Song Files."];
    
    NSInteger songCount = [requiredSongs count];
    NSInteger i = 1;
    
    NSMutableArray *songPathsErrors = [NSMutableArray array];
    for (NSNumber *songID in requiredSongs) {
        [self.statusText setStringValue:[NSString stringWithFormat:@"Copying Song Files. %ld of %ld", i, songCount]];
        
        
        //    Look up song locations.
        //    Copy the music to the desired folder.
        //    Easy peasy.
        NSDictionary *song = [[itunesData objectForKey:@"Tracks"] objectForKey:[songID stringValue]];
        
        NSString *basicLocation = [[[song objectForKey:@"Location"] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"file://localhost" withString:@""];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:basicLocation]) {
            //Song Exists
            
//            NSLog(@"Source: %@", basicLocation);
            NSString *filename = [basicLocation lastPathComponent];
            
            NSString *artist = [song objectForKey:@"Artist"];
            NSString *album = [song objectForKey:@"Album"];
            
            [[NSFileManager defaultManager] createDirectoryAtPath:[NSString stringWithFormat:@"%@%@/%@/", musicFolder, artist, album] withIntermediateDirectories:YES attributes:nil error:nil];
            NSString *dest = [NSString stringWithFormat:@"%@%@/%@/%@", musicFolder, artist, album, filename];
//            NSLog(@"Dest: %@", dest);
            NSError *error;
            if (![[NSFileManager defaultManager] fileExistsAtPath:dest]) {
                [[NSFileManager defaultManager] copyItemAtPath:basicLocation toPath:dest error:&error];
                if (error) {
                    [song setValue:error.localizedDescription forKey:@"error"];
                }
            }
            else {
//                NSLog(@"FILE EXISTS;");
            }
            
        }
        else {
            //Song Doesn't Exist or isn't readable by us
            [song setValue:@"Could not load song" forKey:@"error"];
            [songPathsErrors addObject:song];
        }
        i++;
        
        
        
    }
    
    NSLog(@"Errors: %@", songPathsErrors);
    
    [self.statusText setStringValue:@"Export Complete"];
    [self.activityIndicator stopAnimation:nil];

}

-(NSInteger)nestedLevels:(NSDictionary *)playlist currentLevel:(NSInteger)level {
    if ([playlist objectForKey:@"Parent Persistent ID"]) {
        level ++;
        for (NSDictionary *parent in self.playlists) {
            if ([[parent objectForKey:@"Playlist Persistent ID"] isEqualToString:[playlist objectForKey:@"Parent Persistent ID"]]) {
                return [self nestedLevels:parent currentLevel:level];
            }
        }
        return level;
    }
    else {
        return level;
    }
}

-(BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(NSInteger)row {
    TPICheckboxTableCellView *cell = [tableView viewAtColumn:0 row:row makeIfNecessary:NO];
    [cell.checkbox setState:!cell.checkbox.state];
    
    [[self.playlists objectAtIndex:row] setValue:[NSNumber numberWithBool:cell
                                                  .checkbox.state] forKeyPath:@"isSelected"];
    
    return FALSE;
}

-(void)CellTickedWasChanged:(TPICheckboxTableCellView *)cell row:(NSInteger)row {

    [[self.playlists objectAtIndex:row] setValue:[NSNumber numberWithBool:cell.checkbox.state] forKeyPath:@"isSelected"];
}
- (IBAction)saveSelected:(id)sender {
    [self saveSelectedPlaylists];
}


@end
