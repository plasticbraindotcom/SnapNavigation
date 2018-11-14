//
//  SnapNavigationRouter.swift
//
//  Created by Stephen Downs on 2018-10-23.
//  Copyright © 2018 Stephen Downs. All rights reserved.
//
//  Navigation route concerns.

import UIKit

/// Provides a navigation for a given route.
///
/// Routes are expressed as a `CaseIterable` types.
/// Routes define concrete navigation use cases. They allow
/// numerous specific navigation needs to be expressed
/// from an object triggering a navigation, decoupling the
/// navigation implementation details. A `SnapNavigationRouter`
/// maps a given route to a `SnapNavigation` usable by a
/// `SnapNavigator`.
///
/// Routes defined as enumerations
/// with associated values can be used to provide conditional
/// intent (e.g. mediation payload) as long they conform to
/// `CaseIterable`, in conjuntion with a concrete
/// `SnapNavigationRouter` class `navigation` function switch.
public protocol SnapNavigationRouter: AnyObject {

    /// Provides a `SnapNavigation` for a given `<Route>`.
    ///
    /// - Parameter for: Route describing the navigation path.
    func navigation<Route: CaseIterable>(for route: Route) -> SnapNavigation?
}

/// A `SnapNavigator` with internalized `navigation(for:)`
/// routing method.
///
/// This class allows for a one-step `navigate(using:)` approach
/// when using routes.
public protocol SnapRouteNavigator: SnapNavigator & SnapNavigationRouter {

    /// Perform navigation using given `Route`.
    ///
    /// - Parameter using: Route describing the navigation path.
    func navigate<Route: CaseIterable>(using route: Route)
}

// `SnapRouteNavigator` default implementation.
extension SnapRouteNavigator {
    func navigate<Route: CaseIterable>(using route: Route) {
        guard let navigation = navigation(for: route) else { return }
        navigate(using: navigation)
    }
}
