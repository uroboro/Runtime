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

@interface RTClass : NSObject
@property (nonatomic) Class internalClass;
+ (instancetype)classWithClass:(Class)cls;
- (instancetype)initWithClass:(Class)cls;
- (RTIvar *)getInstanceVariableWithName:(NSString *)name;
@end

@interface RTIvar : NSObject
@property (nonatomic) Ivar internalIvar;
@property (nonatomic, assign) id owner;
+ (instancetype)ivarWithIvar:(Ivar)ivar andOwner:(id)owner;
- (instancetype)initWithIvar:(Ivar)ivar andOwner:(id)owner;

- (NSString *)name;
- (NSString *)type;
- (NSString *)typeWithName:(NSString *)name;
@end

@interface RTProperty : NSObject
@property (nonatomic) Property internalProperty;
@property (nonatomic, assign) id owner;
+ (instancetype)propertyWithProperty:(Property)property andOwner:(id)owner;
- (instancetype)initWithProperty:(Property)property andOwner:(id)owner;

- (NSString *)backingIvar;
- (NSString *)getter;
- (NSString *)setter;
@end

@interface RTPropertyAttribute : NSObject
@property (nonatomic) PropertyAttribute internalPropertyAttribute;
+ (instancetype)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (instancetype)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
@end

@interface RTMethod : NSObject
@property (nonatomic) Method internalMethod;
@property (nonatomic, assign) id owner;
+ (instancetype)methodWithMethod:(Method)method andOwner:(id)owner;
- (instancetype)initWithMethod:(Method)method andOwner:(id)owner;

- (NSString *)name;
@property (nonatomic, assign) BOOL isClassMethod;
@end

@interface RTSelector : NSObject
@property (nonatomic) Selector internalSelector;
@property (nonatomic, assign) id owner;
+ (instancetype)selectorWithSelector:(Selector)selector andOwner:(id)owner;
- (instancetype)initWithSelector:(Selector)selector andOwner:(id)owner;
@end

@interface RTProtocol : NSObject
@property (nonatomic, assign) Protocol * internalProtocol;
+ (instancetype)protocolWithProtocol:(Protocol *)protocol;
- (instancetype)initWithProtocol:(Protocol *)protocol;
@end

@interface RTObject : NSObject
@property (nonatomic,assign) NSObject * internalObject;
+ (instancetype)objectWithObject:(NSObject *)object;
- (instancetype)initWithObject:(NSObject *)object;
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
