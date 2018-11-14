//
//  SnapNavigationSegue.swift
//
//  Created by Stephen Downs on 2018-10-18.
//  Copyright © 2018 Stephen Downs. All rights reserved.

import UIKit

// MARK: - Navigation segue

/// A base `UIStoryboardSegue` class implementing a navigation intent.
///
/// This is intended to be subclassed. A subclass with no custom implementations
/// will behave as a standard `UIStoryboardSegue`.
///
/// To provide a custom mediation in your subclass, simply override `mediation`.
/// This is the primary intended use case.
///
/// Alternatively, or in conjunction with `mediation` override, `intent`,
/// `mediator`, or `presentation` can be overriden. Setting `mediator` gets
/// precedence over `mediation`. A set `presentation` takes precedence
/// over the internal `UIStoryboardSegue` presentation method triggered
/// in the `perform` function.
///
/// As an alternative to custom dedicated subclasses, a dependency injection
/// container can be used to set the desired navigation intent values.
/// Such a framework must work with the storyboard instantiation lifecycle
/// to properly set the values when this object is created but before
/// the `perform` method is triggered.
public class SnapNavigationSegue: UIStoryboardSegue, SnapNavigationMediator {

    // Set a custom intent to override both mediation and presentation.
    // A custom intent with a nil mediation will default to using internal `mediation`.
    public var intent: SnapNavigationIntent? {
        get {
            return navigation.intent
        }
        set {
            navigation.intent = newValue
            if navigation.mediation == nil {
                navigation.mediation = .mediator(self)
            }
        }
    }
    
    public func mediate(source: UIViewController, destination: UIViewController) {
        // Perform mediation.
        mediation(source, destination)
    }
    
    // Navigation mediation method.
    // Override this value as needed in subclass to apply desired mediation.
    public var mediation: (UIViewController, UIViewController) -> () = { _, _ in }
    
    // Presentation is normally handled by the segue storyboard attributes, but can be custom overriden here.
    public var presentation: SnapNavigation.Presentation? {
        get {
            return navigation.presentation
        }
        set {
            navigation.presentation = newValue
        }
    }
    
    // Setting a mediator to a non-nil value will override the internal `mediation`.
    // Setting mediator to nil falls back to using the internal `mediation`.
    public var mediator: SnapNavigationMediator? {
        get {
            guard let mediation = navigation.mediation else { return self }
            switch mediation {
            case .mediator(let authoritativeMediator):
                return authoritativeMediator
            default:
                return self
            }
        }
        set {
            if let newMediator = newValue {
                navigation.mediation = .mediator(newMediator)
            } else {
                navigation.mediation = .mediator(self)
            }
        }
    }
    
    // Captures the segue source and destination along with navigation intent.
    lazy var navigation: SnapNavigation = SnapNavigation(source: self.source, destination: self.destination)
    
    // Internal `SnapNavigator`.
    var navigator: SnapNavigator?
    
    /// Initializes and returns a storyboard segue object.
    ///
    /// You do not create segue objects directly. Instead, the storyboard
    /// runtime creates them when it must perform a segue between two view controllers.
    ///
    /// - Parameter identifier: The identifier for the segue object.
    /// - Parameter source: The source view controller for the segue.
    /// - Parameter destination: The destination view controller for the segue.
    override init(identifier: String?, source: UIViewController, destination: UIViewController) {
        super.init(identifier: identifier, source: source, destination: destination)
        
        navigator = SnapNavigationSegueNavigator()
        navigation.mediation = .mediator(self)
    }
    
    /// Performs the visual transition for the segue.
    public override func perform() {
        
        // Perform navigation concerns (optional mediation, then optional presentation).
        navigator?.navigate(using: navigation)
        
        if shouldPerform {
            super.perform()
        }
        
    }
    
    // Determines if segue should perform `UIStoryboardSegue` transition using the segue Kind attribute set in the storyboard instance.
    public var shouldPerform: Bool {
        return navigation.presentation == nil
    }
    
}

// MARK: - Private

fileprivate class SnapNavigationSegueNavigator: SnapNavigator { }
