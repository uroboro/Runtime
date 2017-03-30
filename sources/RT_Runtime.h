#import "RTDecoding.h"
#import "RTClass.h"
#import "RTIvar.h"
#import "RTProperty.h"
#import "RTPropertyAttribute.h"
#import "RTMethod.h"
#import "RTSelector.h"
#import "RTProtocol.h"
#import "RTObject.h"

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
