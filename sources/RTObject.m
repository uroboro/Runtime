#import "RTObject.h"
#import "RTClass.h"
#import "RTIvar.h"
#import "RT_Runtime.h"

@implementation RTObject

+ (instancetype)objectWithObject:(NSObject *)object {
	return [[[self alloc] initWithObject:object] autorelease];
}
- (instancetype)initWithObject:(NSObject *)object {
	if ((self = [super init])) {
		_internalObject = object;
	}
	return self;
}
- (NSObject *)internalObject {
	return _internalObject;
}

#pragma mark - Working with Instances
- (id)copyWithSize:(size_t)size {
	return object_copy(_internalObject, size);
}
- (id)dispose {
	return object_dispose(_internalObject);
}
- (RTIvar *)setInstanceVariableWithName:(NSString *)name value:(void *)value {
	return [RTIvar ivarWithIvar:object_setInstanceVariable(_internalObject, name.UTF8String, value) andOwner:self];
}
- (RTIvar *)getInstanceVariableWithName:(NSString *)name value:(void **)outValue {
	return [RTIvar ivarWithIvar:object_getInstanceVariable(_internalObject, name.UTF8String, outValue) andOwner:self];
}
- (void *)getIndexedIvars {
	return object_getIndexedIvars(_internalObject);
}
- (id)getIvar:(RTIvar *)ivar {
	return object_getIvar(_internalObject, ivar.internalIvar);
}
- (void)setIvar:(RTIvar *)ivar value:(id)value {
	return object_setIvar(_internalObject, ivar.internalIvar, value);
}
- (NSString *)getClassName {
	return [NSString stringWithUTF8String:object_getClassName(_internalObject)];
}
- (RTClass *)getClass {
	return [RTClass classWithClass:object_getClass(_internalObject)];
}
- (RTClass *)setClass:(RTClass *)cls {
	return [RTClass classWithClass:object_setClass(_internalObject, cls.internalClass)];
}

#pragma mark - Associative References
- (void)setAssociatedObjectForKey:(const void *)key value:(id)value policy:(NSString *)policyName {
	objc_setAssociatedObject(_internalObject, key, value, [RTRuntime associationPolicyWithName:policyName]);
}
- (id)getAssociatedObjectForKey:(const void *)key {
	return objc_getAssociatedObject(_internalObject, key);
}
- (void)removeAssociatedObjects {
	objc_removeAssociatedObjects(_internalObject);
}

@end
