#import "Runtime.h"

@implementation RTPropertyAttribute : NSObject

+ (instancetype)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute {
	return [[[self alloc] initWithPropertyAttribute:propertyAttribute] autorelease];
}
- (instancetype)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute {
	if ((self = [super init])) {
		_internalPropertyAttribute = propertyAttribute;
	}
	return self;
}
- (PropertyAttribute)internalPropertyAttribute {
	return _internalPropertyAttribute;
}

@end
