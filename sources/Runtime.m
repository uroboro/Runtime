#import "RT_Runtime.h"

@implementation NSString (indexCategory)
- (NSString *)objectAtIndexedSubscript:(NSInteger)idx {
	return [self substringWithRange:NSMakeRange(idx, 1)];
}
@end

@implementation RTRuntime

+ (void)load {
	rLog(@"+load");
}
+ (void)initialize {
	rLog(@"+initialize");
}

#pragma mark - Obtaining Class Definitions

+ (NSArray *)classes {
	unsigned int outCount;
	Class *classes = objc_copyClassList(&outCount);
	//rLog(@"registered classes: %d at %p", outCount, classes);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:outCount];
	for (unsigned int i = 0; classes[i]; i++) {
		[array addObject:[RTClass classWithClass:classes[i]]];
	}
	free(classes);
	[array sortUsingSelector:@selector(caseInsensitiveCompare:)];
	return [array copy];
}
+ (NSArray *)classesConformingToProtocol:(Protocol *)protocol {
	NSArray *array = [[self classes] filteredArrayUsingPredicate:[NSPredicate predicateWithBlock:^BOOL(id obj, NSDictionary *bind){
		return [obj conformsToProtocol:protocol];
	}]];
	//sort protocol array
	return array;
}
+ (RTClass *)lookUpClass:(NSString *)name {
	return [RTClass classWithClass:objc_lookUpClass(name.UTF8String)];
}
+ (RTClass *)classNamed:(NSString *)name {
	return [RTClass classWithClass:objc_getClass(name.UTF8String)];
}
+ (RTClass *)metaClassNamed:(NSString *)name {
	return [RTClass classWithClass:objc_getMetaClass(name.UTF8String)];
}
+ (RTClass *)ZeroLink {
	//crash process
	return [RTClass classWithClass:objc_getRequiredClass("ZeroLink")];
}

#pragma mark - Obtaining Protocol Definitions

+ (NSArray *)protocols {
	unsigned int outCount = 0;
	Protocol **protocols = objc_copyProtocolList(&outCount);
 /**/rLog(@"registered protocols: %d", outCount);
	CFMutableArrayRef array = CFArrayCreateMutable(kCFAllocatorDefault, (CFIndex)outCount, NULL);
	for (unsigned int i = 0; i < outCount; i++) {
		CFArrayAppendValue(array, [RTProtocol protocolWithProtocol:protocols[i]]);
	}
	free(protocols);
	NSArray *r = [(NSMutableArray *)array copy];
	CFRelease(array);
	return r;
}

#pragma mark - Working with Libraries

+ (NSArray *)imageNames {
	unsigned int outCount;
	const char **imageNames = objc_copyImageNames(&outCount);
	//rLog(@"registered classes: %d at %p", outCount, classes);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:outCount];
	for (unsigned int i = 0; imageNames[i]; i++) {
		[array addObject:[NSString stringWithUTF8String:imageNames[i]]];
	}
	free(imageNames);
	[array sortUsingSelector:@selector(caseInsensitiveCompare:)];
	return [array copy];
}

+ (NSArray *)classNamesForImage:(NSString *)image {
	unsigned int outCount;
	const char **classNames = objc_copyClassNamesForImage(image.UTF8String, &outCount);
	//rLog(@"registered classes: %d at %p", outCount, classes);
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:outCount];
	for (unsigned int i = 0; classNames[i]; i++) {
		[array addObject:[NSString stringWithUTF8String:classNames[i]]];
	}
	free(classNames);
	[array sortUsingSelector:@selector(caseInsensitiveCompare:)];
	return [array copy];
}

// Sending Messages

#pragma mark - Using Objective-C Language Features

+ (id)loadWeak:(id *)address {
	return objc_loadWeak(address);
}

+ (id)storeWeak:(id *)address object:(id)object {
	return objc_storeWeak(address, object);
}

#pragma mark - Utilities

+ (NSString *)typeForEncoding:(NSString *)encodingString varName:(NSString *)varName {
	return rtTypeForEncoding(encodingString, varName);
}

+ (AssociationPolicy)associationPolicyWithName:(NSString *)policyName {
	NSDictionary *policies = @{
		  @"OBJC_ASSOCIATION_ASSIGN" : @(OBJC_ASSOCIATION_ASSIGN)
		, @"OBJC_ASSOCIATION_RETAIN_NONATOMIC" : @(OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		, @"OBJC_ASSOCIATION_COPY_NONATOMIC" : @(OBJC_ASSOCIATION_COPY_NONATOMIC)
		, @"OBJC_ASSOCIATION_RETAIN" : @(OBJC_ASSOCIATION_RETAIN)
		, @"OBJC_ASSOCIATION_COPY" : @(OBJC_ASSOCIATION_COPY)
	};
	return policies[policyName] ? ((NSNumber *)policies[policyName]).integerValue : OBJC_ASSOCIATION_ASSIGN;
}

@end
