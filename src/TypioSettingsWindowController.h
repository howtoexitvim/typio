#import <Cocoa/Cocoa.h>

FOUNDATION_EXPORT NSString *const TypioSettingsDidChangeNotification;
FOUNDATION_EXPORT NSString *const TypioCandidatePanelTypeDefaultsKey;

@interface TypioSettingsWindowController : NSWindowController

+ (instancetype)sharedController;
- (void)showSettingsWindow;

@end
