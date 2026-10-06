#import "TypioSettingsWindowController.h"

#import <InputMethodKit/InputMethodKit.h>

NSString *const TypioSettingsDidChangeNotification = @"TypioSettingsDidChangeNotification";
NSString *const TypioCandidatePanelTypeDefaultsKey = @"candidatePanelType";

@interface TypioSettingsWindowController ()

@property(nonatomic, strong) NSPopUpButton *panelTypePopup;

@end

@implementation TypioSettingsWindowController

+ (instancetype)sharedController {
    static TypioSettingsWindowController *controller = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
      controller = [[self alloc] initPrivate];
    });
    return controller;
}

- (instancetype)initPrivate {
    NSRect frame = NSMakeRect(0, 0, 640, 220);
    NSWindow *window = [[NSWindow alloc]
        initWithContentRect:frame
                                    styleMask:(NSWindowStyleMaskTitled | NSWindowStyleMaskClosable | NSWindowStyleMaskMiniaturizable)
                    backing:NSBackingStoreBuffered
                      defer:NO];
    self = [super initWithWindow:window];
    if (self) {
        [self setupWindow];
        [self buildUI];
        [self loadFromDefaults];
    }
    return self;
}

- (instancetype)initWithWindow:(NSWindow *)window {
    return [self initPrivate];
}

- (void)setupWindow {
    self.window.title = @"Typio Settings";
    self.window.releasedWhenClosed = NO;
    self.window.minSize = NSMakeSize(640, 220);
    self.window.maxSize = NSMakeSize(640, 220);
}

- (NSTextField *)labelWithText:(NSString *)text frame:(NSRect)frame {
    NSTextField *label = [[NSTextField alloc] initWithFrame:frame];
    label.stringValue = text;
    label.bezeled = NO;
    label.drawsBackground = NO;
    label.editable = NO;
    label.selectable = NO;
    label.font = [NSFont systemFontOfSize:13 weight:NSFontWeightSemibold];
    return label;
}

- (void)buildUI {
    NSView *contentView = self.window.contentView;

    NSTextField *panelTypeLabel = [self labelWithText:@"Candidate Panel Style" frame:NSZeroRect];
    panelTypeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [contentView addSubview:panelTypeLabel];

    self.panelTypePopup = [[NSPopUpButton alloc] initWithFrame:NSZeroRect pullsDown:NO];
    self.panelTypePopup.translatesAutoresizingMaskIntoConstraints = NO;
    [self.panelTypePopup addItemWithTitle:@"Horizontal Row (Stepper)"];
    self.panelTypePopup.lastItem.tag = kIMKSingleRowSteppingCandidatePanel;
    [self.panelTypePopup addItemWithTitle:@"Grid (Multi-row)"];
    self.panelTypePopup.lastItem.tag = kIMKScrollingGridCandidatePanel;
    [self.panelTypePopup addItemWithTitle:@"Vertical Column"];
    self.panelTypePopup.lastItem.tag = kIMKSingleColumnScrollingCandidatePanel;
    [contentView addSubview:self.panelTypePopup];

    NSButton *cancelButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
    cancelButton.title = @"Cancel";
    cancelButton.bezelStyle = NSBezelStyleRounded;
    cancelButton.target = self;
    cancelButton.action = @selector(cancelAction:);
    [contentView addSubview:cancelButton];

    NSButton *saveButton = [[NSButton alloc] initWithFrame:NSZeroRect];
    saveButton.translatesAutoresizingMaskIntoConstraints = NO;
    saveButton.title = @"Save";
    saveButton.bezelStyle = NSBezelStyleRounded;
    saveButton.target = self;
    saveButton.action = @selector(saveAction:);
    [contentView addSubview:saveButton];

    [NSLayoutConstraint activateConstraints:@[
        [panelTypeLabel.leadingAnchor constraintEqualToAnchor:contentView.leadingAnchor constant:32.0],
        [panelTypeLabel.topAnchor constraintEqualToAnchor:contentView.topAnchor constant:56.0],

        [self.panelTypePopup.firstBaselineAnchor constraintEqualToAnchor:panelTypeLabel.firstBaselineAnchor],
        [self.panelTypePopup.leadingAnchor constraintGreaterThanOrEqualToAnchor:panelTypeLabel.trailingAnchor constant:16.0],
        [self.panelTypePopup.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-32.0],
        [self.panelTypePopup.widthAnchor constraintGreaterThanOrEqualToConstant:260.0],

        [saveButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24.0],
        [saveButton.trailingAnchor constraintEqualToAnchor:contentView.trailingAnchor constant:-32.0],

        [cancelButton.firstBaselineAnchor constraintEqualToAnchor:saveButton.firstBaselineAnchor],
        [cancelButton.trailingAnchor constraintEqualToAnchor:saveButton.leadingAnchor constant:-8.0],
        [cancelButton.bottomAnchor constraintEqualToAnchor:contentView.bottomAnchor constant:-24.0]
    ]];
}

- (void)loadFromDefaults {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    NSInteger panelType = [defaults integerForKey:TypioCandidatePanelTypeDefaultsKey];
    if (panelType < kIMKSingleColumnScrollingCandidatePanel || panelType > kIMKSingleRowSteppingCandidatePanel) {
        panelType = kIMKSingleRowSteppingCandidatePanel;
    }

    [self.panelTypePopup selectItemWithTag:panelType];
}

- (void)showSettingsWindow {
    dispatch_async(dispatch_get_main_queue(), ^{
            [self loadFromDefaults];
            [self.window center];
            [NSApp activateIgnoringOtherApps:YES];
            [self.window makeKeyAndOrderFront:nil];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(50 * NSEC_PER_MSEC)), dispatch_get_main_queue(), ^{
                [self.window makeFirstResponder:self.panelTypePopup];
            });
        });
}

- (void)cancelAction:(id)sender {
    [self close];
}

- (void)saveAction:(id)sender {
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;

    NSInteger panelType = self.panelTypePopup.selectedTag;
    if (panelType < kIMKSingleColumnScrollingCandidatePanel || panelType > kIMKSingleRowSteppingCandidatePanel) {
        panelType = kIMKSingleRowSteppingCandidatePanel;
    }
    [defaults setInteger:panelType forKey:TypioCandidatePanelTypeDefaultsKey];

    [NSNotificationCenter.defaultCenter postNotificationName:TypioSettingsDidChangeNotification object:nil];
    [self close];
}

@end
