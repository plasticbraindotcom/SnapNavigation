//
//  SnapNavigator.swift
//
//  Created by Stephen Downs on 2018-10-23.
//  Copyright © 2018 Stephen Downs. All rights reserved.
//

import UIKit

/// Protocol adopted by an object that performs navigations.
///
/// `SnapNavigator` has a robust set of default implementations such that
/// objects implementing this protocol are not required to implement any
/// methods, unless customized behavior is desired. Most navigation
/// customization can be performed by manipulating `SnapNavigation` data.
///
/// There are a number of `navigate` methods provided, allowing for a
/// wide variety of composable navigation actions. These methods fall into two
/// categories: navigate using a `navigationProvider`, or navigate using
/// only provided arguments. The `navigate(using:)` and `navigate(from:…)`
/// methods perform navigation using only provided arguments, and all
/// other `navigate` methods are based on using `navigationProvider` data.
public protocol SnapNavigator: AnyObject {
    
    var identifier: String? { get set }
    
    var navigationProvider: SnapNavigatorDataSource? { get set }
    
    // MARK: - Composable navigation
    
    /// Perform given navigation.
    /// This is the designated navigate method.
    ///
    /// - Parameter using: Object providing navigation details.
    func navigate(using navigation: SnapNavigation)
    
    /// Perform navigation using source, destination, mediation, and presentation.
    ///
    /// - Parameter from: Source object from which to navigate.
    /// - Parameter to: Destination object to navigate towards.
    /// - Parameter applying: Mediation object or method performing
    /// transformation on `source` and `destination`.
    /// - Parameter with: Presentation object or method for transitional
    /// animation and presentation of `destination` from `source`.
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, applying mediation: SnapNavigation.Mediation?, with presentation: SnapNavigation.Presentation?)
    
    /// Perform navigation using source, destination, and intent.
    ///
    /// - Parameter from: Source object from which to navigate.
    /// - Parameter to: Destination object to navigate towards.
    /// - Parameter with: Intent object describing transitional
    /// animation and presentation of `destination` from `source`.
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, with intent: SnapNavigationIntent)
    
    /// Perform navigation using source, destination, and presentation.
    ///
    /// - Parameter from: Source object from which to navigate.
    /// - Parameter to: Destination object to navigate towards.
    /// - Parameter with: Presentation object or method for transitional
    /// animation and presentation of `destination` from `source`.
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, with presentation: SnapNavigation.Presentation)
    
    // MARK: - Provided navigation
    
    /// Perform navigation using `navigationProvider` data.
    func navigate()
    
    /// Perform navigation using `navigationProvider` data with an intent override.
    ///
    /// - Parameter with: Intent object describing transitional
    /// animation and presentation.
    func navigate(with intent: SnapNavigationIntent)
    
    /// Perform navigation using `navigationProvider` data with a mediation override.
    ///
    /// - Parameter applying: Mediation object or method performing
    /// transformation.
    func navigate(applying mediation: SnapNavigation.Mediation)
    
    /// Perform navigation using `navigationProvider` data with a mediation method override.
    ///
    /// - Parameter applying: Mediation method performing transformation.
    func navigate(applying mediationMethod: @escaping (UIViewController, UIViewController) -> ())
    
    /// Perform navigation using `navigationProvider` data with a presentation override.
    ///
    /// - Parameter with: Presentation object or method for transitional
    /// animation and presentation.
    func navigate(with presentation: SnapNavigation.Presentation)
    
    /// Perform navigation using `navigationProvider` data with a presentation method override.
    ///
    /// - Parameter with: Presentation method for transitional
    /// animation and presentation.
    func navigate(with presentationMethod: @escaping (UIViewController, UIViewController) -> ())
}

// MARK: - SnapNavigator data provider

/// Protocol adopted by an object that mediates `SnapNavigation` data for a `SnapNavigator`.
public protocol SnapNavigatorDataSource: AnyObject {
    func navigation(for navigator: SnapNavigator) -> SnapNavigation
}

