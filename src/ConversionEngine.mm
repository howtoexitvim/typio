#import "ConversionEngine.h"

NSDictionary *deserializeJSON(NSString *path) {
    if (path == nil || path.length == 0) {
        return @{};
    }
    NSData *data = [NSData dataWithContentsOfFile:path];
    if (data == nil || data.length == 0) {
        return @{};
    }
    NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    if (error || ![json isKindOfClass:[NSDictionary class]]) {
        return @{};
    }
    return (NSDictionary *)json;
}

marisa::Trie trie;

@implementation ConversionEngine

+ (instancetype)sharedEngine {
    static dispatch_once_t once;
    static id sharedInstance;

    dispatch_once(&once, ^{
        sharedInstance = [self new];
        [sharedInstance loadPreparedData];
    });
    return sharedInstance;
}

- (void)loadPreparedData {
    [self loadTrie];
    self.wordFrequency = [self getWordFrequency];
}


- (void)loadTrie {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"google_227800_words" ofType:@"bin"];
    if (path == nil || path.length == 0) {
        self.trieReady = NO;
        return;
    }
    const char *path2 = [path cStringUsingEncoding:[NSString defaultCStringEncoding]];
    if (path2 == NULL) {
        self.trieReady = NO;
        return;
    }
    try {
        trie.load(path2);
        self.trieReady = YES;
    } catch (...) {
        self.trieReady = NO;
    }
}

- (NSDictionary *)getWordFrequency {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"word_frequency" ofType:@"json"];
    return deserializeJSON(path);
}

- (NSMutableArray *)wordsStartsWith:(NSString *)buffer {
    if (!self.trieReady || buffer == nil || buffer.length == 0) {
        return [[NSMutableArray alloc] init];
    }

    marisa::Agent agent;
    const char *query = [buffer cStringUsingEncoding:[NSString defaultCStringEncoding]];
    if (query == NULL) {
        return [[NSMutableArray alloc] init];
    }
    agent.set_query(query);

    NSMutableArray *filtered = [[NSMutableArray alloc] init];
    while (trie.predictive_search(agent)) {
        const marisa::Key key = agent.key();
        NSString *word = [[NSString alloc] initWithBytes:key.ptr() length:key.length() encoding:NSASCIIStringEncoding];
        [filtered addObject:word];
    }
    return filtered;
}

- (NSArray *)sortWordsByFrequency:(NSArray *)filtered {
    NSDictionary *words = self.wordFrequency;
    NSArray *sorted = [filtered sortedArrayUsingComparator:^NSComparisonResult(id word1, id word2) {
        NSNumber *freq1 = words[word1];
        NSNumber *freq2 = words[word2];
        if (freq1 == nil && freq2 == nil) {
            return (NSComparisonResult)NSOrderedSame;
        }
        if (freq1 == nil) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        if (freq2 == nil) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        int64_t n = freq1.longLongValue - freq2.longLongValue;
        if (n > 0) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        if (n < 0) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];

    return sorted;
}

- (NSArray *)getCandidates:(NSString *)originalInput {
    NSString *buffer = originalInput.lowercaseString;
    NSMutableArray *result = [[NSMutableArray alloc] init];

    if (buffer && buffer.length > 0) {
        NSMutableArray *filtered = [self wordsStartsWith:buffer];
        if (filtered && filtered.count > 0) {
            NSArray *sorted = [self sortWordsByFrequency:filtered];
            [result addObjectsFromArray:sorted];
        }

        if (result.count > 50) {
            result = [NSMutableArray arrayWithArray:[result subarrayWithRange:NSMakeRange(0, 49)]];
        }
        [result removeObject:buffer];
        [result insertObject:buffer atIndex:0];
    }

    NSMutableArray *result2 = [[NSMutableArray alloc] init];
    for (NSString *word in result) {
        // case sensitive input
        if ([word hasPrefix:buffer]) {
            [result2 addObject:[NSString stringWithFormat:@"%@%@", originalInput, [word substringFromIndex:originalInput.length]]];
        } else {
            [result2 addObject:word];
        }
    }
    NSOrderedSet *orderedSet = [NSOrderedSet orderedSetWithArray:result2];
    NSArray *arrayWithoutDuplicates = orderedSet.array;
    return [NSArray arrayWithArray:arrayWithoutDuplicates];
}

@end
