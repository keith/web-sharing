//
//  KSAppDelegate.m
//  Web Sharing
//
//  Created by Keith Smiley on 7/31/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import "KSAppDelegate.h"
#import "KSConstants.h"

@implementation KSAppDelegate
@synthesize launchAtLoginItem;
@synthesize startItem;
@synthesize stopItem;
@synthesize restartItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    [self setLastRan:nil];
    prefs = [NSUserDefaults standardUserDefaults];
    NSDictionary *prefsPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Prefs" ofType:@"plist"]];
    [prefs registerDefaults:prefsPlist];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"menuItem"]];
    [statusItem setHighlightMode:YES];
    [statusItem setAlternateImage:[NSImage imageNamed:@"menuItemHighlight"]];
    [statusItem setTarget:self];
    [statusItem setMenu:webSharingMenu];
    
    if ([prefs boolForKey:START_SERVER_ON_LAUNCH]) {
        [self startApache:nil];
    }
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    if (!prefs) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    if ([prefs boolForKey:STOP_SERVER_ON_QUIT]) {
        [self stopApache:nil];
    }
    [prefs synchronize];
}

- (IBAction)startApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl start\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to start or you did not enter your administrator password"] runModal];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [self setLastRan:@"Start"];
    }
}
- (IBAction)stopApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl stop\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to stop or you did not enter your administrator password"] runModal];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [self setLastRan:@"Stop"];
    }
}
- (IBAction)restartApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl restart\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to restart or you did not enter your administrator password"] runModal];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [self setLastRan:@"Restart"];
    }
}

- (void)setLastRan:(NSString *)caller {
    [startItem setState:NSOffState];
    [stopItem setState:NSOffState];
    [restartItem setState:NSOffState];
    if ([caller isEqualToString:@"Start"]) {
        [startItem setState:NSOnState];
    } else if ([caller isEqualToString:@"Stop"]) {
        [stopItem setState:NSOnState];
    } else if ([caller isEqualToString:@"Restart"]) {
        [restartItem setState:NSOnState];
    }
}

- (IBAction)launchAtLoginCheckChanged:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(loginCheck) userInfo:nil repeats:NO];
}

- (void)loginCheck {
    prefs = [NSUserDefaults standardUserDefaults];
    NSURL *pathURL = [[NSBundle mainBundle] bundleURL];
    if ([prefs boolForKey:LAUNCH_AT_LOGIN]) {
        if (![MPLoginItems loginItemExists:pathURL]) {
            [MPLoginItems addLoginItemWithURL:pathURL];
        }
    } else {
        if ([MPLoginItems loginItemExists:pathURL]) {
            [MPLoginItems removeLoginItemWithURL:pathURL];
        }
    }
}


@end
