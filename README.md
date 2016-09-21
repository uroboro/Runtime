# Runtime
Objective-C runtime access in Objective-C

For use with Cycript.

Currently can read this:

``` objc
@protocol XYZProtocol
- (void)aMethod;
@end
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
```

Into this:
```objc
@interface XYZClass <XYZProtocol> {
    int **I[9];
    /* fp */ void *(**P)(void *);
    float CGF[3];
    float asdf[2][3][4];
    union ting { long L; char C[4]; struct hongs { char C:4; int B[2]; } hongs; } tong;
    struct thing { /* fp */ void *(**P[2])(void *); int I; } thang;
    union thongs { char C:4; int B[2]; } thungs[9875];
}
@property (assign) char c;
@property (nonatomic, retain) id object;
@property (nonatomic, assign) union thong1 { char II:4; int B[2]; } thung1;
@property (nonatomic, assign) union thong2 { int B[2]; char C:4; } thung2;
@property (nonatomic, assign) struct thing3 { int I; } thang3;
@property (assign, getter=isOtherObject, setter=otherObjectIs:) char otherObject;
- (void)aMethod;
- (void)aMethodWithArg:(id)arg0;
- (int *)aMethodWithArg:(id)arg0 andArg:(int [2])arg1;
@end
```
