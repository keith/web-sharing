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

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    [self setLastRan:nil];
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    NSDictionary *prefsPlist = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Prefs" ofType:@"plist"]];
    [prefs registerDefaults:prefsPlist];
    [[NSUserDefaults standardUserDefaults] setBool:[MPLoginItems loginItemExists:bundleURL] forKey:LAUNCH_AT_LOGIN];
    
    statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    [statusItem setImage:[NSImage imageNamed:@"menuItem"]];
    [statusItem setHighlightMode:YES];
    [statusItem setAlternateImage:[NSImage imageNamed:@"menuItemHighlight"]];
    [statusItem setTarget:self];
    [statusItem setMenu:webSharingMenu];
    
    if ([prefs boolForKey:START_SERVER_ON_LAUNCH]) {
        [self startApache:nil];
    }

    if ([prefs boolForKey:IS_FIRST_LAUNCH]) {
        [self configure:nil];
    }
    
    [prefs synchronize];
}

- (void)applicationWillTerminate:(NSNotification *)notification {
    if ([[NSUserDefaults standardUserDefaults] boolForKey:STOP_SERVER_ON_QUIT]) {
        [self stopApache:nil];
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

#pragma mark - Apache methods

- (IBAction)configure:(id)sender
{
    NSFileManager *fm = [NSFileManager defaultManager];
    NSString *userConfPath = [NSString stringWithFormat:@"%@%@.conf", USER_CONF_PATH, NSUserName()];
    NSString *sitesFilePath = [NSString stringWithFormat:@"/Users/%@/Sites/", NSUserName()];
    BOOL confExists = [fm fileExistsAtPath:userConfPath];
    if (!confExists) {
        [NSApp activateIgnoringOtherApps:YES];
        NSAlert *alert = [NSAlert alertWithMessageText:@"User configuration not found"
                                         defaultButton:@"Yes"
                                       alternateButton:@"No"
                                           otherButton:nil
                             informativeTextWithFormat:@"Your configuration file for your user's apache server does not exist in %@ would you like to create one now?", userConfPath];
        NSInteger returnCode = [alert runModal];
        if (returnCode == NSAlertDefaultReturn) {
            NSString *apacheConfFile = [NSString stringWithFormat:@"\\\"<Directory '%@'>\n\tOptions Indexes MultiViews\n\tAllowOverride All\n\tOrder allow,deny\n\tAllow from all\n</Directory>\\\"", sitesFilePath];
            
            NSString *script = [NSString stringWithFormat:@"do shell script \"echo %@ > %@\" with administrator privileges", apacheConfFile, userConfPath];
            
            NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
            NSDictionary *error = [NSDictionary new];
            [appleScript executeAndReturnError:&error];
            
            if (![fm fileExistsAtPath:userConfPath]) {
                NSInteger responseCode = [[NSAlert alertWithMessageText:@"Web Sharing"
                                                          defaultButton:@"Yes"
                                                        alternateButton:@"No"
                                                            otherButton:nil
                                              informativeTextWithFormat:@"Failed to create your %@ file. Would you like to copy the contents to your pasteboard so you can create the file?", userConfPath] runModal];
                
                if (responseCode == NSAlertDefaultReturn) {
                    NSPasteboard *pb = [NSPasteboard generalPasteboard];
                    [pb clearContents];
                    [pb setValue:apacheConfFile];
                }
                
                NSLog(@"Config file creation error %@", error);
            }
        }
    }
    
    BOOL isDirectory = TRUE;
    BOOL sitesFolderExists = [fm fileExistsAtPath:sitesFilePath isDirectory:&isDirectory];
    if (!sitesFolderExists) {
        [NSApp activateIgnoringOtherApps:YES];
        NSInteger response = [[NSAlert alertWithMessageText:@"Web Sharing"
                                              defaultButton:@"Yes"
                                            alternateButton:@"No"
                                                otherButton:nil
                                  informativeTextWithFormat:@"Your ~/Sites folder, which is needed for hosting local websites doesn't exist. Would you like to create one now?"] runModal];
        
        if (response == NSAlertDefaultReturn) {
            NSString *script = [NSString stringWithFormat:@"do shell script \"mkdir ~/Sites\" with administrator privileges"];
            
            NSAppleScript *appleScript = [[NSAppleScript alloc] initWithSource:script];
            NSDictionary *error = [NSDictionary new];
            [appleScript executeAndReturnError:&error];
            if (![fm fileExistsAtPath:sitesFilePath isDirectory:&isDirectory]) {
                [[NSAlert alertWithMessageText:@"Web Sharing"
                                 defaultButton:nil
                               alternateButton:nil
                                   otherButton:nil
                     informativeTextWithFormat:@"Failed to create your ~/Sites folder. You can do this yourself through Finder or by running `mkdir ~/Sites` in terminal"] runModal];
                
                NSLog(@"Sites folder creation error %@", error);
            }
        }
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:IS_FIRST_LAUNCH];
}

- (IBAction)startApache:(id)sender {
    NSDictionary *error = [NSDictionary new];
    NSString *script =  @"do shell script \"apachectl -k start\" with administrator privileges";
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
    NSString *script =  @"do shell script \"apachectl -k stop\" with administrator privileges";
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
    NSString *script =  @"do shell script \"apachectl -k restart\" with administrator privileges";
    NSAppleScript *appleScript = [[NSAppleScript new] initWithSource:script];
    if (![appleScript executeAndReturnError:&error]) {
        [[NSAlert alertWithMessageText:@"Apache Error" defaultButton:NSLocalizedString(@"OK", @"Ok button") alternateButton:nil otherButton:nil informativeTextWithFormat:@"Apache failed to restart or you did not enter your administrator password"] runModal];
        [NSApp activateIgnoringOtherApps:YES];
    } else {
        [self setLastRan:@"Restart"];
    }
}

#pragma mark - Helpers

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
    NSURL *bundleURL = [[NSBundle mainBundle] bundleURL];
    if (self.loginItem.state == NSOnState) {
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [MPLoginItems removeLoginItemWithURL:bundleURL];
        }
        
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [NSApp activateIgnoringOtherApps:YES];
            [[NSAlert alertWithMessageText:@"Web Sharing"
                             defaultButton:nil
                           alternateButton:nil
                               otherButton:nil
                 informativeTextWithFormat:@"Failed to remove Web Sharing from your login items. You can remove it manually in System Preferences -> Users & Groups -> Login Items"] runModal];
        } else {
            [self.loginItem setState:NSOffState];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:LAUNCH_AT_LOGIN];
        }
    } else {
        if (![MPLoginItems loginItemExists:bundleURL]) {
            [MPLoginItems addLoginItemWithURL:bundleURL];
        }
        
        if ([MPLoginItems loginItemExists:bundleURL]) {
            [self.loginItem setState:NSOnState];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:LAUNCH_AT_LOGIN];
        } else {
            [NSApp activateIgnoringOtherApps:YES];
            [[NSAlert alertWithMessageText:@"Github Status"
                             defaultButton:nil
                           alternateButton:nil
                               otherButton:nil
                 informativeTextWithFormat:@"Failed to add Web Sharing from your login items. You can add it manually in System Preferences -> Users & Groups -> Login Items"] runModal];
        }
    }
    
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)showAbout:(id)sender {
    [NSApp orderFrontStandardAboutPanel:sender];
    [NSApp activateIgnoringOtherApps:YES];
}

@end
