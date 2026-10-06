#import "marisa.h"
#import <Cocoa/Cocoa.h>

@interface ConversionEngine : NSObject

+ (instancetype)sharedEngine;
- (NSMutableArray *)wordsStartsWith:(NSString *)prefix;
- (NSArray *)sortWordsByFrequency:(NSArray *)filtered;
- (NSArray *)getCandidates:(NSString *)originalInput;

@property NSDictionary *wordFrequency;
@property BOOL trieReady;

@end
