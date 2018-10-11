//
//  TransitionOperation.swift
//
//  Created by Graham Burgsma on 2018-06-26.
//

import UIKit

/// Used to designate a transition as a presentation or dismissal.
enum TransitionOperation {
    case present, dismiss

    var contextViewControllerKey: UITransitionContextViewControllerKey {
        switch self {
        case .present: return .to
        case .dismiss: return .from
        }
    }

    var contextViewKey: UITransitionContextViewKey {
        switch self {
        case .present: return .to
        case .dismiss: return .from
        }
    }
}
