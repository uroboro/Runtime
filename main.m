#include <dlfcn.h>
#import "sources/Runtime.h"

@protocol XYZProtocol
- (void)aMethod;
@end

#if 0
@interface XYZClass : NSObject
@property (nonatomic, assign) union thong1 { int II:4; int B[2]; } thung1;
@end
typedef union thong1 { int II:4; int B[2][3]; } thong1;
@implementation XYZClass
- (thong1)noop:(thong1)thung1 {
	return thung1;
}
@end
#else
@interface XYZClass : NSObject <XYZProtocol> {
	int **I[9];
	void *(*P)(int, char *);
	CGFloat CGF[3];
	CGFloat asdf[2][3][4];
	union ting { long L; char C[4]; struct hongs { char C:4; int B[2]; } hongs; } tong;
	struct thing { void *(*P[2])(); int I; } thang;
	union thongs { char C:4; int B[2]; } thungs[9875];
}
@property char c;
@property (nonatomic, retain) id object;
@property (nonatomic, assign) union thong1 { int II:4; int B[2]; } thung1;
@property (nonatomic, assign) union thong2 { int B[2]; char C:4; } thung2;
@property (nonatomic, assign) struct thing3 { int I; } thang3;
@property (atomic, assign, getter=isOtherObject, setter=otherObjectIs:) BOOL otherObject;
- (void)aMethodWithArg:(id)arg;
- (int *)aMethodWithArg:(id)arg0 andArg:(int[2])arg1;
- (void)aMethod;
@end
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

int main() {
	dlopen(".theos/obj/Runtime.dylib", RTLD_NOW);

	@autoreleasepool {
		NSLog(@"\n\e[36m%@\e[m", [[objc_getClass("RTClass") classWithClass:XYZClass.class] description]);
	}

	return 0;
}
