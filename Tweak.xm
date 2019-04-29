#import "../PS.h"
#import <UIKit/UIKBKeyView.h>
#import <UIKit/UIKBKeyplaneView.h>

NSInteger popupState = 4;
NSInteger normalState = 2;

static BOOL keyNameOk(NSString *keyName) {
    BOOL currency = [keyName rangeOfString:@"Currency-Sign"].location != NSNotFound;
    BOOL tag = [keyName isEqualToString:@"Primary-Tag-Symbol"] || [keyName isEqualToString:@"Alternate-Tag-Symbol"];
    BOOL domain = [keyName isEqualToString:@"Top-Level-Domain-Key"] || [keyName isEqualToString:@"Single-Domain-Key"] || [keyName isEqualToString:@"Email-Dot-Key"];
    return currency || tag || domain;
}

%group iOS9Up

%hook UIKBKeyplaneView

BOOL override;

- (void)deactivateKey:(UIKBTree *)key previousState:(NSInteger)previousState {
    NSInteger fromState = previousState;
    NSInteger toState = key.state;
    BOOL stateOk = (fromState == popupState || fromState == normalState) && (toState == popupState || toState == normalState);
    BOOL isCharacter = [key _renderAsStringKey];
    NSString *keyName = key.name;
    override = stateOk && (isCharacter || keyNameOk(keyName));
    %orig;
    override = NO;
}

%end

%hook UIKBKeyViewAnimator

- (void)_fadeOutKeyView:(UIKBKeyView *)keyView duration:(CGFloat)duration completion: (void **)block {
    %orig(keyView, override ? 0.15 : duration, block);
}

- (void)transitionOutKeyView:(UIKBKeyView *)keyView fromState:(NSInteger)fromState toState:(NSInteger)toState completion:(void **)completion {
    NSInteger interactionType = keyView.key.interactionType;
    if (override)
        keyView.key.interactionType = 0x14;
    %orig(keyView, override ? 5 : fromState, toState, completion);
    keyView.key.interactionType = interactionType;
}

%end

%end

%group iOS78

%hook UIKBTree

- (BOOL)canFadeOutFromState:(NSInteger)fromState toState:(NSInteger)toState {
    BOOL stateOk = (fromState == popupState || fromState == normalState) && (toState == popupState || toState == normalState);
    BOOL isCharacter = [self _renderAsStringKey];
    NSString *keyName = self.name;
    return stateOk && (isCharacter || keyNameOk(keyName)) ? YES : %orig;
}

%end

%end

%group preiOS7

%hook UIKBKeyplaneView

- (void)setState:(NSInteger)state forKey:(UIKBTree *)key {
    BOOL isCharacter = [key renderAsStringKey];
    NSString *keyName = key.name;
    if ((isCharacter || keyNameOk(keyName)) && key.visible) {
        UIView *view = [self viewForKey:key];
        if (state == 4) {
            if (view.alpha != 0.0) {
                [UIView animateWithDuration:0.1 delay:0 options:nil animations:^{
                    view.alpha = 0.0;
                } completion:^(BOOL finished) {
                    if (finished)
                        %orig;
                }];
                return;
            }
        }
    }
    %orig;
}

%end

%end

%ctor {
    if (isiOS9Up) {
        %init(iOS9Up);
    } else if (isiOS7Up) {
        %init(iOS78);
    } else {
        %init(preiOS7);
    }
}
