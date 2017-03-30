#import "RTIvar.h"
#import "RTDecoding.h"

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
		_internalIvar = ivar;
		_owner = owner;
	}
	return self;
}
- (Ivar)internalIvar {
	return _internalIvar;
}

- (NSString *)name {
	return [NSString stringWithUTF8String:ivar_getName(_internalIvar)];
}
- (NSString *)typeEncoding {
	return [NSString stringWithUTF8String:ivar_getTypeEncoding(_internalIvar)];
}
- (ptrdiff_t)offset {
	return ivar_getOffset(_internalIvar);
}

- (NSString *)type {
	return rtTypeForEncoding(self.typeEncoding, nil);
}
- (NSString *)typeWithName:(NSString *)name {
	return rtTypeForEncoding(self.typeEncoding, name);
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
