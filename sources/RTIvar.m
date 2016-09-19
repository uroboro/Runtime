#import "Runtime.h"

@implementation RTIvar

+ (id)ivarWithIvar:(Ivar)ivar {
	return [[[self alloc] initWithIvar:ivar] autorelease];
}
+ (id)ivarWithIvar:(Ivar)ivar andOwner:(RTClass *)class {
	return [[[self alloc] initWithIvar:ivar andOwner:class] autorelease];
}
- (id)initWithIvar:(Ivar)ivar {
	return [self initWithIvar:ivar andOwner:nil];
}
- (id)initWithIvar:(Ivar)ivar andOwner:(RTClass *)class {
	if ((self = [super init])) {
		_ivar = ivar;
		_owner = class;
	}
	return self;
}
- (Ivar)internalIvar {
	return _ivar;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:ivar_getName(_ivar)];
}
- (NSString *)typeEncoding {
	return [NSString stringWithUTF8String:ivar_getTypeEncoding(_ivar)];
}
- (ptrdiff_t)offset {
	return ivar_getOffset(_ivar);
}

- (NSString *)type {
	return [RTRuntime typeForEncoding:self.typeEncoding varName:nil];
}
- (NSString *)typeWithName:(NSString *)name {
	return [RTRuntime typeForEncoding:self.typeEncoding varName:name];
}

#pragma mark - Description

- (NSString *)description {
	return [self typeWithName:self.name];
}

#pragma mark - Comparison

- (NSComparisonResult)caseInsensitiveCompare:(RTIvar *)rhs {
	return [self.name caseInsensitiveCompare:rhs.name];
}

@end
