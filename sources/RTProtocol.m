#import "Runtime.h"

@implementation RTProtocol

+ (instancetype)protocolWithProtocol:(Protocol *)protocol {
	return [[[self alloc] initWithProtocol:protocol] autorelease];
}
- (instancetype)initWithProtocol:(Protocol *)protocol {
	if ((self = [super init])) {
		_internalProtocol = protocol;
	}
	return self;
}
- (Protocol *)internalProtocol {
	return _internalProtocol;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:protocol_getName(_internalProtocol)];
}
- (BOOL)isEqualToProtocol:(Protocol *)rhs {
	return protocol_isEqual(_internalProtocol, rhs);
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
	protocol_addMethodDescription(_internalProtocol, selector, types.UTF8String, isRequiredMethod, isInstanceMethod);
}
- (void)addProtocolAddition:(Protocol *)addition {
	protocol_addProtocol(_internalProtocol, addition);
}
- (void)addPropertyWithName:(NSString *)name
		attributes:(const objc_property_attribute_t *)attributes attributeCount:(unsigned int)attributeCount
		isRequiredProperty:(BOOL)isRequiredProperty isInstanceProperty:(BOOL)isInstanceProperty {
	protocol_addProperty(_internalProtocol, name.UTF8String, attributes, attributeCount, isRequiredProperty, isInstanceProperty);
}
#pragma mark - Convert to array of custom class
- (NSArray *)copyMethodDescriptionList:(BOOL)b
		isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod {
	return nil;
	unsigned int outCount = 0;
	MethodDescription *descriptions = protocol_copyMethodDescriptionList(_internalProtocol, isRequiredMethod, isInstanceMethod, &outCount);
 /**/rLog(@"method descriptions in protocol %@: %d", NSStringFromProtocol(_internalProtocol), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, &descriptions[i]);
	}
	free(descriptions);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (MethodDescription)getMethodDescriptionForSelector:(RTSelector *)selector
		isRequiredMethod:(BOOL)isRequiredMethod isInstanceMethod:(BOOL)isInstanceMethod {
	return protocol_getMethodDescription(_internalProtocol, selector.internalSelector, isRequiredMethod, isInstanceMethod);
}
- (NSArray *)properties {
	unsigned int outCount = 0;
	Property *properties = protocol_copyPropertyList(_internalProtocol, &outCount);
 /**/rLog(@"properties in protocol %@: %d", NSStringFromProtocol(_internalProtocol), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTProperty propertyWithProperty:properties[i] andOwner:self]);
	}
	free(properties);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (RTProperty *)getPropertyWithName:(NSString *)name
		isRequiredProperty:(BOOL)isRequiredProperty isInstanceProperty:(BOOL)isInstanceProperty {
	return [RTProperty propertyWithProperty:protocol_getProperty(_internalProtocol, name.UTF8String, isRequiredProperty, isInstanceProperty) andOwner:self];
}
- (NSArray *)copyProtocolList {
	unsigned int *outCount = 0;
	Protocol **protocols = protocol_copyProtocolList(_internalProtocol, outCount);
 /**/rLog(@"protocols in protocol %@: %d", NSStringFromProtocol(_internalProtocol), *outCount);
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
	return protocol_conformsToProtocol(_internalProtocol, rhs);
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
