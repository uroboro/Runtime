#import "Runtime.h"

typedef enum RTVarType {
	RTVarTypePrimitive,
	RTVarTypeBitfield,
	RTVarTypeArray,
	RTVarTypeStruct,
	RTVarTypeUnion,
	RTVarTypePointer,
	RTVarTypeUnknown,
	RTVarTypeProperty,
	RTVarTypeNone
} RTVarType;

typedef enum RTStructMode {
	RTStructModeField,
	RTStructModeType,
	RTStructModeNone
} RTStructMode;

NSArray *rtTypeForStructEncoding_(NSString *encodingString, NSString *varName, NSUInteger number);
NSArray *rtTypeForStructEncoding(NSString *encodingString, NSString *varName) {
	return rtTypeForStructEncoding_(encodingString, varName, 0);
}

NSString *rtTypeForEncoding_(NSString *encodingString, NSString *varName, NSUInteger number);
NSString *rtTypeForEncoding(NSString *encodingString, NSString *varName) {
	NSString *removableIdentifier = @"$$$$$$";
	varName = varName.length > 0 ? varName : removableIdentifier;
	NSString *typedString = rtTypeForEncoding_(encodingString, varName, 0);
	typedString = [typedString stringByReplacingOccurrencesOfString:removableIdentifier withString:@""];
	return typedString;
}

NSArray *rtTypeForStructEncoding_(NSString *encodingString, NSString *varName, NSUInteger number) {
	char *encoding = strdup(encodingString.UTF8String);
	int encodingLength = strlen(encoding);

	NSArray *typedArray = nil;
	NSString *typedString = nil;
	RTStructMode mode = RTStructModeNone;

	char *fieldString = calloc(strlen(encoding), sizeof(char));
	if (fieldString == NULL) {
		goto fieldStringLabel;
	}
	int fieldStringIndex = 0;

	char *typeString = calloc(strlen(encoding), sizeof(char));
	if (typeString == NULL) {
		goto typeStringLabel;
	}
	int typeStringIndex = 0;

	int escapeLevel = 0;

	char c = -1;
	rLog(@"struct DECODING: START \e[31m%@\e[m", encodingString);
	for (int idx = 0; idx < encodingLength; idx++) {
		c = encoding[idx];
		switch (mode) {
		case RTStructModeField:
			switch (c) {
			case '"':
				mode = RTStructModeType;
				memset(typeString, 0, typeStringIndex);
				typeStringIndex = 0;
				break;
			default:
				fieldString[fieldStringIndex++] = c;
				break;
			}
			break;

		case RTStructModeType:
			switch (c) {
			case '"':
				if (escapeLevel > 0) {
					typeString[typeStringIndex++] = c;
				} else {
					mode = RTStructModeField;
					typedString = rtTypeForEncoding_(@(typeString), @(fieldString), number);
					typedArray = typedArray ? [typedArray arrayByAddingObject:typedString] : @[typedString];
					memset(fieldString, 0, fieldStringIndex);
					fieldStringIndex = 0;
				}
				break;
			case '[':
			case '{':
			case '(':
				escapeLevel++;
				typeString[typeStringIndex++] = c;
				break;
			case ']':
			case ')':
			case '}':
				escapeLevel--;
				typeString[typeStringIndex++] = c;
				break;
			default:
				typeString[typeStringIndex++] = c;
				break;
			}
			break;

		default:
		case RTStructModeNone:
			switch (c) {
			case '"':
				mode = RTStructModeField;
				break;

			case '[':
			case '{':
			case '(':
				if (escapeLevel == 0) {
					if (typeStringIndex > 0) {
						typedString = rtTypeForEncoding_(@(typeString), nil, number++);
						typedArray = typedArray ? [typedArray arrayByAddingObject:typedString] : @[typedString];
					}
					memset(typeString, 0, typeStringIndex);
					typeStringIndex = 0;
				}
				escapeLevel++;
				typeString[typeStringIndex++] = c;
				break;

			case ']':
			case ')':
			case '}':
				escapeLevel--;
				typeString[typeStringIndex++] = c;
				if (escapeLevel == 0) {
					typedString = rtTypeForEncoding_(@(typeString), nil, number++);
					typedArray = typedArray ? [typedArray arrayByAddingObject:typedString] : @[typedString];
					memset(typeString, 0, typeStringIndex);
					typeStringIndex = 0;
				}
				break;

			default:
				typeString[typeStringIndex++] = c;
				break;
			}
			break;
		}
	}

	// Add remaining type
	if (fieldStringIndex != 0 || typeStringIndex != 0) {
		typedString = rtTypeForEncoding_(@(typeString), @(fieldString), number);
		typedArray = typedArray ? [typedArray arrayByAddingObject:typedString] : @[typedString];
	}
	rLog(@"struct DECODING: END");
	free(typeString);
	goto typeStringLabel; typeStringLabel:;

	free(fieldString);
	goto fieldStringLabel; fieldStringLabel:;

	return typedArray;
}

