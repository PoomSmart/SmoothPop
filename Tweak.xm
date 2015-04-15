#import "../PS.h"

@interface UIKBTree : NSObject
@property NSInteger type;
- (BOOL)_renderAsStringKey;
@end

NSInteger popupState = 4;
NSInteger normalState = 2;

%hook UIKBTree

- (BOOL)canFadeOutFromState:(NSInteger)fromState toState:(NSInteger)toState
{
	BOOL stateOk = (fromState == popupState || fromState == normalState) && (toState == popupState || toState == normalState);
	BOOL isCharacter = [self _renderAsStringKey];
	return stateOk && isCharacter ? YES : %orig;
}

%end
