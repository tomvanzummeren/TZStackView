//
//  UIStackView+TZStackView.h
//
//  Created by Frederic Barthelemy on 9/9/15.
//

#import <UIKit/UIKit.h>

// You probably want the real UIStackView!
#import <UIKit/UIStackView.h>

// Define a preprocessor macro to coopt all your references to UIStackView with this class.
#define UIStackView _polyfill_UIStackView

/**
 This class is a polyfill. Go look at UIStackView.h or TZStackView.swift for implementation details.
 
 Usage: Include this in your Prefix.pch, and use UIStackView * everywhere as if you were on iOS 9.0
 
 This class works by overriding +(instancetype)alloc to dynamically alloc the appropriate class.
 Additionally it defines a PreProcessor macro that will replace all your uses of UIStackView with this class.
 
 @warning: Dynamic tricks like NSStringFromClass([UIStackView class]) will probably not do what you want. Also, the only supported class method is `alloc`.
 
 All methods defined here are simply stubs to silence the compiler, since you can't ever alloc an instance of this.
 */
@interface _polyfill_UIStackView : UIView

#pragma mark - Everything below here is copied in from UIStackView.h -

/* UIStackView enforces that all views in the arrangedSubviews list
 must be subviews of the UIStackView.
 Thus, when a view is added to the arrangedSubviews, UIStackView
 adds it as a subview if it isn't already. And when a view in a
 UIStackView's arrangedSubviews list receives -removeFromSuperview
 it is also removed from the arrangedSubviews.
 */
- (instancetype)initWithArrangedSubviews:(NSArray<__kindof UIView *> *)views; // Adds views as subviews of the receiver.
@property(nonatomic,readonly,copy) NSArray<__kindof UIView *> *arrangedSubviews;

/* Add a view to the end of the arrangedSubviews list.
 Maintains the rule that the arrangedSubviews list is a subset of the
 subviews list by adding the view as a subview of the receiver if
 necessary.
 Does not affect the subview ordering if view is already a subview
 of the receiver.
 */
- (void)addArrangedSubview:(UIView *)view;

/* Removes a subview from the list of arranged subviews without removing it as
 a subview of the receiver.
 To remove the view as a subview, send it -removeFromSuperview as usual;
 the relevant UIStackView will remove it from its arrangedSubviews list
 automatically.
 */
- (void)removeArrangedSubview:(UIView *)view;
/*
 Adds the view as a subview of the container if it isn't already.
 Updates the stack index (but not the subview index) of the
 arranged subview if it's already in the arrangedSubviews list.
 */
- (void)insertArrangedSubview:(UIView *)view atIndex:(NSUInteger)stackIndex;

/* A stack with a horizontal axis is a row of arrangedSubviews,
 and a stack with a vertical axis is a column of arrangedSubviews.
 */
@property(nonatomic) UILayoutConstraintAxis axis;

/* The layout of the arrangedSubviews along the axis
 */
@property(nonatomic) UIStackViewDistribution distribution;

/* The layout of the arrangedSubviews transverse to the axis;
 e.g., leading/trailing edges in a vertical stack
 */
@property(nonatomic) UIStackViewAlignment alignment;

/* Spacing between adjacent edges of arrangedSubviews.
 Used as a strict spacing for the Fill distributions, and
 as a minimum spacing for the EqualCentering and EqualSpacing
 distributions. Use negative values to allow overlap.
 */
@property(nonatomic) CGFloat spacing;

/* Baseline-to-baseline spacing in vertical stacks.
 The baselineRelativeArrangement property supports specifications of vertical
 space from the last baseline of one text-based view to the first baseline of a
 text-based view below, or from the  top (or bottom) of a container to the first
 (or last) baseline of a contained text-based view.
 This property is ignored in horizontal stacks. Use the alignment property
 to specify baseline alignment in horizontal stacks.
 Defaults to NO.
 */
@property(nonatomic,getter=isBaselineRelativeArrangement) BOOL baselineRelativeArrangement;

/* Uses margin layout attributes for edge constraints where applicable.
 Defaults to NO.
 */
@property(nonatomic,getter=isLayoutMarginsRelativeArrangement) BOOL layoutMarginsRelativeArrangement;
@end
