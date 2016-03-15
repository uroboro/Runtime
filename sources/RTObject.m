#import "Runtime.h"

@implementation RTObject

+ (id)objectWithObject:(NSObject *)object {
	return [[[self alloc] initWithObject:object] autorelease];
}
- (id)initWithObject:(NSObject *)object {
	if ((self = [super init])) {
		_object = object;
	}
	return self;
}
- (NSObject *)internalObject {
	return _object;
}

#pragma mark - Working with Instances
- (id)copyWithSize:(size_t)size {
	return object_copy(_object, size);
}
- (id)dispose {
 	return object_dispose(_object);
}
- (RTIvar *)setInstanceVariableWithName:(NSString *)name value:(void *)value {
	return [RTIvar ivarWithIvar:object_setInstanceVariable(_object, name.UTF8String, value)];
}
- (RTIvar *)getInstanceVariableWithName:(NSString *)name value:(void **)outValue {
 	return [RTIvar ivarWithIvar:object_getInstanceVariable(_object, name.UTF8String, outValue)];
}
- (void *)getIndexedIvars {
 	return object_getIndexedIvars(_object);
}
- (id)getIvar:(RTIvar *)ivar {
	return object_getIvar(_object, ivar.internalIvar);
}
- (void)setIvar:(RTIvar *)ivar value:(id)value {
	return object_setIvar(_object, ivar.internalIvar, value);
}
- (NSString *)getClassName {
	return [NSString stringWithUTF8String:object_getClassName(_object)];
}
- (RTClass *)getClass {
	return [RTClass classWithClass:object_getClass(_object)];
}
- (RTClass *)setClass:(RTClass *)cls {
	return [RTClass classWithClass:object_setClass(_object, cls.internalClass)];
}

#pragma mark - Associative References
- (void)setAssociatedObjectForKey:(const void *)key value:(id)value policy:(NSString *)policyName {
	objc_setAssociatedObject(_object, key, value, [RTRuntime associationPolicyWithName:policyName]);
}
- (id)getAssociatedObjectForKey:(const void *)key {
	return objc_getAssociatedObject(_object, key);
}
- (void)removeAssociatedObjects {
	objc_removeAssociatedObjects(_object);
}

@end
