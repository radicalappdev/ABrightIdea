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
    @Environment(\.realityKitScene) var scene

    @State var lightType: LightType = .regular

    @State private var entityTransformAtStartOfGesture: Transform?

    private let notificationTrigger = NotificationCenter.default.publisher(for: Notification.Name("RealityKit.NotificationTrigger"))


    var body: some View {
        RealityView { content in
            // Add the initial RealityKit content
            if let root = try? await Entity(named: "Immersive", in: realityKitContentBundle) {
                content.add(root)

                if let dome = root.findEntity(named: "Dome") {
                    dome.scale = .init(x: -1, y: 1, z: 1)
                }

//                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {
                    // Get the RCP entity and save it as a template
//                    content.add(lightBulbTemplate)
//                    lightBulbTemplate.isEnabled = false

                    // Create the first light buld from the template and place it directly in front of the player
//                    let newLightBulb = lightBulbTemplate.clone(recursive: true)
//                    newLightBulb.isEnabled = true
//
//                    newLightBulb.position = SIMD3(x: 0, y: 1, z: -1)
//                    content.add(newLightBulb)
//                }

//                if let lightSource = root.findEntity(named: "LightBulb") {
//                    for _ in 0..<7 {
//                        let lightSourceCopy = lightSource.clone(recursive: true)
//                        let randomX = Float.random(in: -2...2)
//                        let randomY = Float.random(in: 0...2)
//                        let randomZ = Float.random(in: -2...2)
//
//                        lightSourceCopy.position = SIMD3(x: randomX, y: randomY, z: randomZ)
//
//                        if let lightSource = lightSourceCopy.findEntity(named: "LightSource") {
//                            if var pointLight = lightSource.components[PointLightComponent.self] {
//                                pointLight.intensity = Float.random(in: 1000...53927.52)
//                                print("LIGHT Intensity: \(pointLight.intensity)")
//                                lightSource.components.set(pointLight)
//                            }
//
//                        }
//
//                        content.add(lightSourceCopy)
//                    }
//                }
            }
        } update: { content in

            if let root = content.entities.first {

                if let lightBulbTemplate = root.findEntity(named: "LightBulb") {

                    if(appModel.shouldAddBulb) {

                        print("LIGHT Adding in Update")
                        let newLightBulb = lightBulbTemplate.clone(recursive: true)
                        newLightBulb.name = UUID().uuidString
                        let randomX = Float.random(in: -2...2)
                        let randomY = Float.random(in: 0...2)
                        let randomZ = Float.random(in: -2...2)

                        newLightBulb.position = SIMD3(x: randomX, y: randomY, z: randomZ)

                        content.add(newLightBulb)
                        print("LIGHT Added: \(newLightBulb)")

                        // Send notification LightBuldStart
                        NotificationCenter.default.post(
                            name: NSNotification.Name("RealityKit.NotificationTrigger"),
                            object: nil,
                            userInfo: [
                                "RealityKit.NotificationTrigger.Scene": scene,
                                "RealityKit.NotificationTrigger.Identifier": "LightBuldStart"
                            ]
                        )

                        appModel.shouldAddBulb = false

                    }


                }
            }

        }
        .gesture(tapGesture)
        .gesture(dragGesture)
        .gesture(scaleGesture)

        .onReceive(notificationTrigger) { output in

//            print("LIGHT NOTIFICATION: \(output)")

            if let notificationName = output.userInfo?["RealityKit.NotificationTrigger.Identifier"] as? String {
                print("LIGHT NOTIFICATION: \(notificationName)")

                if(notificationName == "LightBulbEnding") {
                    appModel.shouldAddBulb = true
                    print("LIGHT NOTIFICATION: \(appModel.shouldAddBulb)")
                }

            }


        }
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
