//
//  ContentView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 2/19/23.
//

import MeshKit
import SwiftUI

#if !os(tvOS)
struct ContentView: View {
    private let locationRange: ClosedRange<Float> = -0.5 ... 0.5

    @AppStorage("selectedColorSpace")
    private var colorSpace: String = CGColorSpace.sRGB as String

    @State
    private var colors: MeshColorGrid = MeshKit.generate(
        palette: [.randomPalette()],
        withRandomizedLocations: true,
        locationRandomizationRange: -0.5 ... 0.5
    )
    @State
    private var lastColors: MeshColorGrid?
    @State
    private var state: RenderState = .none

    @State
    private var isShowingAboutView: Bool = false
    @State
    private var isShowingUI: Bool = true

    enum RenderState {
        case none
        case rendering
        case saved
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            Group {
                if isShowingUI {
                    Mesh(colors: colors, colorSpace: .init(name: CGColorSpace.linearSRGB))
                } else {
                    Mesh(
                        colors: colors,
                        animatorConfiguration: .init(meshRandomizer: .withMeshColors(colors)),
                        colorSpace: .init(name: CGColorSpace.linearSRGB)
                    )
                }
            }
            .id(colors)
            .transition(.blurWithoutScale.animation(.easeInOut))
            .ignoresSafeArea()
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isShowingUI.toggle()
                }
            }
            .onChange(of: colors) { _ in
                state = .none
            }

            if isShowingUI {
                Menu {
                    Button {
                        let size = UIScreen.main.nativeBounds.size
                        render(MeshSize(width: Int(size.height), height: Int(size.width)))
                    } label: {
                        Label("Landscape", systemImage: "rectangle")
                    }

                    Button {
                        let size = UIScreen.main.nativeBounds.size
                        render(MeshSize(width: Int(size.width), height: Int(size.height)))
                    } label: {
                        Label("Portrait", systemImage: "rectangle.portrait")
                    }

                    Button {
                        render()
                    } label: {
                        Label("Square", systemImage: "square")
                    }
                } label: {
                    Group {
                        switch state {
                        case .none:
                            Label("Save", systemImage: "square.and.arrow.down")
                                .fixedSize(horizontal: true, vertical: false)
                        case .rendering:
                            ProgressView()
                                .frame(alignment: .center)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(width: 25)
                        case .saved:
                            Image(systemName: "checkmark")
                                .frame(alignment: .center)
                                .fixedSize(horizontal: true, vertical: false)
                                .frame(width: 25)
                        }
                    }
                    .font(.system(.headline, design: .rounded, weight: .bold))
                    .frame(height: 25)
                } primaryAction: {
                    render()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: state == .none ? 20 : 50, style: .continuous)
                        .fill(.thinMaterial)
                        .shadow(radius: 30, y: 8)
                )
                .zIndex(999)
                .transition(.blur)
                .animation(.spring(), value: state)
                .padding()
                .padding(.horizontal, 60)
                .allowsHitTesting(state != .rendering)
            }

            HStack {
                if lastColors != nil, isShowingUI {
                    Button {
                        colors = lastColors ?? colors
                        lastColors = nil
                    } label: {
                        Image(systemName: "arrow.uturn.backward")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(width: 25, height: 25)
                            .padding()
                            .background(
                                Circle()
                                    .fill(.thinMaterial)
                                    .shadow(radius: 30, y: 8)
                            )
                    }
                    .transition(.blur)
                }

                Spacer()
                if isShowingUI {
                    Menu {
                        ForEach(Hue.allCases, id: \.self) { hue in
                            Menu(hue.displayTitle) {
                                Button {
                                    lastColors = colors
                                    colors = MeshKit.generate(
                                        palette: [hue],
                                        luminosity: .bright,
                                        withRandomizedLocations: true,
                                        locationRandomizationRange: locationRange
                                    )
                                } label: {
                                    Label("Vibrant", systemImage: "light.max")
                                }

                                Button {
                                    lastColors = colors
                                    colors = MeshKit.generate(
                                        palette: [hue],
                                        luminosity: .light,
                                        withRandomizedLocations: true,
                                        locationRandomizationRange: locationRange
                                    )
                                } label: {
                                    Label("Light", systemImage: "sun.max")
                                }

                                Button {
                                    lastColors = colors
                                    colors = MeshKit.generate(
                                        palette: [hue],
                                        luminosity: .dark,
                                        withRandomizedLocations: true,
                                        locationRandomizationRange: locationRange
                                    )
                                } label: {
                                    Label("Dark", systemImage: "sun.min")
                                }
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.triangle.2.circlepath")
                            .font(.system(.headline, design: .rounded, weight: .bold))
                            .frame(width: 25, height: 25)
                            .padding()
                            .background(
                                Circle()
                                    .fill(.thinMaterial)
                                    .shadow(radius: 30, y: 8)
                            )
                    } primaryAction: {
                        lastColors = colors
                        colors = MeshKit.generate(
                            palette: [.randomPalette()],
                            withRandomizedLocations: true,
                            locationRandomizationRange: locationRange
                        )
                    }
                    .transition(.blur)
                }
            }
            .padding()
        }
        .overlay(alignment: .topTrailing) {
            if isShowingUI {
                Button {
                    isShowingAboutView.toggle()
                } label: {
                    Image(systemName: "info")
                        .font(.system(.headline, design: .rounded, weight: .bold))
                        .frame(width: 25, height: 25)
                        .padding()
                        .background(
                            Circle()
                                .fill(.thinMaterial)
                                .shadow(radius: 30, y: 8)
                        )
                }
                .popover(isPresented: $isShowingAboutView) {
                    AboutView()
                }
                .padding()
                .transition(.blur)
            }
        }
        .statusBarHidden()
    }

    func render(_ size: MeshSize = MeshSize(width: 4096, height: 4096)) {
        state = .rendering
        Task(priority: .userInitiated) {
            do {
                let url = try await colors.export(
                    size: size,
                    subdivisions: 64,
                    colorSpace: .init(name: colorSpace as CFString),
                    fileFormat: .png
                )

                if let image = UIImage(contentsOfFile: url.path) {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    state = .saved
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif
