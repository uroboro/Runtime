#import "Runtime.h"

@implementation RTPropertyAttribute : NSObject

+ (id)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute {
	return [[[self alloc] initWithPropertyAttribute:propertyAttribute] autorelease];
}
- (id)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute {
	if ((self = [super init])) {
		_propertyAttribute = propertyAttribute;
	}
	return self;
}
- (PropertyAttribute)internalPropertyAttribute {
	return _propertyAttribute;
}

@end
