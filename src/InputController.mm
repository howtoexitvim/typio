#import <CoreServices/CoreServices.h>

#import "InputApplicationDelegate.h"
#import "InputController.h"
#import "NSScreen+PointConversion.h"
#import "TypioSettingsWindowController.h"

extern IMKCandidates *sharedCandidates;
extern NSUserDefaults *preference;
extern ConversionEngine *engine;

typedef NSInteger KeyCode;
static const KeyCode KEY_RETURN = 36, KEY_TAB = 48, KEY_SPACE = 49, KEY_DELETE = 51, KEY_ESC = 53, KEY_ARROW_LEFT = 123, KEY_ARROW_RIGHT = 124, KEY_ARROW_DOWN = 125, KEY_ARROW_UP = 126, KEY_RIGHT_SHIFT = 60;

@interface InputController()

- (void)showIMEPreferences:(id)sender;
- (void)clickAbout:(NSMenuItem *)sender;
- (void)clickSponsor:(NSMenuItem *)sender;
- (void)clearMarkedTextForClient:(id)client;
- (void)applyCandidatePanelPreference;
- (void)handleSettingsDidChange:(NSNotification *)notification;

@end

@implementation InputController

- (instancetype)initWithServer:(IMKServer *)server delegate:(id)delegate client:(id)inputClient {
    self = [super initWithServer:server delegate:delegate client:inputClient];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleSettingsDidChange:)
                                                     name:TypioSettingsDidChangeNotification
                                                   object:nil];
        [self applyCandidatePanelPreference];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:TypioSettingsDidChangeNotification object:nil];
}

- (NSUInteger)recognizedEvents:(id)sender {
    return NSEventMaskKeyDown | NSEventMaskFlagsChanged;
}

- (BOOL)handleEvent:(NSEvent *)event client:(id)sender {
    NSUInteger modifiers = event.modifierFlags;
    bool handled = NO;

    if (event.type == NSEventTypeKeyDown && event.keyCode == KEY_ESC) {
        NSString *bufferedText = [self originalBuffer];
        NSString *composedText = [self composedBuffer];
        if ((bufferedText && bufferedText.length > 0) || (composedText && composedText.length > 0) || [sharedCandidates isVisible]) {
            [self cancelComposition];
            [self clearMarkedTextForClient:sender ?: _currentClient];
            [self reset];
            return YES;
        }
    }

    switch (event.type) {
    case NSEventTypeFlagsChanged:
        // NSLog(@"typio event modifierFlags %lu, event keyCode: %@", (unsigned long)[event modifierFlags], [event keyCode]);

        if (_lastEventTypes[1] == NSEventTypeFlagsChanged && _lastModifiers[1] == modifiers) {
            return YES;
        }

        if (modifiers == 0 && _lastEventTypes[1] == NSEventTypeFlagsChanged && _lastModifiers[1] == NSEventModifierFlagShift &&
            event.keyCode == KEY_RIGHT_SHIFT && !(_lastModifiers[0] & NSEventModifierFlagShift)) {

            _defaultEnglishMode = !_defaultEnglishMode;
            if (_defaultEnglishMode) {
                NSString *bufferedText = [self originalBuffer];
                if (bufferedText && bufferedText.length > 0) {
                    [self cancelComposition];
                    [self commitComposition:sender];
                }
            }
        }
        break;
    case NSEventTypeKeyDown:
        if (_defaultEnglishMode) {
            break;
        }

        if (modifiers & NSEventModifierFlagCommand) {
            return NO; // let system/global shortcuts (Cmd+A/C/V/Z/…) pass through
        }

        if (modifiers & NSEventModifierFlagOption) {
            return false;
        }

        if (modifiers & NSEventModifierFlagControl) {
            return false;
        }

        handled = [self onKeyEvent:event client:sender];
        break;
    default:
        break;
    }

    _lastModifiers[0] = _lastModifiers[1];
    _lastEventTypes[0] = _lastEventTypes[1];
    _lastModifiers[1] = modifiers;
    _lastEventTypes[1] = event.type;
    return handled;
}

