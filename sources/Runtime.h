//https://developer.apple.com/library/ios//documentation/Cocoa/Reference/ObjCRuntimeRef/index.html
#include <objc/runtime.h>

typedef struct objc_property *Property;
typedef objc_property_attribute_t *PropertyAttribute;
typedef struct objc_method_description MethodDescription;
typedef SEL Selector;
typedef IMP Implementation;
typedef objc_AssociationPolicy AssociationPolicy;

#define LOG_STUFF 0
#if LOG_STUFF
#define rLog(format, ...) jWo75h4R78(format, ##__VA_ARGS__)
static inline void jWo75h4R78(NSString *format, ...) {
	@autoreleasepool {
		va_list args;
		va_start(args, format);
		NSString * message = [[[NSString alloc] initWithFormat:format arguments:args] autorelease];
		va_end(args);

#if 01
		printf("%s\n", message.UTF8String);
#else
		HBLogInfo(@"%@", message);
#endif
	}
}
#else
#define rLog(format, ...)
#endif

@interface NSString (indexCategory)
- (NSString *)objectAtIndexedSubscript:(NSInteger)idx;
@end

NSString *rtTypeForEncoding(NSString *encodingString, NSString *varName);

@class RTIvar;

@interface RTClass : NSObject {
	Class _class;
}
+ (instancetype)classWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls;
- (Class)internalClass;
- (RTIvar *)getInstanceVariableWithName:(NSString *)name;
@end

@interface RTIvar : NSObject {
	Ivar _ivar;
}
@property (nonatomic, assign) id owner;
//+ (instancetype)ivarWithIvar:(Ivar)ivar;
+ (instancetype)ivarWithIvar:(Ivar)ivar andOwner:(id)owner;
//- (instancetype)initWithIvar:(Ivar)ivar;
- (instancetype)initWithIvar:(Ivar)ivar andOwner:(id)owner;
- (Ivar)internalIvar;

- (NSString *)name;
- (NSString *)type;
- (NSString *)typeWithName:(NSString *)name;
@end

@interface RTProperty : NSObject {
	Property _property;
}
@property (nonatomic, assign) id owner;
//+ (instancetype)propertyWithProperty:(Property)property;
+ (instancetype)propertyWithProperty:(Property)property andOwner:(id)owner;
//- (instancetype)initWithProperty:(Property)property;
- (instancetype)initWithProperty:(Property)property andOwner:(id)owner;
- (Property)internalProperty;

- (NSString *)backingIvar;
- (NSString *)getter;
- (NSString *)setter;
@end

@interface RTPropertyAttribute : NSObject {
	PropertyAttribute _propertyAttribute;
}
+ (instancetype)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (instancetype)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (PropertyAttribute)internalPropertyAttribute;
@end

@interface RTMethod : NSObject {
	Method _method;
}
@property (nonatomic, assign) id owner;
//+ (instancetype)methodWithMethod:(Method)method;
+ (instancetype)methodWithMethod:(Method)method andOwner:(id)owner;
//- (instancetype)initWithMethod:(Method)method;
- (instancetype)initWithMethod:(Method)method andOwner:(id)owner;
- (Method)internalMethod;

- (NSString *)name;
@property (nonatomic, assign) BOOL isClassMethod;
@end

@interface RTSelector : NSObject {
	Selector _selector;
}
@property (nonatomic, assign) id owner;
//+ (instancetype)selectorWithSelector:(Selector)selector;
+ (instancetype)selectorWithSelector:(Selector)selector andOwner:(id)owner;
//- (instancetype)initWithSelector:(Selector)selector;
- (instancetype)initWithSelector:(Selector)selector andOwner:(id)owner;
- (Selector)internalSelector;
@end

@interface RTProtocol : NSObject {
	Protocol *_protocol;
}
+ (instancetype)protocolWithProtocol:(Protocol *)protocol;
- (instancetype)initWithProtocol:(Protocol *)protocol;
- (Protocol *)internalProtocol;
@end

@interface RTObject : NSObject {
	NSObject *_object;
}
+ (instancetype)objectWithObject:(NSObject *)object;
- (instancetype)initWithObject:(NSObject *)object;
- (NSObject *)internalObject;
@end

@interface RTRuntime : NSObject
+ (NSArray *)classes;
+ (NSArray *)classesConformingToProtocol:(Protocol *)protocol;
+ (RTClass *)lookUpClass:(NSString *)name;
+ (RTClass *)classNamed:(NSString *)name;
+ (RTClass *)metaClassNamed:(NSString *)name;
+ (RTClass *)ZeroLink;
+ (NSArray *)protocols;
+ (NSArray *)imageNames;
+ (NSArray *)classNamesForImage:(NSString *)image;
+ (id)loadWeak:(id *)address;
+ (id)storeWeak:(id *)address object:(id)object;
+ (NSString *)typeForEncoding:(NSString *)enc varName:(NSString *)varName;
+ (AssociationPolicy)associationPolicyWithName:(NSString *)policyName;
@end
