//
//  ScreensaverView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 2/19/23.
//

#if os(tvOS)
import MeshKit
import SwiftUI

struct ScreensaverView: View {
    @State
    private var colors: MeshColorGrid = MeshKit.generate(
        palette: [.randomPalette()],
        withRandomizedLocations: true
    )

    var body: some View {
        Mesh(colors: colors, animatorConfiguration: .init(meshRandomizer: .withMeshColors(colors)))
            .ignoresSafeArea()
            .onTapGesture {
                colors = MeshKit.generate(
                    palette: [.randomPalette()],
                    withRandomizedLocations: true
                )
            }
    }
}

struct ScreensaverView_Previews: PreviewProvider {
    static var previews: some View {
        ScreensaverView()
    }
}
#endif
