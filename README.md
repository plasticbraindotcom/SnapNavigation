# SnapNavigation
Composable view navigation for iOS

[![Language: Swift](https://img.shields.io/badge/language-swift-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/then/blob/master/LICENSE)

SnapNavigation provides a comprehensive way to define and handle all iOS application view navigation concerns.

SnapNavigation allows you to separate navigation code into dedicated objects, empowering you to snap together each aspect in any way you see fit: dynamically determining source and destination views, mediation between actors, and presentational code. It works with navigation actions triggered from code as well as from UIStoryboard action segues.

## Quick Start

If you want to skip the details and use SnapNavigation right away, the following example recipes offer some starting points.

<details>
<summary>Basic composable navigation examples</summary>

```swift
import UIKit

// Basic SnapNavigator with no internal navigation logic, just default implementations.
class MyNavigator: SnapNavigator {}

// Some particular view controller in your application.
class MyViewController: UIViewController {

// Create a SnapNavigator that uses only the default implementation methods.
let navigator = MyNavigator()

var someData: String = "Sample data"

// Other code
// …

// Example navigations.
func composableNavigationExamples() {

// Note: Some examples show internal creation of a destination view controller. This is not good practice unless the destination is intended as an internally controlled child view controller.

// Composable navigation example 1:
//  Create a secondary view controller, and show it.
let destinationVC = UIViewController()
navigator.navigate(from: .viewController(self), to: .viewController(destinationVC), with: .show)

// Composable navigation example 2:
//  Create a secondary view controller, pass a value to it via closure and show it.
let destinationWithValueVC = MyViewController()
let mediation2: (UIViewController, UIViewController) -> () = { source, destination in
if let destination = destination as? MyViewController {
destination.someData = "Sent message"
}
}
navigator.navigate(from: .viewController(self), to: .viewController(destinationWithValueVC), applying: .method(mediation2), with: .show)

// Composable navigation example 3:
//  Navigation using a set navigation model, presenting a second VC and passing a value.
let destination3 = MyViewController()
let mediation3: (UIViewController, UIViewController) -> () = { source, destination in
if let destination = destination as? MyViewController {
destination.someData = "Sent message 3"
}
}
let navigation3 = SnapNavigation(
source: .viewController(self),
destination: .viewController(destination3),
mediation: .method(mediation3),
presentation: SnapNavigation.Presentation.present(true, {}))
navigator.navigate(using: navigation3)

// Navigation using provider:
//  Explicitly set the navigator data provider.
//  We set ourself as the data provider in this example. See the SnapNavigatorDataSource extension below.
navigator.navigationProvider = self
navigator.navigate()

}

}
```

</details>

<details>
<summary>Navigation provider example</summary>

```swift

// Navigation using provider:
//  Explicitly set the navigator data provider.
//  We set ourself as the data provider in this example. See the SnapNavigatorDataSource extension below.
navigator.navigationProvider = self
navigator.navigate()

extension MyViewController: SnapNavigatorDataSource {
func navigation(for navigator: SnapNavigator) -> SnapNavigation {
let someDestination = UIViewController()
let someMediation: (UIViewController, UIViewController) -> () = { source, destination in
destination.title = "Honey I Set the Title!"
}
return SnapNavigation(
source: .viewController(self),
destination: .viewController(someDestination),
mediation: .method(someMediation),
presentation: .show)
}
}
```

</details>

<details>
<summary>Navigation with a UIStoryboardSegue</summary>

```swift

//  An example SnapNavigationSegue and SnapNavigationMediator in one.
//  Intended as an example. Not to be used or subclassed.
//
//  Use this approach to define a custom UIStoryboardSegue that uses an [already internally defined] Navigator and an internal mediation method when performing its transition.
//  To implement your own class, copy this class and:
//      - Use a custom unique Class name.
//      - In a matching storyboard segue, set the class of the segue instance to this class.
//      - Customize the mediation(source:destination:) method to dynamically craft the desired Navigation result.
//      - Optional: The navigationIntent.presentation can be set, which will override any segue presentation method.

/*

import UIKit

class ExampleNavigationSegue: SnapNavigationSegue {

override var mediation: (UIViewController, UIViewController) -> () {
get {
// Perform mediation here.
return { source, destination in
// A mediation might look like this:
//                if let source = source as? ExpectedSourceSubclassOrProtocol,
//                let destination = destination as? ExpectedDestinationSublassOrProtocol {
//                    destination.valueToSet = source.providingValue
//                }
}
}
set {
// Irrelevant.
}
}

}

```

</details>

<details>
<summary>Route navigator example</summary>

```swift

//  An example SnapRouteNavigator.
//  Intended as an example. Not to be used or subclassed.
//
//  Use this approach to define a custom Navigator that holds internal Navigation data mapped to Route enum cases.
//  To implement your own class, copy this class and:
//      - Use a custom unique Class name.
//      - Use a custom enum Route definition matching your navigation needs.
//      - Customize the `navigation<Route>(for:)` method to dynamically craft the desired Navigation result.
//
//  Example usage, from a UIViewController:
//      myNavigator = ExampleRouteNavigator(source: self)
//      myNavigator.navigate(using: ExampleRoute.presentSettings)



import UIKit

class ExampleRouteNavigator: SnapRouteNavigator {

var navigation: SnapNavigation

// MARK: - Initialization

init(source: UIViewController) {
navigation = SnapNavigation(source: source, destination: source)
}

// MARK: - Navigation

func navigation<Route: CaseIterable>(for route: Route) -> SnapNavigation? {
guard let route = route as? ExampleRoute else { return nil }
switch route {
case .presentSettings:
// Set destination / destinationFactory here.
// Set mediation here.
// Set presentation here.
return navigation
case .showColleagueView(let viewData):
// Set destination / destinationFactory here.
// Set mediation here.
// Set presentation here.
return navigation
case .showDetailView(let detailData):
// Set destination / destinationFactory here.
// Set mediation here.
// Set presentation here.
return navigation
}
}
}

enum ExampleRoute: CaseIterable {

// Conformance to CaseIterable.
static var allCases: [ExampleRoute] {
return [
.presentSettings,
.showColleagueView(viewData: 0),
.showDetailView(detailData: "")
]
}

case presentSettings
case showColleagueView(viewData: Int)
case showDetailView(detailData: String)
}
```

</details>


## Introduction

View navigation in the context of the iOS UIKit framework is a process involving multiple objects and actions. Navigation starts with a trigger action, determining what is the starting source view controller and the resultant destination view controller. This is followed by presenting the destination view controller in a certain manner and completed by perfoming any desired transformations on the view controllers.

SnapNavigation is a [behavioral pattern](https://en.wikipedia.org/wiki/Behavioral_pattern) offering a unified interface for this navigation process. It aims to aid and improve upon standard navigation by realizing the following goals:

- **Composable, Modular, Customizable**: Define each aspect of navigation separately; mix-and-match intent to targets as needed; mediation, and presentation can be performed by closure or delegate object, view instantiation can be performed by reference or factories.
- **Aggregate utility**: Provide default presentation animation implementations for all common navigation triggers; handle entire navigation flow in one function call.
- **Separate tightly-bound concerns**: Minimize colleague view references; separate the need to perform navigation actions from the actual implementation; view instantiation, mediation, and presentation can each be isolated.
- **Lightweight**: Use as a library, not a framework; Promote usage by composition, not inheritance.
- **Flexible**: Works for navigations triggered from code or as `UIStoryboardSegue` actions.

Navigation is described by model classes (`SnapNavigation` and concrete Route objects), with navigator classes managing the navigation actions (`SnapNavigator`, `SnapNavigationRouter`, and `SnapNavigationSegue`). Concrete navigation scenarios can be defined in your app partially or entirely as custom navigation models, sent to navigator object navigate methods dynamically, or mixtures of each approach as needed.

## SnapNavigation: The data model describing navigation

A SnapNavigation class instance describes a particular navigation action.

SnapNavigation has four elementary attributes: `source`, `destination`, `mediation`, and `presentation`. Each of these is an enumeration. Collectively these describe the who, what, and how of the navigation.

`source` is the representative view object from which the navigation emanates.

`destination` is the representative view object to which the navigation transitions towards.

`mediation` governs any transformative methods peformed on `source` and `destination`.

`presentation` governs transitional animation and resultant presentation of `source` and `destination`.

A navigation must describe a `source` and `destination`, but other attributes are optional.

A navigation with only a `source` and `destination` describes an abstract association.

A navigation with a `mediation` and no `presentation` describes a purely mediational relationship. For example, data marshalling between `source` and `destination`.

A navigation with a `presentation` and no `mediation` describes a purely presentational relationship. For example, this could be a method to present the `destination` modally over the `source` involving an animation.

A navigation with both `mediation` and `presentation` describes a complete navigation. `mediation` and `presentation` together can be defined in a `NavigationIntent`.

## SnapNavigator: An object that performs a navigation

SnapNavigator is a protocol adopted by an object that performs navigations.

`SnapNavigator` has a robust set of default implementations such that objects implementing this protocol are not required to implement any methods, unless customized behavior is desired. Most navigation customization can be performed by manipulating `SnapNavigation` data.

There are a number of `navigate` methods provided, allowing for a wide variety of composable navigation actions. These methods fall into two categories: navigate using a `navigationProvider`, or navigate using only provided arguments. The `navigate(using:)` and `navigate(from:…)` methods perform navigation using only provided arguments, and all other `navigate` methods are based on using `navigationProvider` data.

## SnapNavigationSegue: A UIStoryboardSegue performing a custom navigation

SnapNavigationSegue is a base `UIStoryboardSegue` class implementing a navigation intent.

This is intended to be subclassed. A subclass with no custom implementations will behave as a standard `UIStoryboardSegue`.

To provide a custom mediation in your subclass, simply override `mediation`. This is the primary intended use case.

Alternatively, or in conjunction with `mediation` override, `intent`, `mediator`, or `presentation` can be overriden. Setting `mediator` gets precedence over `mediation`. A set `presentation` takes precedence over the internal `UIStoryboardSegue` presentation method triggered in the `perform` function.

As an alternative to custom dedicated subclasses, a dependency injection container can be used to set the desired navigation intent values. Such a framework must work with the storyboard instantiation lifecycle to properly set the values when this object is created but before the `perform` method is triggered.

## Routes: Powerful convenience for particular navigations

Routes are expressed as a `CaseIterable` types. Routes define concrete navigation use cases. They allow numerous specific navigation needs to be expressed from an object triggering a navigation, decoupling the navigation implementation details. A `SnapNavigationRouter` maps a given route to a `SnapNavigation` usable by a `SnapNavigator`.

Routes defined as enumerations with associated values can be used to provide conditional intent (e.g. mediation payload) as long they conform to `CaseIterable`, in conjuntion with a concrete `SnapNavigationRouter` class `navigation` function switch.