//
//  SnapNavigation.swift
//
//  Created by Stephen Downs on 2018-10-18.
//  Copyright © 2018 Stephen Downs. All rights reserved.
//
// Navigation model concerns.

import UIKit

// MARK: - Navigation

/// A model describing a navigation action.
///
/// `SnapNavigation` has four elementary attributes: `source`, `destination`,
/// `mediation`, and `presentation`. Each of these is an enumeration. Collectively
/// these describe the who, what, and how of the navigation.
///
/// `source` is the representative view object from which the
/// navigation emanates.
///
/// `destination` is the representative view object to which the
/// navigation transitions towards.
///
/// `mediation` governs any transformative methods peformed on `source` and
/// `destination`.
///
/// `presentation` governs transitional animation and resultant presentation of
/// `source` and `destination`.
///
/// A navigation must describe a `source` and `destination`, but other
/// attributes are optional.
///
/// A navigation with only a `source` and `destination` describes an
/// abstract association.
///
/// A navigation with a `mediation` and no `presentation` describes a
/// purely mediational relationship. For example, data marshalling between
/// `source` and `destination`.
///
/// A navigation with a `presentation` and no `mediation` describes a
/// purely presentational relationship. For example, this could be a method
/// to present the `destination` modally over the `source` involving an animation.
///
/// A navigation with both `mediation` and `presentation`
/// describes a complete navigation. `mediation` and `presentation` together
/// can be defined in a `NavigationIntent`.
public class SnapNavigation {
    
    public typealias SnapNavigationMediation = (UIViewController, UIViewController) -> ()
    
    public typealias SnapNavigationPresentation = (UIViewController, UIViewController) -> ()
    
    public typealias ViewControllerFactory = (SnapNavigation) -> UIViewController
    
    public enum Destination {
        case viewController(UIViewController)
        case viewControllerFactory(ViewControllerFactory)
    }
    
    public enum Mediation {
        case mediator(SnapNavigationMediator)
        case method(SnapNavigationMediation)
    }
    
    public enum Presentation {
        case dismiss(Bool, () -> Void)
        case present(Bool, () -> Void)
        case show, showDetailViewController
        case presenter(SnapNavigationPresenter)
        case method(SnapNavigationPresentation)
    }
    
    public enum Source {
        case viewController(UIViewController)
    }
    
    public var source: Source
    
    public var destination: Destination
    
    public var intent: SnapNavigationIntent?
    
    // `mediation` value is stored within the `intent`.
    public var mediation: Mediation? {
        
        get {
            return intent?.mediation
        }
        
        set {
            if intent == nil {
                if newValue != nil {
                    intent = SnapNavigationIntent(mediation: newValue)
                }
            } else {
                if newValue == nil && intent!.presentation == nil {
                    intent = nil
                } else {
                    intent!.mediation = newValue
                }
            }
        }
        
    }
    
    // `presentation` value is stored within the `intent`.
    public var presentation: Presentation? {
        
        get {
            return intent?.presentation
        }
        
        set {
            if intent == nil {
                if newValue != nil {
                    intent = SnapNavigationIntent(presentation: newValue)
                }
            } else {
                if newValue == nil && intent!.mediation == nil {
                    intent = nil
                } else {
                    intent!.presentation = newValue
                }
            }
        }
        
    }
    
    /// Creates a `SnapNavigation` instance from `SnapNavigation.Source` and
    /// `SnapNavigation.Destination`, with optional `SnapNavigation.Mediation`
    /// and optional `SnapNavigation.Presentation`.
    ///
    /// - Parameter source: The object from which the navigation emanates.
    /// - Parameter destination: The object to which the navigation transitions
    /// towards.
    /// - Parameter mediation: Object or method performing transformation on
    /// `source` and `destination`.
    /// - Parameter presentation: Object or method for transitional animation and
    /// presentation of `destination` from `source`.
    public init(source: Source, destination: Destination, mediation: Mediation? = nil, presentation: Presentation? = nil) {
        self.source = source
        self.destination = destination
        self.mediation = mediation
        self.presentation = presentation
    }
    
    /// Creates a `SnapNavigation` instance from a view controller source and
    /// destination, with optional `SnapNavigation.Mediation` and
    /// optional `SnapNavigation.Presentation`.
    ///
    /// - Parameter source: The view controller from which the navigation
    /// emanates.
    /// - Parameter destination: The view controller to which the navigation
    /// transitions towards.
    /// - Parameter mediation: Object or method performing transformation on
    /// `source` and `destination`.
    /// - Parameter presentation: Object or method for transitional animation and
    /// presentation of `destination` from `source`.
    public convenience init(source: UIViewController, destination: UIViewController, mediation: Mediation? = nil, presentation: Presentation? = nil) {
        self.init(source: .viewController(source), destination: .viewController(destination), mediation: mediation, presentation: presentation)
    }
    