- (BOOL)onKeyEvent:(NSEvent *)event client:(id)sender {
    _currentClient = sender;
    NSInteger keyCode = event.keyCode;
    NSString *characters = event.characters;

    if (characters == nil || characters.length == 0) {
        return NO;
    }

    NSString *bufferedText = [self originalBuffer];
    bool hasBufferedText = bufferedText && bufferedText.length > 0;

    if (keyCode == KEY_DELETE) {
        if (hasBufferedText) {
            return [self deleteBackward:sender];
        }

        return NO;
    }

    if (keyCode == KEY_SPACE) {
        if (hasBufferedText) {
            [self commitComposition:sender];
            return YES;
        }
        return NO;
    }

    if (keyCode == KEY_RETURN) {
        if (hasBufferedText) {
            [self commitCompositionWithoutSpace:sender];
            return YES;
        }
        return NO;
    }

    if (keyCode == KEY_TAB) {
        if (!hasBufferedText) {
            return NO;
        }
        return YES;
    }

    if (keyCode == KEY_ESC) {
        [self cancelComposition];
        [self clearMarkedTextForClient:sender ?: _currentClient];
        [self reset];
        return YES;
    }

    char ch = [characters characterAtIndex:0];
    if ((ch >= 'a' && ch <= 'z') || (ch >= 'A' && ch <= 'Z')) {
        [self originalBufferAppend:characters client:sender];

        [sharedCandidates updateCandidates];
        [sharedCandidates show:kIMKLocateCandidatesBelowHint];
        return YES;
    }

    if ([self isMojaveAndLaterSystem]) {
        BOOL isCandidatesVisible = [sharedCandidates isVisible];
        if (isCandidatesVisible) {
            if (keyCode == KEY_ARROW_DOWN) {
                [sharedCandidates moveDown:self];
                _currentCandidateIndex++;
                return NO;
            }

            if (keyCode == KEY_ARROW_UP) {
                [sharedCandidates moveUp:self];
                _currentCandidateIndex--;
                return NO;
            }

            if (keyCode == KEY_ARROW_RIGHT) {
                [sharedCandidates moveRight:self];
                _currentCandidateIndex++;
                return YES;
            }

            if (keyCode == KEY_ARROW_LEFT) {
                [sharedCandidates moveLeft:self];
                if (_currentCandidateIndex > 0) {
                    _currentCandidateIndex--;
                }
                return YES;
            }
        }

        if ([[NSCharacterSet decimalDigitCharacterSet] characterIsMember:ch]) {
            if (!hasBufferedText) {
                [self appendToComposedBuffer:characters];
                [self commitCompositionWithoutSpace:sender];
                return YES;
            }

            if (isCandidatesVisible) { // use 1~9 digital numbers as selection keys
                int pressedNumber = characters.intValue;
                if (pressedNumber < 1 || pressedNumber > 9) {
                    return NO;
                }
                int pageSize = 9;
                NSInteger selectedIndex = pressedNumber - 1;
                if (_currentCandidateIndex <= pageSize) {
                    selectedIndex = pressedNumber - 1;
                } else {
                    selectedIndex = pageSize * (_currentCandidateIndex / pageSize - 1) + (_currentCandidateIndex % pageSize) + pressedNumber - 1;
                }

                if (selectedIndex < 0 || selectedIndex >= _candidates.count) {
                    return NO;
                }

                NSString *candidate = _candidates[selectedIndex];
                [self cancelComposition];
                [self setComposedBuffer:candidate];
                [self setOriginalBuffer:candidate];
                [self commitComposition:sender];
                return YES;
            }
        }
    }

    if ([[NSCharacterSet punctuationCharacterSet] characterIsMember:ch] || [[NSCharacterSet symbolCharacterSet] characterIsMember:ch]) {
        if (hasBufferedText) {
            [self appendToComposedBuffer:characters];
            [self commitCompositionWithoutSpace:sender];
            return YES;
        }
    }

    return NO;
}

