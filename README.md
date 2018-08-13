<img src="https://github.com/gametimesf/GTSheet/blob/master/sample.png" width="160">

# GTSheet
GTSheet is a a simple, easy to integrate solution for presenting `UIViewController` in bottom sheet. We handle all the hard work for you-- transitions, gestures, taps and more are all automatically provided by the library. Styling, however, is intentionally left out, allowing you to integrate your own design language with ease.

## Installation

[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)

### Carthage

    github "gametimesf/GTSheet" == 1.1

## Getting Started

The example project included is a great way to try out the features of GTSheet and experiment with some of the more advanced functionality. You can explore integrations for regular a `UIViewController`, a `UIViewController` that includes a `UIScrollView`, such as a `UITableViewController`. You can also explore a more complex example, using functionality to present a `UIViewController` above the bottom sheet.

### Simple Integration
Getting started is easy. You'll need to conform to at least one protocol on the presented `UIViewController`. An optional protocol for your presented `UIViewController` makes presenting a bottom sheet faster and easier.
#### Required: `HalfSheetPresentableProtocol`
Implement `HalfSheetPresentableProtocol` on the `UIViewController` that you will be presenting in a bottom sheet. 

```swift
public protocol HalfSheetPresentableProtocol: class {
    weak var managedScrollView: UIScrollView? { get }
    var dismissMethod: [DismissMethod] { get }
    var sheetHeight: CGFloat? { get }
}
public extension HalfSheetPresentableProtocol where Self: UIViewController {
    func didUpdateSheetHeight()
}
```

1.) `managedScrollView` provides a scroll view that will be used to trigger dismissal transitions. For example, a `UITableViewController` should return it's `tableView` property here.

2.) `dismissMethod` provides an array of `DismissMethod` options, such as `.swipe`, `.tap`. You may return all, some, or none of these options. When returning an empty set, you will be responsible for dismissing your own `UIViewController`.  

3.) `sheetHeight` provides the height you would like your bottom sheet to be. `UIScrollView` subviews will overflow and scroll as expected. On iOS 11, `Safe Area` insets are automatically respected for you, and added to the total height you return. All `HalfSheetPresentableProtocol` conforming `UIViewControllers` are extended with a `didUpdateSheetHeight` method, which should be called to let the library know that it needs to adjust the height of your bottom sheet.    

#### Optional: `HalfSheetPresentingProtocol`
Although you can manually instantiate `HalfSheetPresentationManager` and assign it as your `HalfSheetPresentableProtocol`'s `transitioningDelegate`, conforming to `HalfSheetPresentingProtocol` gives your presenting `UIViewController` several convenience methods for presenting `UIViewControllers` in a bottom sheet.

```swift
public protocol HalfSheetPresentingProtocol: class {
    var transitionManager: HalfSheetPresentationManager! { get set }
}

public extension HalfSheetPresentingProtocol where Self: UIViewController {
    func presentUsingHalfSheet(_ vc: UIViewController, animated: Bool = true)
    @discardableResult func presentUsingHalfSheetInNC(_ vc: UIViewController, animated: Bool = true) -> UINavigationController
}

```

### Advanced Features
#### `HalfSheetCompletionProtocol`
Implement this on your presenting `UIViewController` to receive a callback when your bottom sheet is dismissed.
#### `HalfSheetAppearanceProtocol`
Although most styling can be accomplished by using `UIAppearance`, some advanced changes are simply not possible. This protocol exposes additional styling options that will be handled within the library.
#### `HalfSheetTopVCProviderProtocol`
By conforming to this protocol on your presented `UIViewController`, you are able to provide a `UIViewController` that will fill the unused space above your bottom sheet.