    /// Creates a `SnapNavigation` instance from view controller source and
    /// destination, with optional mediation method and optional
    /// `SnapNavigation.Presentation`.
    ///
    /// - Parameter source: The view controller from which the navigation
    /// emanates.
    /// - Parameter destination: The view controller to which the navigation
    /// transitions towards.
    /// - Parameter mediation: Transformative method performed on `source`
    /// and `destination`.
    /// - Parameter presentation: Object or method for transitional animation and
    /// presentation of `destination` from `source`.
    public convenience init(source: UIViewController, destination: UIViewController, mediation: SnapNavigationMediation?, presentation: Presentation?) {
        let navMediation: Mediation?
        if let mediation = mediation {
            navMediation = .method(mediation)
        } else {
            navMediation = nil
        }
        self.init(source: .viewController(source), destination: .viewController(destination), mediation: navMediation, presentation: presentation)
    }
    
    /// Creates a `SnapNavigation` instance from `SnapNavigation.Source`,
    /// `SnapNavigation.Destination`, and `SnapNavigationIntent`.
    ///
    /// - Parameter source: The object from which the navigation emanates.
    /// - Parameter destination: The object to which the navigation transitions
    /// towards.
    /// - Parameter intent: Object providing transformative actions and
    /// presentation of `destination` from `source`.
    public convenience init(source: Source, destination: Destination, intent: SnapNavigationIntent) {
        self.init(source: source, destination: destination)
        self.intent = intent
    }
    
    /// Creates a `SnapNavigation` instance from `SnapNavigation.Source`,
    /// `SnapNavigation.Destination`, and `SnapNavigation.Presentation`.
    ///
    /// - Parameter source: The object from which the navigation emanates.
    /// - Parameter destination: The object to which the navigation transitions
    /// towards.
    /// - Parameter presentation: Object or method for transitional animation and
    /// presentation of `destination` from `source`.
    public convenience init(source: Source, destination: Destination, presentation: Presentation) {
        self.init(source: source, destination: destination, mediation: nil, presentation: presentation)
    }
    
}

// MARK: - Navigation intent

/// `SnapNavigationIntent` model describes the transformative actions and
/// presentation aspects of a navigation.
///
/// `SnapNavigationIntent` has two optional attributes: `mediation` and
/// `presentation`.
///
/// `mediation` governs any transformative methods peformed on `source` and
/// `destination`.
///
/// `presentation` governs transitional and resultant presentation aspects of
/// the navigation affecting `source` and `destination`.
///
/// `SnapNavigationIntent` isolates these aspects for navigation scenarios
/// where what happens and how it happens are decoupled from the affected
/// navigation participants.
public class SnapNavigationIntent {
    public var mediation: SnapNavigation.Mediation?
    public var presentation: SnapNavigation.Presentation?
    
    /// Creates a `SnapNavigationIntent` instance from optional
    /// `SnapNavigation.Mediation` and optional `SnapNavigation.Presentation`.
    ///
    /// - Parameter mediation: Object or method performing transformation
    /// method of the intent.
    /// - Parameter presentation: Object or method performing transitional
    /// animation and presentation aspects of the intent.
    public init(mediation: SnapNavigation.Mediation? = nil, presentation: SnapNavigation.Presentation? = nil) {
        self.mediation = mediation
        self.presentation = presentation
    }
    
    /// Creates a `SnapNavigationIntent` instance from `SnapNavigation.Presentation`.
    ///
    /// - Parameter presentation: Object or method performing transitional
    /// animation and presentation aspects of the intent.
    public convenience init(presentation: SnapNavigation.Presentation) {
        self.init(mediation: nil, presentation: presentation)
    }
}

// MARK: - Navigation mediator

/// Provides a transformative `mediation` for use on `source` and
/// `destination` view controller navigation actors.
///
/// Classes adopting this protocol need only to provide a `mediation`
/// method.
public protocol SnapNavigationMediator {
    var mediation: (UIViewController, UIViewController) -> () { get }
    
    /// Performs a mediation.
    ///
    /// - Parameter source: The source view controller of the mediation.
    /// - Parameter destination: The destination view controller of the mediation.
    func mediate(source: UIViewController, destination: UIViewController)
}

// `SnapNavigationMediator` default implementation.
extension SnapNavigationMediator {
    public func mediate(source: UIViewController, destination: UIViewController) {
        // Perform mediation.
        mediation(source, destination)
    }
}

// MARK: - Navigation presenter

/// Provides a `presentation` method handling transitional animation
/// and resultant presentation of `source` and `destination`
/// view controller navigation actors.
///
/// Classes adopting this protocol need only to provide a `presentation`
/// method.
public protocol SnapNavigationPresenter {
    var presentation: (UIViewController, UIViewController) -> () { get }
    
    /// Performs a navigation presentation.
    ///
    /// - Parameter source: The source view controller of the presentation.
    /// - Parameter destination: The destination view controller of the
    /// presentation.
    func present(source: UIViewController, destination: UIViewController)
}

// `SnapNavigationPresenter` default implementation.
extension SnapNavigationPresenter {
    public func present(source: UIViewController, destination: UIViewController) {
        // Perform presentation.
        presentation(source, destination)
    }
}
