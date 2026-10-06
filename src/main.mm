#import "ConversionEngine.h"
#import "TypioSettingsWindowController.h"
#import <Carbon/Carbon.h>
#import <Cocoa/Cocoa.h>
#import <InputMethodKit/InputMethodKit.h>

NSUserDefaults *preference;
ConversionEngine *engine;

const NSString *kConnectionName = @"Typio_1_Connection";
IMKCandidates *sharedCandidates;

static const unsigned char kInstallLocation[] = "/Library/Input Methods/Typio.app";
static NSString *const kSourceID = @"top.shuqihere.inputmethod.typio";

bool registerInputSource() {
    CFURLRef installedLocationURL =
        CFURLCreateFromFileSystemRepresentation(NULL, kInstallLocation, strlen((const char *)kInstallLocation), NO);
    if (!installedLocationURL) {
        return false;
    }
    OSStatus status = TISRegisterInputSource(installedLocationURL);
    CFRelease(installedLocationURL);
    NSLog(@"Register input source from %s: %d", kInstallLocation, (int)status);
    return status == noErr;
}

static bool enableInputSource(NSString *sourceID, bool select) {
    NSDictionary *filter = @{(__bridge NSString *)kTISPropertyInputSourceID : sourceID};
    CFArrayRef sources = TISCreateInputSourceList((__bridge CFDictionaryRef)filter, true);
    if (!sources || CFArrayGetCount(sources) == 0) {
        if (sources) CFRelease(sources);
        NSLog(@"Input source not found: %@", sourceID);
        return false;
    }

    TISInputSourceRef source = (TISInputSourceRef)CFArrayGetValueAtIndex(sources, 0);
    OSStatus status = TISEnableInputSource(source);
    NSLog(@"Enable input source %@: %d", sourceID, (int)status);
    if (status == noErr && select) {
        status = TISSelectInputSource(source);
        NSLog(@"Select input source %@: %d", sourceID, (int)status);
    }
    CFRelease(sources);
    return status == noErr;
}

bool activateInputSource() {
    return enableInputSource(kSourceID, true);
}

void initPreference() {
    preference = [NSUserDefaults standardUserDefaults];
    NSDictionary *defaultPrefs = @{@"commitWordWithSpace" : @YES,
                                   TypioCandidatePanelTypeDefaultsKey : @(kIMKSingleRowSteppingCandidatePanel)};
    [preference registerDefaults:defaultPrefs];
}

int main(int argc, char *argv[]) {
    if (argc > 1 && !strcmp("--install", argv[1])) {
        if (!registerInputSource() || !activateInputSource()) {
            NSLog(@"Add Typio in System Settings > Keyboard > Input Sources, then select it again.");
            return 1;
        }
        return 0;
    }

    initPreference();

    NSString *identifier = [NSBundle mainBundle].bundleIdentifier;
    IMKServer *server = [[IMKServer alloc] initWithName:(NSString *)kConnectionName bundleIdentifier:identifier];

    NSInteger panelType = [preference integerForKey:TypioCandidatePanelTypeDefaultsKey];
    if (panelType < kIMKSingleColumnScrollingCandidatePanel || panelType > kIMKSingleRowSteppingCandidatePanel) {
        panelType = kIMKSingleRowSteppingCandidatePanel;
    }

    sharedCandidates = [[IMKCandidates alloc] initWithServer:server panelType:panelType];
    [sharedCandidates setAttributes:@{IMKCandidatesSendServerKeyEventFirst : @YES}];

    if (!sharedCandidates) {
        NSLog(@"Fatal error: Cannot initialize shared candidate panel with connection %@.", kConnectionName);
        return -1;
    }

    engine = [ConversionEngine sharedEngine];



    [[NSBundle mainBundle] loadNibNamed:@"PreferencesMenu" owner:[NSApplication sharedApplication] topLevelObjects:nil];

    [[NSApplication sharedApplication] run];
    return 0;
}
