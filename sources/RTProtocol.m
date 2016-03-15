#import "Runtime.h"

@implementation RTProtocol

+ (id)protocolWithProtocol:(Protocol *)protocol {
	return [[[self alloc] initWithProtocol:protocol] autorelease];
}
- (id)initWithProtocol:(Protocol *)protocol {
	if ((self = [super init])) {
		_protocol = protocol;
	}
	return self;
}
- (Protocol *)internalProtocol {
	return _protocol;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:protocol_getName(_protocol)];
}
- (BOOL)isEqualToProtocol:(Protocol *)rhs {
	return protocol_isEqual(_protocol, rhs);
}

- (Protocol *)objc_getProtocol:(NSString *)name {
	return objc_getProtocol(name.UTF8String);
}
- (Protocol *)objc_allocateProtocol:(NSString *)name {
	return objc_allocateProtocol(name.UTF8String);
}
- (void)objc_registerProtocol:(Protocol *)protocol {
	objc_registerProtocol(protocol);
}

- (void)addMethodDescriptionForSelector:(Selector)selector types:(NSString *)types
		isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod {
	protocol_addMethodDescription(_protocol, selector, types.UTF8String, isRequiredMethod, isInstanceMethod);
}
- (void)addProtocolAddition:(Protocol *)addition {
	protocol_addProtocol(_protocol, addition);
}
- (void)addPropertyWithName:(NSString *)name
		attributes:(const objc_property_attribute_t *)attributes attributeCount:(unsigned int)attributeCount
		isRequiredProperty:(BOOL)isRequiredProperty isInstanceProperty:(BOOL)isInstanceProperty {
	protocol_addProperty(_protocol, name.UTF8String, attributes, attributeCount, isRequiredProperty, isInstanceProperty);
}
#pragma mark - Convert to array of custom class
- (NSArray *)copyMethodDescriptionList:(BOOL)b
		isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod {
	return nil;
	unsigned int outCount = 0;
	struct objc_method_description *descriptions = protocol_copyMethodDescriptionList(_protocol, isRequiredMethod, isInstanceMethod, &outCount);
 /**/rLog(@"method descriptions in protocol %@: %d", NSStringFromProtocol(_protocol), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, &descriptions[i]);
	}
	free(descriptions);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (struct objc_method_description)getMethodDescriptionForSelector:(RTSelector *)selector
		isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod {
	return protocol_getMethodDescription(_protocol, selector.internalSelector, isRequiredMethod, isInstanceMethod);
}
- (NSArray *)copyPropertyList {
	unsigned int outCount = 0;
	Property *properties = protocol_copyPropertyList(_protocol, &outCount);
 /**/rLog(@"properties in protocol %@: %d", NSStringFromProtocol(_protocol), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTProperty propertyWithProperty:properties[i]]);
	}
	free(properties);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (RTProperty *)getPropertyWithName:(NSString *)name
		isRequiredProperty:(BOOL)isRequiredProperty isInstanceProperty:(BOOL)isInstanceProperty {
	return [RTProperty propertyWithProperty:protocol_getProperty(_protocol, name.UTF8String, isRequiredProperty, isInstanceProperty)];
}
- (NSArray *)copyProtocolList {
	unsigned int *outCount = 0;
	Protocol **protocols = protocol_copyProtocolList(_protocol, outCount);
 /**/rLog(@"protocols in protocol %@: %d", NSStringFromProtocol(_protocol), *outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)*outCount, NULL);
	for (unsigned int i = 0; i < *outCount; i++) {
		CFArrayAppendValue(array, [RTProtocol protocolWithProtocol:protocols[i]]);
	}
	free(protocols);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (BOOL)conformsToProtocol:(Protocol *)rhs {
	return protocol_conformsToProtocol(_protocol, rhs);
}

#pragma mark - Description

- (NSString *)description {
	return self.name;
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTProtocol *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end
