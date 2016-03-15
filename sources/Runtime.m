#import "Runtime.h"

@implementation NSString (indexCategory)
- (id)objectAtIndexedSubscript:(NSInteger)idx {
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
// NSArray of NSStrings
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
+ (Class)lookUpClass:(NSString *)name {
	return objc_lookUpClass(name.UTF8String);
}
+ (Class)objc_getClass:(NSString *)name {
	return objc_getClass(name.UTF8String);
}
+ (Class)objc_getMetaClass:(NSString *)name {
	return objc_getMetaClass(name.UTF8String);
}
+ (Class)ZeroLink {
	//crash process
	return objc_getRequiredClass("ZeroLink");
}

#pragma mark - Convert to array of custom class
+ (NSArray *)objc_copyProtocolList {
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
+ (NSArray *)copyClassNamesForImage:(const char *)image {
	unsigned int outCount;
	const char **classNames = objc_copyClassNamesForImage(image, &outCount);
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
#if 0
void objc_enumerationMutation(id obj)
void objc_setEnumerationMutationHandler(void (*handler)(id))
id objc_loadWeak(id *location)
id objc_storeWeak(id *location, id obj)
#endif

// Utils
+ (NSString *)typeForEncoding:(NSString *)encodingString varName:(NSString *)varName {
	return rtTypeForEncoding(encodingString, varName);
}
+ (objc_AssociationPolicy)associationPolicyWithName:(NSString *)policyName {
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
