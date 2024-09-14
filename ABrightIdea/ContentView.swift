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

    var body: some View {
        VStack {

            Text("Enter the")
            Text("Bright Idea Dome")
                .font(.extraLargeTitle2)

            ToggleImmersiveSpaceButton()

        }
        .padding()
    }
}

#Preview(windowStyle: .automatic) {
    ContentView()
        .environment(AppModel())
}
