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
                appModel.rootEntity = root

                if let dome = root.findEntity(named: "Dome") {
                    dome.scale = .init(x: -1, y: 1, z: 1)
                }

                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {
                    lightBulbTemplate.isEnabled = false

                    if let entity = lightBulbTemplate.findEntity(named: "Glass")
                    {
                        if var material =  entity.components[ModelComponent.self]?.materials.first as? PhysicallyBasedMaterial {
                            material.emissiveIntensity = 0
                            entity.components[ModelComponent.self]?.materials[0] = material
                        }
                    }

                    // Create the first light bulb from the template and place it directly in front of the player
                    let newLightBulb = lightBulbTemplate.clone(recursive: true)
                    newLightBulb.isEnabled = true
                    newLightBulb.name = UUID().uuidString
                    newLightBulb.position = SIMD3(x: 0, y: 1, z: -1)
                    content.add(newLightBulb)
                    appModel.selectedEntity = newLightBulb

                    if let entity = newLightBulb.findEntity(named: "Glass")
                    {
                        if var material =  entity.components[ModelComponent.self]?.materials.first as? PhysicallyBasedMaterial {
                            material.emissiveIntensity = 10
                            entity.components[ModelComponent.self]?.materials[0] = material
                        }
                    }

                    if appModel.cachedPointLight == nil, let pointLight = root.findEntity(named: "SelectedPointLight") {
                        print("LIGHT Loaded in scene: \(pointLight)")
                        appModel.cachedPointLight = pointLight

                        newLightBulb.addChild(pointLight)
                        pointLight.setPosition([0,0.088,0], relativeTo: newLightBulb)
                    }
                }
            }
        } update: { content in
            if let root = appModel.rootEntity {

                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {


                    if appModel.shouldAddBulb {
                        appModel.shouldAddBulb = false

                        let newLightBulb = lightBulbTemplate.clone(recursive: true)
                        newLightBulb.isEnabled = true
                        newLightBulb.name = UUID().uuidString
                        let randomX = Float.random(in: -2...2)
                        let randomY = Float.random(in: 0.75...2)
                        let randomZ = Float.random(in: -2...2)

                        newLightBulb.position = SIMD3(x: randomX, y: randomY, z: randomZ)
                        content.add(newLightBulb)
                        appModel.selectedEntity = newLightBulb
                        print("LIGHT Added: \(newLightBulb)")

                        if let entity = newLightBulb.findEntity(named: "Glass")
                        {
                            if var material =  entity.components[ModelComponent.self]?.materials.first as? PhysicallyBasedMaterial {
                                material.emissiveIntensity = 10
                                entity.components[ModelComponent.self]?.materials[0] = material
                            }
                        }

                        if let pointLight = appModel.cachedPointLight {
                            pointLight.parent?.removeChild(pointLight)
                            newLightBulb.addChild(pointLight)
                            pointLight.setPosition([0,0.088,0], relativeTo: newLightBulb)
                        }
                    }
                }

                if let cleanUp = appModel.cleanEntity {
                    if let entity = cleanUp.findEntity(named: "Glass") {
                        if var material = entity.components[ModelComponent.self]?.materials.first as? PhysicallyBasedMaterial {
                            material.emissiveIntensity = 0
                            entity.components[ModelComponent.self]?.materials[0] = material
                        }

                        // Force it to rotate onto one side
                        let rotationX = simd_quatf(angle: -.pi * 84 / 180, axis: SIMD3(1, 0, 0))
                        // Then apply a random rotation so they don't all face the same way
                        let randomYRotation = Float.random(in: 0...2 * .pi)
                        let rotationY = simd_quatf(angle: randomYRotation, axis: SIMD3(0, 1, 0))

                        let combinedRotation = rotationY * rotationX
                        cleanUp.setOrientation(combinedRotation, relativeTo: root)

                        // Physics sucks on RealityKit (mainly colliders) so just shove it onto the ground.

                        // Target position on the ground
                        let targetPosition = SIMD3(x: cleanUp.position.x, y: 0.088, z: cleanUp.position.z)

                        // Animate rotation and position
                        cleanUp.move(to: Transform(scale: cleanUp.scale, rotation: combinedRotation, translation: targetPosition),
                                     relativeTo: root,
                                     duration: 0.25)
                    }
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
                if(appModel.selectedEntity?.name == value.entity.name) {
                    appModel.cleanEntity = value.entity
                    appModel.shouldAddBulb = true
                }
            }
    }

    var dragGesture: some Gesture {
        DragGesture()
            .targetedToAnyEntity()
            .onChanged { value in
                let radius: Float = 4
                let floorHeight: Float = 0.1

                // Convert the drag location to the entity's parent's coordinate space
                let newPosition = value.convert(value.location3D, from: .local, to: value.entity.parent!)

                // Ensure the y position doesn't go below the floor
                let clampedY = max(newPosition.y, floorHeight)

                // Calculate the distance from the origin
                var clampedPosition = SIMD3<Float>(newPosition.x, clampedY, newPosition.z)

                // Check if the position exceeds the sphere's radius
                let distanceFromCenter = length(clampedPosition)
                if distanceFromCenter > radius {
                    // Normalize the position and scale it to be on the sphere's surface
                    clampedPosition = normalize(clampedPosition) * radius
                    // Ensure the clamped Y value stays above the floor after normalization
                    clampedPosition.y = max(clampedPosition.y, floorHeight)
                }

                // Apply the clamped position back to the entity
                value.entity.position = clampedPosition
            }
            .onEnded { value in
                // Optional: Add any behavior for when the drag gesture ends
            }
    }

}

#Preview(immersionStyle: .full) {
    ImmersiveView()
        .environment(AppModel())
}
