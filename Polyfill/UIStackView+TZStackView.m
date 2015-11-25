//
//  UIStackView+TZStackView.m
//
//  Created by Frederic Barthelemy on 9/9/15.
//

#import <objc/runtime.h>

#import "FitStar-Swift.h"
#import "UIStackView+TZStackView.h"

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= __IPHONE_9_0
#error UIStackView+TZStackView Polyfill is no longer required! Remove these files. Congratulations!
#endif

@implementation _polyfill_UIStackView

+ (instancetype)alloc {
	// Actually pick the best StackView implementation:
	return [NSClassFromString(@"UIStackView") alloc] ?: [TZStackView alloc];
}

#pragma mark - Polyfill Stubs
- (instancetype)initWithArrangedSubviews:(NSArray<__kindof UIView *> *)views FIT_UNAVAILABLE(@"Polyfill Stub",@"You can't actually have an instance of this object.");
- (void)addArrangedSubview:(UIView *)view FIT_UNAVAILABLE(@"Polyfill Stub",@"You can't actually have an instance of this object.");
- (void)removeArrangedSubview:(UIView *)view FIT_UNAVAILABLE(@"Polyfill Stub",@"You can't actually have an instance of this object.");
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex FIT_UNAVAILABLE(@"Polyfill Stub",@"You can't actually have an instance of this object.");
@end