- (BOOL)isMojaveAndLaterSystem {
    NSOperatingSystemVersion version = [NSProcessInfo processInfo].operatingSystemVersion;
    return (version.majorVersion == 10 && version.minorVersion > 13) || version.majorVersion > 10;
}

- (BOOL)deleteBackward:(id)sender {
    NSMutableString *originalText = [self originalBuffer];

    if (_insertionIndex > 0) {
        --_insertionIndex;

        NSString *convertedString = [originalText substringToIndex:originalText.length - 1];

        [self setComposedBuffer:convertedString];
        [self setOriginalBuffer:convertedString];

        [self showPreeditString:convertedString];

        if (convertedString && convertedString.length > 0) {
            [sharedCandidates updateCandidates];
            [sharedCandidates show:kIMKLocateCandidatesBelowHint];
        } else {
            [self reset];
        }
        return YES;
    }
    return NO;
}

- (void)commitComposition:(id)sender {
    NSString *text = [self composedBuffer];

    if (text == nil || text.length == 0) {
        text = [self originalBuffer];
    }
    BOOL commitWordWithSpace = [preference boolForKey:@"commitWordWithSpace"];

    if (commitWordWithSpace && text.length > 0) {
        char firstChar = [text characterAtIndex:0];
        char lastChar = [text characterAtIndex:text.length - 1];
        if (![[NSCharacterSet decimalDigitCharacterSet] characterIsMember:firstChar] && lastChar != '\'') {
            text = [NSString stringWithFormat:@"%@ ", text];
        }
    }

    [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    [self reset];
}

- (void)commitCompositionWithoutSpace:(id)sender {
    NSString *text = [self composedBuffer];

    if (text == nil || text.length == 0) {
        text = [self originalBuffer];
    }

    [sender insertText:text replacementRange:NSMakeRange(NSNotFound, NSNotFound)];

    [self reset];
}

- (void)reset {
    [self setComposedBuffer:@""];
    [self setOriginalBuffer:@""];
    _insertionIndex = 0;
    _currentCandidateIndex = 1;
    [sharedCandidates clearSelection];
    [sharedCandidates hide];
    _candidates = [[NSMutableArray alloc] init];
    [sharedCandidates setCandidateData:@[]];
}

- (NSMutableString *)composedBuffer {
    if (_composedBuffer == nil) {
        _composedBuffer = [[NSMutableString alloc] init];
    }
    return _composedBuffer;
}

- (void)setComposedBuffer:(NSString *)string {
    NSMutableString *buffer = [self composedBuffer];
    [buffer setString:string];
}

- (NSMutableString *)originalBuffer {
    if (_originalBuffer == nil) {
        _originalBuffer = [[NSMutableString alloc] init];
    }
    return _originalBuffer;
}

- (void)setOriginalBuffer:(NSString *)input {
    NSMutableString *buffer = [self originalBuffer];
    [buffer setString:input];
}

- (void)showPreeditString:(NSString *)input {
    if (input == nil) {
        return;
    }

    NSDictionary *attrs = [self markForStyle:kTSMHiliteSelectedRawText atRange:NSMakeRange(0, input.length)];
    NSAttributedString *attrString;

    NSString *originalBuff = [NSString stringWithString:[self originalBuffer]];
    if ([input.lowercaseString hasPrefix:originalBuff.lowercaseString] && originalBuff.length <= input.length) {
        attrString = [[NSAttributedString alloc]
            initWithString:[NSString stringWithFormat:@"%@%@", originalBuff, [input substringFromIndex:originalBuff.length]]
                attributes:attrs];
    } else {
        attrString = [[NSAttributedString alloc] initWithString:input attributes:attrs];
    }

    [_currentClient setMarkedText:attrString
                   selectionRange:NSMakeRange(input.length, 0)
                 replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
}

- (void)originalBufferAppend:(NSString *)input client:(id)sender {
    NSMutableString *buffer = [self originalBuffer];
    [buffer appendString:input];
    _insertionIndex++;
    [self showPreeditString:buffer];
}

- (void)appendToComposedBuffer:(NSString *)input {
    NSMutableString *buffer = [self composedBuffer];
    [buffer appendString:input];
}

- (NSArray *)candidates:(id)sender {
    NSString *originalInput = [self originalBuffer];
    NSArray *candidateList = [engine getCandidates:originalInput];
    _candidates = [NSMutableArray arrayWithArray:candidateList];
    return _candidates;
}

- (void)candidateSelectionChanged:(NSAttributedString *)candidateString {
    if (candidateString == nil || candidateString.string == nil) {
        return;
    }

    [self _updateComposedBuffer:candidateString];

    [self showPreeditString:candidateString.string];

    _insertionIndex = candidateString.length;
}

- (void)candidateSelected:(NSAttributedString *)candidateString {
    if (candidateString == nil || candidateString.string == nil) {
        return;
    }

    [self _updateComposedBuffer:candidateString];

    [self commitComposition:_currentClient];
}

- (void)_updateComposedBuffer:(NSAttributedString *)candidateString {
    if (candidateString == nil || candidateString.string == nil) {
        return;
    }
    [self setComposedBuffer:candidateString.string];
    [self setOriginalBuffer:candidateString.string];
}

- (void)activateServer:(id)sender {
    [sender overrideKeyboardWithKeyboardNamed:@"com.apple.keylayout.US"];

    _currentCandidateIndex = 1;
    _candidates = [[NSMutableArray alloc] init];
    [self applyCandidatePanelPreference];
}

- (void)deactivateServer:(id)sender {
    [self clearMarkedTextForClient:sender ?: _currentClient];
    [self reset];
}

- (void)clearMarkedTextForClient:(id)client {
    if (!client) {
        return;
    }

    if ([client respondsToSelector:@selector(unmarkText)]) {
        [client unmarkText];
    }

    if ([client respondsToSelector:@selector(setMarkedText:selectionRange:replacementRange:)]) {
        NSAttributedString *empty = [[NSAttributedString alloc] initWithString:@""];
        [client setMarkedText:empty selectionRange:NSMakeRange(0, 0) replacementRange:NSMakeRange(NSNotFound, NSNotFound)];
    }
}

- (NSMenu *)menu{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    return [NSApp.delegate performSelector:NSSelectorFromString(@"menu")];
#pragma clang diagnostic pop
}

- (void)showIMEPreferences:(id)sender {
    [[TypioSettingsWindowController sharedController] showSettingsWindow];
}

- (void)applyCandidatePanelPreference {
    NSInteger panelType = [preference integerForKey:TypioCandidatePanelTypeDefaultsKey];
    if (panelType < kIMKSingleColumnScrollingCandidatePanel || panelType > kIMKSingleRowSteppingCandidatePanel) {
        panelType = kIMKSingleRowSteppingCandidatePanel;
    }

    if (sharedCandidates && sharedCandidates.panelType != panelType) {
        [sharedCandidates setPanelType:panelType];
    }
}

- (void)handleSettingsDidChange:(NSNotification *)notification {
    [self applyCandidatePanelPreference];
}

- (void)clickAbout:(NSMenuItem *)sender {
    [self openUrl:@"https://github.com/howtoexitvim/typio"];
}

- (void)clickSponsor:(NSMenuItem *)sender {
    [self openUrl:@"https://www.shuqihere.top/archive/projects/typio"];
}

- (void)openUrl:(NSString *)url {
    NSWorkspace *ws = [NSWorkspace sharedWorkspace];

    NSWorkspaceOpenConfiguration *configuration = [NSWorkspaceOpenConfiguration new];
    configuration.promptsUserIfNeeded = YES;
    configuration.createsNewApplicationInstance = NO;

    [ws openURL:[NSURL URLWithString:url] configuration:configuration completionHandler:^(NSRunningApplication * _Nullable app, NSError * _Nullable error) {
        if (error) {
          NSLog(@"Failed to run the app: %@", error.localizedDescription);
        }
    }];
}



@end
