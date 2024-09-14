//
//  ImmersiveView.swift
//  ABrightIdea
//
//  Created by Joseph Simpson on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

//enum LightType: Float {
//    case dim =  520
//    case regular = 1600
//    case bright = 3200
//}

enum LightType: Float {
    case dim =  6740.94
    case regular = 26963.76
    case bright = 53927.52
}

struct ImmersiveView: View {
    @Environment(AppModel.self) private var appModel

    @State var lightType: LightType = .regular

    @State private var entityTransformAtStartOfGesture: Transform?



    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let root = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(root)

                if let dome = root.findEntity(named: "Dome") {
                    dome.scale = .init(x: -1, y: 1, z: 1)
                }

                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {
                    lightBulbTemplate.isEnabled = false

                    // Create the first light bulb from the template and place it directly in front of the player
                    let newLightBulb = lightBulbTemplate.clone(recursive: true)
                    newLightBulb.isEnabled = true
                    newLightBulb.position = SIMD3(x: 0, y: 1, z: -1)
                    content.add(newLightBulb)

                    if appModel.cachedPointLight == nil, let pointLight = root.findEntity(named: "SelectedPointLight") {
                        print("LIGHT Loaded in scene: \(pointLight)")
                        appModel.cachedPointLight = pointLight
                        
                        newLightBulb.addChild(pointLight)
                        pointLight.setPosition([0,0.088,0], relativeTo: newLightBulb)
                    }
                }
            }
        } update: { content in
            if let root = content.entities.first {
                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {

                    if appModel.shouldAddBulb {
                        appModel.shouldAddBulb = false

                        let newLightBulb = lightBulbTemplate.clone(recursive: true)
                        newLightBulb.isEnabled = true
                        newLightBulb.name = UUID().uuidString
                        let randomX = Float.random(in: -2...2)
                        let randomY = Float.random(in: 0...2)
                        let randomZ = Float.random(in: -2...2)

                        newLightBulb.position = SIMD3(x: randomX, y: randomY, z: randomZ)
                        content.add(newLightBulb)
                        print("LIGHT Added: \(newLightBulb)")

                        if let pointLight = appModel.cachedPointLight {
                            print("LIGHT Point: \(pointLight)") // THIS IS STILL NOT RUNNING
                            pointLight.parent?.removeChild(pointLight)
                            newLightBulb.addChild(pointLight)
                            pointLight.setPosition([0,0.088,0], relativeTo: newLightBulb)
                        }
                    }
                }
            }
        }
        .gesture(tapGesture)
        .gesture(dragGesture)
        .gesture(scaleGesture)
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

                appModel.shouldAddBulb = true
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

    var scaleGesture: some Gesture {
        MagnifyGesture()
            .targetedToAnyEntity()
            .onChanged { value in

                let magnification: Float = Float(value.magnification)
//                print("SCALE GESTURE: \(magnification)")

                if entityTransformAtStartOfGesture == nil {
                    entityTransformAtStartOfGesture = value.entity.transform
                }

                if let initialScale = entityTransformAtStartOfGesture?.scale.x  {
                    let scaler = Float(magnification) * initialScale
                    let minScale: Float = 0.5
                    let maxScale: Float = 10.5
                    let scaled = min(Float(max(Float(scaler), minScale)), maxScale)
                    let newScale = SIMD3(x: scaled, y: scaled, z: scaled)
                    value.entity.setScale(newScale, relativeTo: value.entity.parent!)

//                    print("LIGHT SCALE: \(scaled)")
                    appModel.lightIntensity = scaled

                }

            }
            .onEnded { value in
                // TODO: Save the item scale

                entityTransformAtStartOfGesture = nil
            }
    }

}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
