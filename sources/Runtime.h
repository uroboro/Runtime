//https://developer.apple.com/reference/objectivec/objective_c_runtime
#include <objc/runtime.h>

#define LOG_STUFF 01
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

typedef struct objc_property * Property;
typedef objc_property_attribute_t * PropertyAttribute;
typedef struct objc_method_description MethodDescription;
typedef SEL Selector;
typedef IMP Implementation;
typedef objc_AssociationPolicy AssociationPolicy;

@interface NSString (indexCategory)
- (NSString *)objectAtIndexedSubscript:(NSInteger)idx;
@end