NSString *rtTypeForEncoding_(NSString *encodingString, NSString *varName, NSUInteger number) {
	char *encoding = strdup(encodingString.UTF8String);
	int encodingLength = strlen(encoding);

	NSString *typedString = nil;

	RTVarType varType = RTVarTypeNone;

	NSUInteger arrayNumber = 0;
	BOOL arrayStringEnded = NO;

	NSUInteger bitfieldNumber = 0;
	BOOL bitfieldStringEnded = NO;

	char *structName = calloc(strlen(encoding), sizeof(char));
	if (structName == NULL) {
		goto structNameLabel;
	}
	int structNameIndex = 0;
	BOOL structStringEnded = NO;

	char *unionName = calloc(strlen(encoding), sizeof(char));
	if (unionName == NULL) {
		goto unionNameLabel;
	}
	int unionNameIndex = 0;
	BOOL unionStringEnded = NO;

#define className unionName
#define classNameIndex unionNameIndex

#define protocolName structName
#define protocolNameIndex structNameIndex

	BOOL isDecodingSubstring = NO;
	BOOL isDecodingProtocol = NO;

	NSDictionary *varTypes = @{
		@"c":@"char",
		@"i":@"int",
		@"s":@"short",
		@"l":@"long",
		@"q":@"long long",
		@"C":@"unsigned char",
		@"I":@"unsigned int",
		@"S":@"unsigned short",
		@"L":@"unsigned long",
		@"Q":@"unsigned long long",
		@"f":@"float",
		@"d":@"double",
		@"B":@"bool",
		@"v":@"void",
		@"*":@"char *",
		@"@":@"id",
		@"#":@"Class",
		@":":@"SEL"
	};

	#if 0
	NSDictionary *methodTypes = @{
		@"r":@"const",
		@"n":@"in",
		@"N":@"inout",
		@"o":@"out",
		@"O":@"bycopy",
		@"R":@"byref",
		@"V":@"oneway"
	};
	#endif
	NSString *internalType = nil;
	NSArray *internalStructTypeArray = nil;

	char c = -1;
	rLog(@"type ENCODING: START \e[31m%@\e[m \e[36m%@\e[m", encodingString, varName);
	for (int idx = 0; idx < encodingLength; idx++) {
		c = encoding[idx];
		switch (varType) {
		case RTVarTypeNone:
			switch (c) {
			case '^': // Pointer
				varType = RTVarTypePointer;
				rLog(@"pointer to");
				break;
			case '?': // Unknown
				varType = RTVarTypeUnknown;
				rLog(@"unknown");
				break;
			case 'b': // Bitfield
				varType = RTVarTypeBitfield;
				rLog(@"bit field");
				break;
			case '[': // Array
				varType = RTVarTypeArray;
				rLog(@"array start");
				break;
			case '{': // Struct
				varType = RTVarTypeStruct;
				rLog(@"struct start");
				break;
			case '(': // Union
				varType = RTVarTypeUnion;
				rLog(@"union start");
				break;
			case 'T': // Property
				varType = RTVarTypeProperty;
				rLog(@"property");
				break;
			default : // Primitive
				varType = RTVarTypePrimitive;
				rLog(@"%@", varTypes[@( ({char s[2] = {c, 0}; s;}) )]);
				break;
			}
			break;

		case RTVarTypeBitfield:
			if (!isdigit(c)) {
				if (!bitfieldStringEnded) {
					rLog(@"B:::%lu", (unsigned long)bitfieldNumber);
				}
				bitfieldStringEnded = YES;
			} else if (!bitfieldStringEnded) {
				bitfieldNumber = bitfieldNumber * 10 + c - '0';
			} else {
				//rLog(@"X");
			}
			break;

		case RTVarTypeArray:
			if (!isdigit(c)) {
				if (!arrayStringEnded) {
					rLog(@"A::[%lu]", (unsigned long)arrayNumber);
				}
				arrayStringEnded = YES;
				if (!isDecodingSubstring) {
					isDecodingSubstring = YES;
					internalType = rtTypeForEncoding_([encodingString substringWithRange:NSMakeRange(idx, encodingLength - idx - 1)], varName, number);
					rLog(@"A::\e[34m%@\e[m", [internalType stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[34m"]);
				}
			} else if (!arrayStringEnded) {
				arrayNumber = arrayNumber * 10 + c - '0';
			} else {
				//rLog(@"X");
			}
			break;

		case RTVarTypeStruct:
			if (c == '=') {
				structStringEnded = YES;
				rLog(@"S::{%s}", structName);
			} else if (!structStringEnded) {
				structName = realloc(structName, (structNameIndex + 1) * sizeof(char));
				structName[structNameIndex++] = c;
			} else {
				if (!isDecodingSubstring) {
					isDecodingSubstring = YES;
					internalStructTypeArray = rtTypeForStructEncoding_([encodingString substringWithRange:NSMakeRange(idx, encodingLength - idx - 1)], varName, number);
					rLog(@"S::\e[34m%@\e[m", [internalStructTypeArray.description stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[34m"]);
				}
			}
			break;

		case RTVarTypeUnion:
			if (c == '=') {
				unionStringEnded = YES;
				rLog(@"U::(%s)", unionName);
			} else if (!unionStringEnded) {
				unionName = realloc(unionName, (unionNameIndex + 1) * sizeof(char));
				unionName[unionNameIndex++] = c;
			} else {
				if (!isDecodingSubstring) {
					isDecodingSubstring = YES;
					internalStructTypeArray = rtTypeForStructEncoding_([encodingString substringWithRange:NSMakeRange(idx, encodingLength - idx - 1)], varName, number);
					rLog(@"U::\e[34m%@\e[m", [internalStructTypeArray.description stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[34m"]);
				}
			}
			break;

		case RTVarTypePointer:
			internalType = rtTypeForEncoding_([encodingString substringWithRange:NSMakeRange(idx, encodingLength - idx)], varName, number);
			idx = encodingLength;
			rLog(@"P::\e[34m%@\e[m", [internalType stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[34m"]);
			break;

		case RTVarTypeUnknown:
			rLog(@"u::\e[34m%@\e[m", @"¯\\_(ツ)_/¯");
			break;
		case RTVarTypeProperty:
			internalType = rtTypeForEncoding_([encodingString substringWithRange:NSMakeRange(idx, encodingLength - idx)], varName, number);
			rLog(@"A::\e[34m%@\e[m", [internalType stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[34m"]);
			idx = encodingLength;
			break;

		case RTVarTypePrimitive:
			if (c == '"') {
				if (!isDecodingSubstring) {
					isDecodingSubstring = YES;
					rLog(@"C started class type");
				} else {
					isDecodingSubstring = NO;
					rLog(@"C (%s)", className);
					rLog(@"C stopped class type");
				}
			} else if (c == '<' || c == '>') {
				if (!isDecodingProtocol) {
					isDecodingProtocol = YES;
					rLog(@"C started protocol type");
				} else {
					isDecodingProtocol = NO;
					rLog(@"P (%s)", structName);
					rLog(@"C stopped protocol type");
				}
			} else {
				if (isDecodingSubstring && !isDecodingProtocol) {
					className = realloc(className, (classNameIndex + 1) * sizeof(char));
					className[classNameIndex++] = c;
				} else {
					protocolName = realloc(protocolName, (protocolNameIndex + 1) * sizeof(char));
					protocolName[protocolNameIndex++] = c;
				}
			}
			break;

		default:
			rLog(@"X (%c)", c);
		} // type switch
	} // for loop
	rLog(@"type ENCODING: END");

	// Decide output formatting
	switch (varType) {
		case RTVarTypePrimitive:
			internalType = (classNameIndex == 0) ? varTypes[encodingString] : (protocolNameIndex == 0) ? [NSString stringWithFormat:@"%s *", className] : [NSString stringWithFormat:@"%s<%s> *", className, protocolName];
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"%@ $%lu", internalType, (unsigned long)number];
			} else {
				typedString = [NSString stringWithFormat:@"%@ %@", internalType, varName];
			}
			break;

		case RTVarTypeBitfield:
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"char $%lu:%lu", (unsigned long)number, (unsigned long)bitfieldNumber];
			} else {
				typedString = [NSString stringWithFormat:@"char %@:%lu", varName, (unsigned long)bitfieldNumber];
			}
			break;

		case RTVarTypeArray:
			rLog(@"A::\e[31m%@\e[m as internalType", internalType);
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"$%lu[%lu]", (unsigned long)number, (unsigned long)arrayNumber];
				typedString = [internalType stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"$%lu", (unsigned long)number] withString:typedString];
			} else {
				typedString = [NSString stringWithFormat:@"%@[%lu]", varName, (unsigned long)arrayNumber];
				typedString = [internalType stringByReplacingOccurrencesOfString:varName withString:typedString];
				rLog(@"%@", typedString);
			}
			break;

		case RTVarTypeStruct:
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"struct %s { %@; }", structName, [internalStructTypeArray componentsJoinedByString:@"; "]];
			} else {
				typedString = [NSString stringWithFormat:@"struct %s { %@; } %@", structName, [internalStructTypeArray componentsJoinedByString:@"; "], varName];
			}
			break;

		case RTVarTypeUnion:
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"union %s { %@; }", unionName, [internalStructTypeArray componentsJoinedByString:@"; "]];
			} else {
				typedString = [NSString stringWithFormat:@"union %s { %@; } %@", unionName, [internalStructTypeArray componentsJoinedByString:@"; "], varName];
			}
			break;

		case RTVarTypePointer:
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"%@ *", internalType];
			} else {
				typedString = [NSString stringWithFormat:@"*%@", varName];
				typedString = [internalType stringByReplacingOccurrencesOfString:varName withString:typedString];
				rLog(@"%@", typedString);
				//typedString = [NSString stringWithFormat:@"%@ *%@", internalType, varName];
			}
			break;

		case RTVarTypeUnknown:
			if (varName == nil) {
				typedString = [NSString stringWithFormat:@"/* fp */ void *(*)(void *)"];
			} else {
				typedString = [NSString stringWithFormat:@"/* fp */ void *(%@)(void *)", varName];
			}
			break;

		case RTVarTypeProperty:
			if (varName == nil) {
				typedString = [NSString stringWithString:internalType];
			} else {
				typedString = [NSString stringWithFormat:@"%@ %@", internalType, varName];
			}
			break;

		default:
			break;
	}

	free(encoding);
	goto encodingLabel; encodingLabel:;

#undef className
#undef classNameIndex

#undef protocolName
#undef protocolNameIndex

	free(unionName);
	goto unionNameLabel; unionNameLabel:;

	free(structName);
	goto structNameLabel; structNameLabel:;

	rLog(@"==> \e[32m%@\e[m", [typedString stringByReplacingOccurrencesOfString:@"\e[m" withString:@"\e[m\e[32m"]);
	return typedString;
}
