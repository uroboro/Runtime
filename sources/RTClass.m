#import "Runtime.h"

@implementation RTClass

+ (instancetype)classWithClass:(Class)cls {
	return [[[self alloc] initWithClass:cls] autorelease];
}
- (instancetype)initWithClass:(Class)cls {
	if ((self = [super init])) {
		_class = cls;
	}
	return self;
}
- (Class)internalClass {
	return _class;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:class_getName(_class)];
}
- (RTClass *)getSuperclass {
	return [RTClass classWithClass:class_getSuperclass(_class)];
}
- (BOOL)isMetaClass {
	return class_isMetaClass(_class);
}
- (size_t)getInstanceSize {
	return class_getInstanceSize(_class);
}
- (RTIvar *)getClassVariableWithName:(NSString *)name {
	return [RTIvar ivarWithIvar:class_getClassVariable(_class, name.UTF8String) andOwner:self];
}

- (int)getVersion {
	return class_getVersion(_class);
}
- (void)setVersion:(int)version {
	class_setVersion(_class, version);
}

#pragma mark - Class Ivars
- (NSArray *)ivars {
	unsigned int outCount = 0;
	Ivar *ivars = class_copyIvarList(_class, &outCount);
	//rLog(@"ivars in class %@: %d", NSStringFromClass(_class), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTIvar ivarWithIvar:ivars[i] andOwner:self]);
	}
	free(ivars);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (RTIvar *)getInstanceVariableWithName:(NSString *)name {
	return [RTIvar ivarWithIvar:class_getInstanceVariable(_class, name.UTF8String) andOwner:self];
}
- (BOOL)addIvarWithName:(NSString *)name size:(size_t)size alignment:(uint8_t)alignment types:(NSString *)types {
	return class_addIvar(_class, name.UTF8String, size, alignment, types.UTF8String);
}
- (const uint8_t *)getIvarLayout {
	return class_getIvarLayout(_class);
}
- (void)setIvarLayout:(const uint8_t *)layout {
	class_setIvarLayout(_class, layout);
}
- (const uint8_t *)getWeakIvarLayout {
	return class_getWeakIvarLayout(_class);
}
- (void)setWeakIvarLayout:(const uint8_t *)layout {
	class_setWeakIvarLayout(_class, layout);
}

#pragma mark - Class Properties
- (NSArray *)properties {
	unsigned int outCount = 0;
	Property *properties = class_copyPropertyList(_class, &outCount);
	//rLog(@"properties in class %@: %d", NSStringFromClass(_class), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTProperty propertyWithProperty:properties[i] andOwner:self]);
	}
	free(properties);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (RTProperty *)getPropertyWithName:(NSString *)name {
	return [RTProperty propertyWithProperty:class_getProperty(_class, name.UTF8String) andOwner:self];
}

#pragma mark - Class Methods
- (NSArray *)methods {
	unsigned int outCount = 0;
	Method *methods = class_copyMethodList(_class, &outCount);
	//rLog(@"methods in class %@: %d", NSStringFromClass(_class), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTMethod methodWithMethod:methods[i] andOwner:self]);
	}
	free(methods);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (BOOL)addMethodForSelector:(RTSelector *)selector implementation:(Implementation)imp types:(NSString *)types {
	return class_addMethod(_class, selector.internalSelector, imp, types.UTF8String);
}
- (RTMethod *)getInstanceMethodForSelector:(RTSelector *)selector {
	RTMethod *m = [RTMethod methodWithMethod:class_getInstanceMethod(_class, selector.internalSelector) andOwner:self];
	m.isClassMethod = NO;
	return m;
}
- (RTMethod *)getClassMethodForSelector:(RTSelector *)selector {
	RTMethod *m = [RTMethod methodWithMethod:class_getClassMethod(_class, selector.internalSelector) andOwner:self];
	m.isClassMethod = YES;
	return m;
}
- (Implementation)replaceMethodForSelector:(RTSelector *)selector implementation:(Implementation)imp types:(NSString *)types {
	return class_replaceMethod(_class, selector.internalSelector, imp, types.UTF8String);
}
- (Implementation)getMethodImplementationForSelector:(RTSelector *)selector {
	return class_getMethodImplementation(_class, selector.internalSelector);
}
#if !__LP64__
- (Implementation)getMethodImplementation_stretForSelector:(RTSelector *)selector {
	return class_getMethodImplementation_stret(_class, selector.internalSelector);
}
#endif /* __LP64__ */
- (BOOL)respondsToSelector:(Selector)selector {
	return class_respondsToSelector(_class, selector);
}

#pragma mark - Class Protocols
- (NSArray *)protocols {
	unsigned int outCount = 0;
	Protocol **protocols = class_copyProtocolList(_class, &outCount);
	//rLog(@"protocols in class %@: %d", NSStringFromClass(_class), outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTProtocol protocolWithProtocol:protocols[i]]);
	}
	free(protocols);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}
