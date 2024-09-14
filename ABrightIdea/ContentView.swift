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

    @State var tempLights: Double = 5

    var body: some View {
        VStack {

            Text("Enter the")
            Text("Bright Idea Dome")
                .font(.extraLargeTitle2)

            ToggleImmersiveSpaceButton()

            Slider(value: $tempLights,
                  in: 5...25,
                  step: 1,
                  minimumValueLabel: Text("5"),
                  maximumValueLabel: Text("25"),
                  label: {
                Text("Rating")
            }
            )
            .padding(EdgeInsets(top: 0, leading: 40, bottom: 0, trailing: 40))
        }
        .padding()
        .onChange(of: tempLights) { _, newValue in
            appModel.totalTempLights = Int(newValue)
        }
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
