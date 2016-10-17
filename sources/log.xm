%hookf(void, NSLogv, NSString *format, va_list args) {
}

%hookf(void, CFLog, int32_t lev, CFStringRef format, ...) {
}

%ctor {
	NSArray * blacklist = @[@"BlueTool"];
	if (![blacklist containsObject:NSBundle.mainBundle.bundleIdentifier]) {
		%init;
	}
}
