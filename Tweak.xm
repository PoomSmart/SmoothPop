#import "../PS.h"

@interface UIKBTree : NSObject
@property NSInteger type;
- (NSString *)name;
@end

NSInteger popupState = 4;
NSInteger normalState = 2;

NSArray *whitelist()
{
	return @[@"International-Key", @"Delete-Key", @"Return-Key", @"Shift-Key", @"More-Key", @"Dictation-Key", @"Space-Key"];
}

%hook UIKBTree

- (BOOL)canFadeOutFromState:(NSInteger)fromState toState:(NSInteger)toState
{
	BOOL stateOk = (fromState == popupState || fromState == normalState) && (toState == popupState || toState == normalState);
	BOOL notInList = ![whitelist() containsObject:self.name];
	return stateOk && notInList ? YES : %orig;
}

%end
