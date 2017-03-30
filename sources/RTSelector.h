#import "Runtime.h"

@interface RTSelector : NSObject
@property (nonatomic) Selector internalSelector;
@property (nonatomic, assign) id owner;
+ (instancetype)selectorWithSelector:(Selector)selector andOwner:(id)owner;
- (instancetype)initWithSelector:(Selector)selector andOwner:(id)owner;
@end
