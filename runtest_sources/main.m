#include <dlfcn.h>
#import <Runtime.h>
#import <RT_Runtime.h>

@protocol XYZProtocol
- (void)aMethod;
@end

#if 0
#import "inc_short.h"
@implementation XYZClass
- (void)aMethod {
}
@end
#else
#import "inc_long.h"
@implementation XYZClass
- (void)aMethod {
	rLog(@"I got called");
}
- (void)aMethodWithArg:(id)arg {
	rLog(@"I got called with arg: %@", [arg description]);
}
- (int *)aMethodWithArg:(id)arg0 andArg:(int[2])arg1 {
	rLog(@"I got called with arg0:%@ and arg1:%d", [arg0 description], arg1[0]);
	static int a[2] = { 0, 1 };
	return a;
}
@end
#endif
//#define $ctor __attribute__((constructor)) static void ctor ## __LINE__ (int argc, char **argv, char **envp)
//$ctor { rLog(@"ctor	loading"); }
//%dtor { rLog(@"dtor unloading"); }

int main(int argc, char **argv, char **envp, char **apple) {
	@autoreleasepool {
		if (argc < 2) {
			return 1;
		}

		char str[256];
		strcpy(str, argv[1]);
		strcat(str, "/Runtime.dylib");
		printf("string: %s\n", str);
		void * dylib = dlopen(str, RTLD_NOW);

		Class RTRuntime = objc_getClass("RTRuntime");
		for (NSString * imageName in [RTRuntime imageNames]) {
			printf("%s:\n[ %s ]\n", imageName.UTF8String, [[RTRuntime classNamesForImage:imageName] componentsJoinedByString:@", "].UTF8String);
		}

		/*printf("\n\e[36m%s\e[m\n", [[objc_getClass("RTClass") classWithClass:NSString.class] description].UTF8String);*/

		dlclose(dylib);
	}

	return 0;
}
