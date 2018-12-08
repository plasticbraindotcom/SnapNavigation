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
    
    /// Perform navigation using given `Route` with an intent override.
    ///
    /// - Parameter using: Route describing the navigation path.
    /// - Parameter with: Intent object describing transitional
    /// animation and presentation.
    func navigate<Route: CaseIterable>(using route: Route, with intent: SnapNavigationIntent)
    
    /// Perform navigation using given `Route` with a mediation override.
    ///
    /// - Parameter using: Route describing the navigation path.
    /// - Parameter applying: Mediation object or method performing
    /// transformation.
    func navigate<Route: CaseIterable>(using route: Route, applying mediation: SnapNavigation.Mediation)
    
    /// Perform navigation using given `Route` with a mediation method override.
    ///
    /// - Parameter using: Route describing the navigation path.
    /// - Parameter applying: Mediation method performing transformation.
    func navigate<Route: CaseIterable>(using route: Route, applying mediationMethod: @escaping (UIViewController, UIViewController) -> ())
    
    /// Perform navigation using given `Route` with a presentation override.
    ///
    /// - Parameter using: Route describing the navigation path.
    /// - Parameter with: Presentation object or method for transitional
    /// animation and presentation.
    func navigate<Route: CaseIterable>(using route: Route, with presentation: SnapNavigation.Presentation)
    
    /// Perform navigation using given `Route` with a presentation method override.
    ///
    /// - Parameter using: Route describing the navigation path.
    /// - Parameter with: Presentation method for transitional
    /// animation and presentation.
    func navigate<Route: CaseIterable>(using route: Route, with presentationMethod: @escaping (UIViewController, UIViewController) -> ())
}

// `SnapRouteNavigator` default implementations.
extension SnapRouteNavigator {
    public func navigate<Route: CaseIterable>(using route: Route) {
        guard let navigation = navigation(for: route) else { return }
        navigate(using: navigation)
    }
    
    public func navigate<Route: CaseIterable>(using route: Route, with intent: SnapNavigationIntent) {
        guard let navigation = navigation(for: route) else { return }
        let composedNavigation = SnapNavigation(source: navigation.source, destination: navigation.destination, intent: intent)
        navigate(using: composedNavigation)
    }
    
    public func navigate<Route: CaseIterable>(using route: Route, applying mediation: SnapNavigation.Mediation) {
        guard let navigation = navigation(for: route) else { return }
        let composedNavigation = SnapNavigation(source: navigation.source, destination: navigation.destination, mediation: mediation)
        navigate(using: composedNavigation)
    }
    
    public func navigate<Route: CaseIterable>(using route: Route, applying mediationMethod: @escaping (UIViewController, UIViewController) -> ()) {
        guard let navigation = navigation(for: route) else { return }
        let composedNavigation = SnapNavigation(source: navigation.source, destination: navigation.destination, mediation: SnapNavigation.Mediation.method(mediationMethod))
        navigate(using: composedNavigation)
    }
    
    public func navigate<Route: CaseIterable>(using route: Route, with presentation: SnapNavigation.Presentation) {
        guard let navigation = navigation(for: route) else { return }
        let composedNavigation = SnapNavigation(source: navigation.source, destination: navigation.destination, mediation: navigation.mediation, presentation: presentation)
        navigate(using: composedNavigation)
    }
    
    public func navigate<Route: CaseIterable>(using route: Route, with presentationMethod: @escaping (UIViewController, UIViewController) -> ()) {
        guard let navigation = navigation(for: route) else { return }
        let composedNavigation = SnapNavigation(source: navigation.source, destination: navigation.destination, mediation: navigation.mediation, presentation: SnapNavigation.Presentation.method(presentationMethod))
        navigate(using: composedNavigation)
    }
}
