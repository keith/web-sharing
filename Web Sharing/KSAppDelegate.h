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
    IBOutlet NSMenu *webSharingMenu;
}

@property (weak) IBOutlet NSMenuItem *startItem;
@property (weak) IBOutlet NSMenuItem *stopItem;
@property (weak) IBOutlet NSMenuItem *restartItem;
@property (weak) IBOutlet NSMenuItem *loginItem;

@end
