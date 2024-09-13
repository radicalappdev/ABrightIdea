//
//  ImmersiveView.swift
//  ABrightIdea
//
//  Created by Joseph Simpson on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ImmersiveView: View {

    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let root = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(root)

                if let dome = root.findEntity(named: "Dome") {
                    dome.scale = .init(x: -1, y: 1, z: 1)
                }
            }
        }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
