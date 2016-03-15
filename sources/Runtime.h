//https://developer.apple.com/library/ios//documentation/Cocoa/Reference/ObjCRuntimeRef/index.html
#include <objc/runtime.h>

typedef struct objc_property *Property;
typedef objc_property_attribute_t *PropertyAttribute;
typedef SEL Selector;
typedef IMP Implementation;

#define LOG_STUFF 01
#if LOG_STUFF
#define rLog(format, ...) NSLog(@"\033[34m[Runtime]\033[0m " format, ##__VA_ARGS__);
#else
#define rLog(format, ...)
#endif

@interface NSString (indexCategory)
- (id)objectAtIndexedSubscript:(NSInteger)idx;
@end

NSString *rtTypeForEncoding(NSString *encodingString, NSString *varName);

@class RTIvar;

@interface RTClass : NSObject {
	Class _class;
}
+ (id)classWithClass:(Class)cls;
- (id)initWithClass:(Class)cls;
- (Class)internalClass;
- (RTIvar *)getInstanceVariableWithName:(NSString *)name;
@end

@interface RTIvar : NSObject {
	Ivar _ivar;
}
@property (nonatomic, assign) RTClass *owner;
+ (id)ivarWithIvar:(Ivar)ivar;
+ (id)ivarWithIvar:(Ivar)ivar andOwner:(RTClass *)class;
- (id)initWithIvar:(Ivar)ivar;
- (id)initWithIvar:(Ivar)ivar andOwner:(RTClass *)class;
- (Ivar)internalIvar;

- (NSString *)name;
- (NSString *)type;
- (NSString *)typeWithName:(NSString *)name;
@end

@interface RTProperty : NSObject {
	Property _property;
}
@property (nonatomic, assign) RTClass *owner;
+ (id)propertyWithProperty:(Property)property;
+ (id)propertyWithProperty:(Property)property andOwner:(RTClass *)class;
- (id)initWithProperty:(Property)property;
- (id)initWithProperty:(Property)property andOwner:(RTClass *)class;
- (Property)internalProperty;

- (NSString *)backingIvar;
- (NSString *)getter;
- (NSString *)setter;
@end

@interface RTPropertyAttribute : NSObject {
	PropertyAttribute _propertyAttribute;
}
+ (id)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (id)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (PropertyAttribute)internalPropertyAttribute;
@end

@interface RTMethod : NSObject {
	Method _method;
}
@property (nonatomic, assign) RTClass *owner;
+ (id)methodWithMethod:(Method)method;
+ (id)methodWithMethod:(Method)method andOwner:(RTClass *)class;
- (id)initWithMethod:(Method)method;
- (id)initWithMethod:(Method)method andOwner:(RTClass *)class;
- (Method)internalMethod;

- (NSString *)name;
@property (nonatomic, assign) BOOL isClassMethod;
@end

@interface RTSelector : NSObject {
	Selector _selector;
}
@property (nonatomic, assign) RTClass *owner;
+ (id)selectorWithSelector:(Selector)selector;
+ (id)selectorWithSelector:(Selector)selector andOwner:(RTClass *)class;
- (id)initWithSelector:(Selector)selector;
- (id)initWithSelector:(Selector)selector andOwner:(RTClass *)class;
- (Selector)internalSelector;
@end

@interface RTProtocol : NSObject {
	Protocol *_protocol;
}
+ (id)protocolWithProtocol:(Protocol *)protocol;
- (id)initWithProtocol:(Protocol *)protocol;
- (Protocol *)internalProtocol;
@end

@interface RTObject : NSObject {
	NSObject *_object;
}
+ (id)objectWithObject:(NSObject *)object;
- (id)initWithObject:(NSObject *)object;
- (NSObject *)internalObject;
@end

@interface RTRuntime : NSObject
+ (NSString *)typeForEncoding:(NSString *)enc varName:(NSString *)varName;
+ (objc_AssociationPolicy)associationPolicyWithName:(NSString *)policyName;
@end
