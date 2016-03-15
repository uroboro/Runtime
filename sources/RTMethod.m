#import "Runtime.h"

@implementation RTMethod

+ (id)methodWithMethod:(Method)method {
	return [[[self alloc] initWithMethod:method] autorelease];
}
+ (id)methodWithMethod:(Method)method andOwner:(RTClass *)class {
	return [[[self alloc] initWithMethod:method andOwner:class] autorelease];
}
- (id)initWithMethod:(Method)method {
	return [self initWithMethod:method andOwner:nil];
}
- (id)initWithMethod:(Method)method andOwner:(RTClass *)class {
	if ((self = [super init])) {
		_method = method;
		_owner = class;
	}
	return self;
}
- (Method)internalMethod {
	return _method;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:sel_getName(method_getName(_method))];
}
- (NSString *)typeEncoding {
	return [NSString stringWithUTF8String:method_getTypeEncoding(_method)];
}
- (NSString *)returnType {
	char *r = method_copyReturnType(_method);
	NSString *ret = [NSString stringWithUTF8String:r];
	free(r);
	return ret;
}
- (NSString *)argumentTypeAtIndex:(NSUInteger)index {
	char *r = method_copyArgumentType(_method, index);
	NSString *ret = [NSString stringWithUTF8String:r];
	free(r);
	return ret;
}
- (NSUInteger)numberOfArguments {
	return (NSUInteger)method_getNumberOfArguments(_method);
}
- (NSArray *)argumentTypes {
	NSMutableArray *array = [NSMutableArray arrayWithCapacity:self.numberOfArguments];
	for (NSUInteger i = 0; i < self.numberOfArguments; i++) {
		[array addObject:[self argumentTypeAtIndex:i]];
	}
	return array;
}

#if 0
	id method_invoke(id receiver, Method m, ...)
	void method_invoke_stret(id receiver, Method m, ...)
	Implementation method_getImplementation( Method method)
	struct objc_method_description *method_getDescription( Method m)
	Implementation method_setImplementation( Method method, Implementation imp)
	void method_exchangeImplementations( Method m1, Method m2)

	#pragma mark - Using Objective-C Language Features
	Implementation imp_implementationWithBlock(id block)
	id imp_getBlock( Implementation anImp)
	BOOL imp_removeBlock( Implementation anImp)
#endif

#pragma mark - Description

- (NSString *)description {
	NSArray *types = self.argumentTypes;
	types = [types subarrayWithRange:NSMakeRange(2, types.count - 2)];
	NSArray *nameSegments = [self.name componentsSeparatedByString:@":"];

	NSMutableArray *fullNameArray = [NSMutableArray arrayWithCapacity:nameSegments.count];
	if (types.count > 0) {
		[types enumerateObjectsUsingBlock:^(NSString *type, NSUInteger idx, BOOL *stop) {
			[fullNameArray addObject:[NSString stringWithFormat:@"%@:(%@)arg%d", nameSegments[idx], [[RTRuntime typeForEncoding:type varName:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], (int)idx]];
		}];
	} else {
		[fullNameArray addObject:nameSegments[0]];
	}

	return [NSString stringWithFormat:@"%c (%@)%@", self.isClassMethod ? '+':'-', [[RTRuntime typeForEncoding:self.returnType varName:@""] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]], [fullNameArray componentsJoinedByString:@" "]];
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTMethod *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end
