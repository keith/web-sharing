//
//  KSAppDelegate.h
//  Web Sharing
//
//  Created by Keith Smiley on 7/31/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MPLoginItems.h"

@interface KSAppDelegate : NSObject <NSApplicationDelegate, NSMenuDelegate> {
    NSStatusItem *statusItem;
    NSUserDefaults *prefs;
    IBOutlet NSMenu *webSharingMenu;
}
@property (weak) IBOutlet NSMenuItem *launchAtLoginItem;

- (IBAction)startApache:(id)sender;
- (IBAction)stopApache:(id)sender;
- (IBAction)restartApache:(id)sender;

- (IBAction)launchAtLoginCheckChanged:(id)sender;

@end
