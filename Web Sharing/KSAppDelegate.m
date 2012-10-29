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
    [prefs setBool:YES forKey:IS_FIRST_LAUNCH];
    if ([prefs boolForKey:IS_FIRST_LAUNCH]) {
        NSFileManager *fm = [NSFileManager defaultManager];
        NSString *userConfPath = [NSString stringWithFormat:@"%@%@.conf", USER_CONF_PATH, NSUserName()];
        NSString *sitesFilePath = [NSString stringWithFormat:@"/Users/%@/Sites/", NSUserName()];
        BOOL confExists = [fm fileExistsAtPath:userConfPath];
        if (!confExists) {
            NSAlert *alert = [NSAlert alertWithMessageText:@"User configuration not found" defaultButton:@"Yes" alternateButton:@"No" otherButton:nil informativeTextWithFormat:@"Your configuration file for your user's apache server does not exist in %@ would you like me to create one now?", userConfPath];
            NSInteger returnCode = [alert runModal];
            if (returnCode == NSAlertDefaultReturn) {
                NSString *apacheConfFile = [NSString stringWithFormat:@"\\\"<Directory '%@'>\n\tOptions Indexes MultiViews\n\tAllowOverride All\n\tOrder allow,deny\n\tAllow from all\n</Directory>\\\"", sitesFilePath];
                
                NSString *script = [NSString stringWithFormat:@"do shell script \"echo %@ > %@\" with administrator privileges", apacheConfFile, userConfPath];
                NSLog(@"%@", script);

                NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
                NSDictionary *error = [NSDictionary new];
                if ([appleScript executeAndReturnError:&error]) {
                    NSLog(@"worked");
                } else {
                    NSLog(@"didnt work %@", error);
                }
            } else {
                NSLog(@"Dont Create");
            }
        }
        
        BOOL isDirectory = TRUE;
        BOOL sitesFolderExists = [fm fileExistsAtPath:sitesFilePath isDirectory:&isDirectory];
        if (!sitesFolderExists) {
            NSLog(@"need to create sites folder");
            NSString *script = [NSString stringWithFormat:@"do shell script \"mkdir ~/Sites\" with administrator privileges"];
            
            NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
            NSDictionary *error = [NSDictionary new];
            if ([appleScript executeAndReturnError:&error]) {
                NSLog(@"worked mkdir sites");
            } else {
                NSLog(@"failed to make dir sites");
            }
        } else {
            NSLog(@"sites folder exists");
        }
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

- (IBAction)showAbout:(id)sender {
    [NSApp orderFrontStandardAboutPanel:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
