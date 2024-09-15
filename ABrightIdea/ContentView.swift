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

    @State var tempLightValue: Double = 1

    var body: some View {
        VStack {

            Text("Enter the")
            Text("Bright Idea Dome")
                .font(.extraLargeTitle2)

            ToggleImmersiveSpaceButton()
                .padding()


        }
        .padding()
        .onChange(of: tempLightValue) { _, newValue in
            appModel.lightIntensity = Float(newValue)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