- (BOOL)addProtocol:(RTProtocol *)protocol {
	return class_addProtocol(_class, protocol.internalProtocol);
}
- (BOOL)addPropertyWithName:(NSString *)name attributes:(NSArray *)attributesArray {
	unsigned int attributeCount = (unsigned int)CFArrayGetCount((CFArrayRef)attributesArray);
	objc_property_attribute_t *attributes = (objc_property_attribute_t *)malloc(attributeCount * sizeof(objc_property_attribute_t));
	for (unsigned int i = 0; i < attributeCount; i++) {
		attributes[i] = *(objc_property_attribute_t *)CFArrayGetValueAtIndex((CFArrayRef)attributesArray, i);
	}
	BOOL r = class_addProperty(_class, name.UTF8String, attributes, attributeCount);
	free(attributes);
	return r;
}
- (void)replacePropertyWithName:(NSString *)name attributes:(NSArray *)attributesArray {
	unsigned int attributeCount = (unsigned int)CFArrayGetCount((CFArrayRef)attributesArray);
	objc_property_attribute_t *attributes = (objc_property_attribute_t *)malloc(attributeCount * sizeof(objc_property_attribute_t));
	for (unsigned int i = 0; i < attributeCount; i++) {
		attributes[i] = *(objc_property_attribute_t *)CFArrayGetValueAtIndex((CFArrayRef)attributesArray, i);
	}
	class_replaceProperty(_class, name.UTF8String, attributes, attributeCount);
	free(attributes);
	return;
}
- (BOOL)conformsToProtocol:(Protocol *)protocol {
	return class_conformsToProtocol(_class, protocol);
}

#pragma mark - Adding Classes
- (RTClass *)objc_allocateClassPairWithName:(NSString *)name size:(size_t)extraBytes {
	return [RTClass classWithClass:objc_allocateClassPair(_class, name.UTF8String, extraBytes)];
}
- (void)objc_disposeClassPair {
	objc_disposeClassPair(_class);
}
- (void)objc_registerClassPair {
	objc_registerClassPair(_class);
}

#pragma mark - Instantiating Classes
- (id)createInstanceWithSize:(size_t)extraBytes {
	return class_createInstance(_class, extraBytes);
}
- (id)objc_constructInstanceWithBytes:(void *)bytes {
	return objc_constructInstance(_class, bytes);
}
- (void *)objc_destructInstance:(id)obj {
	return objc_destructInstance(obj);
}

#pragma mark - Working with Libraries
- (NSString *)class_getImageName {
	return [NSString stringWithUTF8String:class_getImageName(_class)];
}

#pragma mark - Description

- (NSString *)description {
	NSMutableArray *protocols = ({ NSArray *a = [self protocols]; NSMutableArray *b = [a mutableCopy]; [a release]; b; });
	NSMutableArray *ivars = ({ NSArray *a = [self ivars]; NSMutableArray *b = [a mutableCopy]; [a release]; b; });
	NSMutableArray *properties = ({ NSArray *a = [self properties]; NSMutableArray *b = [a mutableCopy]; [a release]; b; });
	NSMutableArray *methods = ({ NSArray *a = [self methods]; NSMutableArray *b = [a mutableCopy]; [a release]; b; });

	NSMutableString *description = [[NSString stringWithFormat:@"@interface %@", self.name] mutableCopy];

	if (protocols.count > 0) {
		[description appendFormat:@" <%@>", [protocols componentsJoinedByString:@", "]];
	}

	#define FILTER_REDUNDANCIES 01
	#if FILTER_REDUNDANCIES
	[properties enumerateObjectsUsingBlock:^(RTProperty *property, NSUInteger idx, BOOL *stop) {
		[ivars enumerateObjectsUsingBlock:^(RTIvar *ivar, NSUInteger idx, BOOL *stop) {
			if ([ivar.name isEqualToString:property.backingIvar]) {
				*stop = YES;
				[ivars removeObject:ivar];
			}
		}];
		[methods enumerateObjectsUsingBlock:^(RTMethod *method, NSUInteger idx, BOOL *stop) {
			if ([method.name isEqualToString:property.getter]) {
				*stop = YES;
				[methods removeObject:method];
			}
		}];
		[methods enumerateObjectsUsingBlock:^(RTMethod *method, NSUInteger idx, BOOL *stop) {
			if ([method.name isEqualToString:property.setter]) {
				*stop = YES;
				[methods removeObject:method];
			}
		}];
	}];
	#endif

	if (ivars.count > 0) {
		[description appendFormat:@" {\n\t%@;\n}", [ivars componentsJoinedByString:@";\n\t"]];
	}
	[description appendFormat:@"\n"];

	if (properties.count > 0) {
		[description appendFormat:@"%@;\n", [properties componentsJoinedByString:@";\n"]];
	}

	if (methods.count > 0) {
		[description appendFormat:@"%@", [methods componentsJoinedByString:@";\n"]];
		[description appendFormat:@";\n"];
	}

	[description appendFormat:@"@end"];

	[protocols release];
	[ivars release];
	[properties release];
	[methods release];

	return description;
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTClass *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end
