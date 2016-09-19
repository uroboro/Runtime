#import "Runtime.h"

@implementation RTSelector

+ (id)selectorWithSelector:(Selector)selector {
	return [[[self alloc] initWithSelector:selector] autorelease];
}
+ (id)selectorWithSelector:(Selector)selector andOwner:(RTClass *)class {
	return [[[self alloc] initWithSelector:selector andOwner:class] autorelease];
}
- (id)initWithSelector:(Selector)selector {
	return [self initWithSelector:selector andOwner:nil];
}
- (id)initWithSelector:(Selector)selector andOwner:(RTClass *)class {
	if ((self = [super init])) {
		_selector = selector;
		_owner = class;
	}
	return self;
}
- (Selector)internalSelector {
	return _selector;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:sel_getName(_selector)];
}
- (Selector)registerName:(NSString *)name {
	return sel_registerName(name.UTF8String);
}
- (BOOL)isEqualToSelector:(Selector)selector {
	return sel_isEqual(_selector, selector);
}

#pragma mark - Description

- (NSString *)description {
	return self.name;
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTSelector *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end