// MARK: - SnapNavigator default implementation

extension SnapNavigator {
    
    var identifier: String? {
        get { return nil }
        set { }
    }
    
    var navigationProvider: SnapNavigatorDataSource? {
        get { return nil }
        set { }
    }
    
    // Designated navigate function.
    func navigate(using navigation: SnapNavigation) {
        
        // Get source and destination
        let source = sourceViewController(of: navigation)
        let destination = destinationViewController(of: navigation)
        
        // Apply mediation
        if let mediation = navigation.mediation {
            switch mediation {
                
            // Use provided NavigationMediator.
            case let .mediator(mediator):
                mediator.mediate(source: source, destination: destination)
                
            // Call the mediation method.
            case let .method(navMethod):
                navMethod(source, destination)
            }
        }
        
        // Perform presentation
        if let presentation = navigation.presentation {
            switch presentation {
                
            // Use provided NavigationPresenter.
            case let .presenter(presenter):
                presenter.present(source: source, destination: destination)
                
            // Call the presentation method.
            case let .method(navMethod):
                navMethod(source, destination)
                
            // Call show method on source.
            case .show:
                source.show(destination, sender: self)
                
            // Call showDetailViewController on source.
            case .showDetailViewController:
                source.showDetailViewController(destination, sender: self)
                
            // Call present method on source.
            case let .present(animated, completion):
                source.present(destination, animated: animated, completion: completion)
                
            // Call dismiss on source.
            case let .dismiss(animated, completion):
                source.dismiss(animated: animated, completion: completion)
            }
        }
        
    }
    
    // Composable navigation methods.
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, applying mediation: SnapNavigation.Mediation?, with presentation: SnapNavigation.Presentation?) {
        let nav = SnapNavigation(source: source, destination: destination, mediation: mediation, presentation: presentation)
        navigate(using: nav)
    }
    
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, with intent: SnapNavigationIntent) {
        let nav = SnapNavigation(source: source, destination: destination, mediation: intent.mediation, presentation: intent.presentation)
        navigate(using: nav)
    }
    
    func navigate(from source: SnapNavigation.Source, to destination: SnapNavigation.Destination, with presentation: SnapNavigation.Presentation) {
        let nav = SnapNavigation(source: source, destination: destination, mediation: nil, presentation: presentation)
        navigate(using: nav)
    }
    
    // Navigation convenience methods using navigationProvider.
    func navigate() {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(using: nav)
    }
    
    func navigate(with intent: SnapNavigationIntent) {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(from: nav.source, to: nav.destination, with: intent)
    }
    
    func navigate(applying mediation: SnapNavigation.Mediation) {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(from: nav.source, to: nav.destination, applying: mediation, with: nav.presentation)
    }
    
    func navigate(applying mediationMethod: @escaping (UIViewController, UIViewController) -> ()) {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(from: nav.source, to: nav.destination, applying: .method(mediationMethod), with: nav.presentation)
    }
    
    func navigate(with presentation: SnapNavigation.Presentation) {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(from: nav.source, to: nav.destination, applying: nav.mediation, with: presentation)
    }
    
    func navigate(with presentationMethod: @escaping (UIViewController, UIViewController) -> ()) {
        guard let nav = navigationProvider?.navigation(for: self) else { return }
        navigate(from: nav.source, to: nav.destination, applying: nav.mediation, with: .method(presentationMethod))
    }
    
    // Warning: When using factories, calling this method will create a new UIViewController every time.
    func destinationViewController(of navigation: SnapNavigation) -> UIViewController {
        switch navigation.destination {
            
        case let .viewController(vc):
            return vc
            
        case let .viewControllerFactory(vcf):
            return vcf(navigation)
        }
    }
    
    func sourceViewController(of navigation: SnapNavigation) -> UIViewController {
        switch navigation.source {
        case let .viewController(vc):
            return vc
        }
    }
    
}
