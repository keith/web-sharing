//
//  KSAppDelegate.m
//  Web Sharing
//
//  Created by Keith Smiley on 7/31/12.
//  Copyright (c) 2012 Keith Smiley. All rights reserved.
//

#import "KSAppDelegate.h"

@implementation KSAppDelegate
@synthesize launchAtLoginItem;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    prefs = [NSUserDefaults standardUserDefaults];
    [prefs registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:NO, @"launchAtLogin", NO, @"stopWhenQuit", nil]];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"menuItem"]];
    [statusItem setHighlightMode:YES];
    [statusItem setAlternateImage:[NSImage imageNamed:@"menuItemHighlight"]];
    [statusItem setTarget:self];
    [statusItem setMenu:webSharingMenu];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
    if (!prefs) {
        prefs = [NSUserDefaults standardUserDefaults];
    }
    if ([prefs boolForKey:@"stopWhenQuit"]) {
        [self stopApache:nil];
    }
    [prefs synchronize];
}

- (IBAction)startApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl start\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to start"] runModal];
    }
}
- (IBAction)stopApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl stop\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to stop"] runModal];
    }
}
- (IBAction)restartApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl restart\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to restart"] runModal];
    }
}

- (IBAction)launchAtLoginCheckChanged:(id)sender {
    [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(loginCheck) userInfo:nil repeats:NO];
}

- (void)loginCheck {
    prefs = [NSUserDefaults standardUserDefaults];
    NSURL *pathURL = [[NSBundle mainBundle] bundleURL];
    if ([prefs boolForKey:@"launchAtLogin"]) {
        [MPLoginItems addLoginItemWithURL:pathURL];
    } else {
        [MPLoginItems removeLoginItemWithURL:pathURL];
    }
}


@end
