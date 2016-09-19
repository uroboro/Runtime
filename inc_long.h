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
@property id<XYZProtocol> *QuantumThang;
@property (retain) XYZClass<XYZProtocol> *QuantumThing;
@property (copy) XYZClass *QuantumThong;
- (void)aMethodWithArg:(id)arg;
- (int *)aMethodWithArg:(id)arg0 andArg:(int[2])arg1;
- (void)aMethod;
@end