# TZStackView [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)
A wonderful layout component called the [`UIStackView` was introduced with *iOS 9*](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/). With this component it is really easy to layout components in a row both horizontally and vertically. Apple recommends using the `UIStackView` wherever possible and resort to explicit `NSLayoutConstraints` only when there is no way to do it with `UIStackView`. This saves you lots of boiler plate `NSLayoutConstraint` creation code.

`UIStackView` requires *iOS 9*, but we're not ready to make our apps require *iOS 9+* just yet. In the meanwhile, we developers are eager to try this component in our apps right now! This is why I created this replica of the `UIStackView`, called the `TZStackView` (TZ = Tom van Zummeren, my initials). I created this component very carefully, tested every single corner case and matched the results against the *real* `UIStackView` with automated `XCTestCases`.

## Features
- ✅ Compatible with **iOS 7.x** and **iOS 8.x**
- ✅ Supports the complete API of `UIStackView` including **all** *distribution* and *alignment* options
- ✅ Supports animating the `hidden` property of the *arranged subviews*
- ✅ Optional [Polyfill](#polyfill) for Objective-C code to use the name UIStackView, while dynamically selecting TZStackView when on earlier iOS versions.
- ❌ Supports *Storyboard*

So this implementation does **not** support Storyboard. It is meant for iOS developers who, like me, want to use the `UIStackView` in our existing apps and like to layout their components in code as opposed to using *Storyboard*.

## Setup
You basically have two options to include the `TZStackView` in your *Xcode* project:

### Use [Cocoapods](http://cocoapods.org/)
Example `Podfile`:
```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, "8.0"
use_frameworks!

pod "TZStackView", "1.1.2"
```
Unfortunately, using Cocoapods with a Swift pod requires iOS 8.

### Use [Carthage](https://github.com/Carthage/Carthage)

Example `Cartfile`:
```
github "tomvanzummeren/TZStackView" ~> 1.1
```

Run `carthage` to build the framework and drag the built `TZStackView.framework` into your Xcode project.

### Drag files directly into your project
Alternatively (when you do want to support iOS 7) drag in the following classes from the *Example* folder directly into your *Xcode* project
  * `TZStackView`
  * `TZSpacerView`
  * `TZStackViewAlignment`
  * `TZStackViewDistribution`

## Example usage
Given `view1`, `view2` and `view3` who have intrinsic content sizes set to *100x100*, *80x80* and *60x60* respectively.

```swift
let stackView = TZStackView(arrangedSubviews: [view1, view2, view3])
stackView.distribution = .FillEqually
stackView.alignment = .Center
stackView.axis = .Vertical
stackView.spacing = 25
```

This would produce the following layout:

![TZStackView Layout example](/assets/layout-example.png)

See the [developer documentation for `UIStackView`](https://developer.apple.com/library/prerelease/ios/documentation/UIKit/Reference/UIStackView_Class_Reference/) for all other combinatins of distributions, alignments and axis. `TZStackView` works and behaves exactly the same way as the `UIStackView` except for not supporting Storyboard. If you do find a case where it does not behave the same way, please file a bug report.

To animate adding a view to or removing a view from the arranged subviews, simply hide or show them by adjusting the `hidden` property within an animation block (as described by the `UIStackView` reference docs as well):

```swift
UIView.animateWithDuration(0.5, animations: {
	self.view2.hidden = true
})
```
![TZStackView hidden animation example](/assets/TZStackView-hide-animation.gif)

## Polyfill
(Objective-C only)

If you're writing code with Objective-C, and you want to dynamically select UIStackView over TZStackView when on iOS versions that provide it, check out [UIStackView+TZStackView](./Polyfill/)

If you include these files in your project, and include the header in your Prefix.pch, along with TZStackView [see Setup](#setup) you to will be able to type `UIStackView` and have the code dynamically select the right class to fulfill your needs.

If you go down this route, you don't have to do anything to migrate to UIStackView, but to remove TZStackView.

Example:
```objc
UIStackView * stack = [[UIStackView alloc] initWithArrangedSubviews:@[/*…*/]];
````

More documentation in [UIStackView+TZStackView.h](./Polyfill/TZStackView.h)

## Migrating to UIStackView
If at a later point you decide to make *iOS 9* the minimum requirement of your app (it will happen sooner or later), you will want to migrate to the real `UIStackView` instead of using this implementation. Because the `TZStackView` is a drop-in replacement for `UIStackView`, you simply replace:

```swift
let stackView = TZStackView(arrangedSubviews: views)
```

with ...

```swift
let stackView = UIStackView(arrangedSubviews: views)
```

... and you're good to go! You will not need to make any other changes and everything will simply work the way it worked before.

## License
TZStackView is released under the MIT license. See LICENSE for details.
