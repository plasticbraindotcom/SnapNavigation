# SnapNavigation
Composable navigation for iOS

[![Language: Swift](https://img.shields.io/badge/language-swift-f48041.svg?style=flat)](https://developer.apple.com/swift)
![Platform: iOS 8+](https://img.shields.io/badge/platform-iOS%208%2B-blue.svg?style=flat)
[![License: MIT](http://img.shields.io/badge/license-MIT-lightgrey.svg?style=flat)](https://github.com/freshOS/then/blob/master/LICENSE)
![Release version](https://img.shields.io/github/release/freshos/router.svg)

SnapNavigation provides a comprehensive way to define and handle all iOS application navigation concerns.

SnapNavigation allows you to separate navigation code into dedicated objects and snap together each aspect in any way you see fit, dynamically determining source and destination views, mediation between actors, and presentational code. It works with navigation actions triggered from code as well as from UIStoryboard action segues.

## Overview

Navigation is described by model classes (SnapNavigation and concrete Route objects), with navigator classes managing the navigation actions (SnapNavigator, SnapNavigationRouter, and SnapNavigationSegue). Concrete navigation scenarios can be defined in your app partially or entirely as custom navigation models, sent to navigator object navigate methods dynamically, or mixtures of each approach as needed.

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
