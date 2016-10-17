#import "Runtime.h"

@implementation RTIvar

+ (instancetype)ivarWithIvar:(Ivar)ivar {
	return [[[self alloc] initWithIvar:ivar] autorelease];
}
+ (instancetype)ivarWithIvar:(Ivar)ivar andOwner:(id)owner {
	return [[[self alloc] initWithIvar:ivar andOwner:owner] autorelease];
}
- (instancetype)initWithIvar:(Ivar)ivar {
	return [self initWithIvar:ivar andOwner:nil];
}
- (instancetype)initWithIvar:(Ivar)ivar andOwner:(id)owner {
	if ((self = [super init])) {
		_ivar = ivar;
		_owner = owner;
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
