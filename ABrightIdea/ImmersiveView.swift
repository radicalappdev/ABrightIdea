//
//  ImmersiveView.swift
//  ABrightIdea
//
//  Created by Joseph Simpson on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

enum LightType: CGFloat {
    case dim =  13481.88
    case regular = 26963.76
    case bright = 53927.52
}

struct ImmersiveView: View {

    @State var lightType: LightType = .regular

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
        .gesture(tapGesture)
        .gesture(dragGesture)
    }

    var tapGesture: some Gesture {
        SpatialTapGesture()
            .targetedToAnyEntity()
            .onEnded { value in
//                let selected = value.entity.name
                if(lightType == .dim) {
                    lightType = .regular
                } else if (lightType == .regular) {
                    lightType = .bright
                } else if (lightType == .bright) {
                    lightType = .dim
                }
                print("TAP GESTURE: \(lightType)")
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in

                let newPostion = value.convert(value.location3D, from: .local, to: value.entity.parent!)

                let limit: Float = 2
                value.entity.position.x = min(max(newPostion.x, -limit), limit)
                value.entity.position.y = min(max(newPostion.y, 0.1), limit)
                value.entity.position.z = min(max(newPostion.z, -limit), limit)

            }
            .onEnded { value in
                // TODO: Save the item position
            }
    }
}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
