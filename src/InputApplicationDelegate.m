#import "InputApplicationDelegate.h"

@implementation InputApplicationDelegate

- (NSMenu *)menu {
    return _menu;
}

- (void)awakeFromNib {
    NSMenuItem *preferenceMenuItem = [_menu itemWithTitle:@"Preferences"];
    NSMenuItem *sponsorMenuItem = [_menu itemWithTitle:@"Sponsor"];
    NSMenuItem *aboutMenuItem = [_menu itemWithTitle:@"About"];

    if (preferenceMenuItem) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        preferenceMenuItem.action = @selector(showIMEPreferences:);
#pragma clang diagnostic pop
    }

    if (aboutMenuItem) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        aboutMenuItem.action = @selector(clickAbout:);
#pragma clang diagnostic pop
    }

    if (sponsorMenuItem) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
        sponsorMenuItem.action = @selector(clickSponsor:);
#pragma clang diagnostic pop
    }
}

@end
