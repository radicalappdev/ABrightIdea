//
//  AppModel.swift
//  ABrightIdea
//
//  Created by Joseph Simpson on 9/13/24.
//

import SwiftUI
import RealityKit

/// Maintains app-wide state
@MainActor
@Observable
class AppModel {
    let immersiveSpaceID = "ImmersiveSpace"
    enum ImmersiveSpaceState {
        case closed
        case inTransition
        case open
    }
    var immersiveSpaceState = ImmersiveSpaceState.closed
    var mainWindowOpen: Bool = true

    var lightIntensity: Float = 1

    var rootEntity: Entity?
    var shouldAddBulb: Bool = false
    var cachedPointLight: Entity?
    var cleanEntity: Entity?
    var selectedEntity: Entity?

    var exitCount: Int = 0

}
