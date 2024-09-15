//
//  ContentView.swift
//  ABrightIdea
//
//  Created by Joseph Simpson on 9/13/24.
//

import SwiftUI
import RealityKit
import RealityKitContent

struct ContentView: View {

    @Environment(AppModel.self) private var appModel
    @Environment(\.scenePhase) private var scenePhase


    var body: some View {
        VStack {

            Text("A Bright Idea")
                .font(.extraLargeTitle2)
            Text("By Joseph Simpson")
            Text("Vision Hack 2024")

            ToggleImmersiveSpaceButton()
                .padding()


            Text("Exit the space by tapping the floor three times.")
                .font(.caption)


        }
        .padding()
        .onChange(of: scenePhase, initial: true) {
            switch scenePhase {
            case .inactive, .background:
                appModel.mainWindowOpen = false
            case .active:
                appModel.mainWindowOpen = true
                appModel.exitCount = 0
            @unknown default:
                appModel.mainWindowOpen = false
            }
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
