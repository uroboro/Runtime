#import "Runtime.h"

@implementation RTProperty

+ (instancetype)propertyWithProperty:(Property)property {
	return [[[self alloc] initWithProperty:property] autorelease];
}
+ (instancetype)propertyWithProperty:(Property)property andOwner:(id)owner {
	return [[[self alloc] initWithProperty:property andOwner:owner] autorelease];
}
- (instancetype)initWithProperty:(Property)property {
	return [self initWithProperty:property andOwner:nil];
}
- (instancetype)initWithProperty:(Property)property andOwner:(id)owner {
	if ((self = [super init])) {
		_internalProperty = property;
		_owner = owner;
	}
	return self;
}
- (Property)internalProperty {
	return _internalProperty;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:property_getName(_internalProperty)];
}
- (NSDictionary *)attributes {
	NSString *attributesString = [NSString stringWithUTF8String:property_getAttributes(_internalProperty)];
	NSArray *attributesArray = [attributesString componentsSeparatedByString:@","];
	__block NSMutableDictionary *dict_m = [NSMutableDictionary dictionary];
	[attributesArray enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
		dict_m[obj[0]] = [obj substringWithRange:NSMakeRange(1, obj.length - 1)];
	}];
	return dict_m;
}
- (NSString *)copyAttributeValueWithName:(NSString *)attributeName {
	char *value = property_copyAttributeValue(_internalProperty, attributeName.UTF8String);
	NSString *string = [NSString stringWithUTF8String:value];
	free(value);
	return string;
}
- (NSArray *)copyAttributeList {
	return nil;
	unsigned int outCount = 0;
	PropertyAttribute attributes = property_copyAttributeList(_internalProperty, &outCount);
	//rLog(@"attributes in property %p: %d", _internalProperty, outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTPropertyAttribute propertyAttributeWithPropertyAttribute:&attributes[i]]);
	}
	free(attributes);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}

- (NSString *)type {
	return self.attributes[@"T"];
}
- (NSString *)backingIvar {
	return self.attributes[@"V"];
}
- (BOOL)hasCustomGetter {
	return self.attributes[@"G"] != nil;
}
- (NSString *)getter {
	return self.hasCustomGetter ? self.attributes[@"G"] : self.name;
}
- (BOOL)hasCustomSetter {
	return self.attributes[@"S"] != nil;
}
- (NSString *)setter {
	return self.hasCustomSetter ? self.attributes[@"S"] : [NSString stringWithFormat:@"set%@:", [self.name capitalizedString]];
}

- (BOOL)isReadOnly {
	return self.attributes[@"R"] != nil;
}
- (BOOL)isCopy {
	return self.attributes[@"C"] != nil;
}
- (BOOL)isRetain {
	return self.attributes[@"&"] != nil;
}
- (BOOL)isNonatomic {
	return self.attributes[@"N"] != nil;
}
- (BOOL)isDynamic {
	return self.attributes[@"D"] != nil;
}
- (BOOL)isWeak {
	return self.attributes[@"W"] != nil;
}
- (BOOL)isGarbageCollected {
	return self.attributes[@"P"] != nil;
}

#pragma mark - Description

- (NSString *)description {
	NSMutableArray *attributesArray = [NSMutableArray array];
	if (self.isNonatomic) { [attributesArray addObject:@"nonatomic"]; }
	if (self.isReadOnly) { [attributesArray addObject:@"readonly"]; }
	if (self.isCopy) { [attributesArray addObject:@"copy"]; }
	if (self.isRetain) { [attributesArray addObject:@"retain"]; }
	if (self.isDynamic) { [attributesArray addObject:@"dynamic"]; }
	if (self.isWeak) { [attributesArray addObject:@"weak"]; }
	if (self.isGarbageCollected) { [attributesArray addObject:@"garbageCollected"]; }
	if (!(self.isReadOnly || self.isCopy || self.isRetain || self.isWeak)) { [attributesArray addObject:@"assign"]; }
	if (self.hasCustomGetter) { [attributesArray addObject:[NSString stringWithFormat:@"getter=%@", self.getter]]; }
	if (self.hasCustomSetter) { [attributesArray addObject:[NSString stringWithFormat:@"setter=%@", self.setter]]; }

	//NSString *typeString = [RTRuntime typeForEncoding:self.type varName:self.name];
	NSString *typeString = [[_owner getInstanceVariableWithName:self.backingIvar] typeWithName:self.name];
	NSString *attributesString = nil;
	if (attributesArray.count > 0) {
		attributesString = [NSString stringWithFormat:@"@property (%@) %@", [attributesArray componentsJoinedByString:@", "], typeString];
	} else {
		attributesString = [NSString stringWithFormat:@"@property %@", typeString];
	}
	return attributesString;
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTProperty *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end
