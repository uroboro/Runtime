#import "Runtime.h"

@interface RTPropertyAttribute : NSObject
@property (nonatomic) PropertyAttribute internalPropertyAttribute;
+ (instancetype)propertyAttributeWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
- (instancetype)initWithPropertyAttribute:(PropertyAttribute)propertyAttribute;
@end
