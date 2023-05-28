//
//  AboutView.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 2/19/23.
//

import SwiftUI

struct AboutView: View {
    @AppStorage("selectedColorSpace")
    private var colorSpace: String = CGColorSpace.sRGB as String

    var body: some View {
        VStack {
            Image("Icon")
                .resizable()
                .aspectRatio(1 / 1, contentMode: .fit)
                .frame(maxWidth: 100)
            Text("Acrylic")
                .font(.largeTitle)
                .bold()

            Picker("Color Space", selection: $colorSpace) {
                Text("Linear SRGB")
                    .tag(CGColorSpace.linearSRGB as String)
                Text("sRGB")
                    .tag(CGColorSpace.sRGB as String)
                Text("Display P3")
                    .tag(CGColorSpace.displayP3 as String)
            }

            LinksView()
            CreditsView()
            Spacer()
        }
        .padding()
        .presentationDetents([.fraction(0.8)])
        .presentationDragIndicator(.visible)
    }

    struct LinksView: View {
        @Environment(\.openURL)
        var openUrl

        var body: some View {
            GroupBox {
                VStack(alignment: .leading) {
                    if let url = URL(string: "https://ethanlipnik.com/acrylic") {
                        Link(destination: url) {
                            Label("Website", systemImage: "globe")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if let url = URL(string: "https://github.com/EthanLipnik/MeshKit") {
                        Link(destination: url) {
                            Label("MeshKit", systemImage: "circle.grid.cross")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }

                    if let url = URL(string: "https://github.com/Nekitosss/MeshGradient") {
                        Link(destination: url) {
                            Label("MeshGradient", systemImage: "square.stack.3d.forward.dottedline")
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                }
            } label: {
                Label("Links", systemImage: "link")
            }
        }
    }

    struct CreditsView: View {
        @Environment(\.openURL)
        var openUrl

        var body: some View {
            GroupBox {
                userView(
                    "Ethan Lipnik",
                    username: "EthanLipnik",
                    profilePic: "Ethan",
                    body: "Developer and Designer"
                )

                Divider()

                userView(
                    "Nikita Patskov",
                    username: "NikitkaPa",
                    profilePic: "Nik",
                    body: "MeshGradient Library"
                )

                Divider()

                userView(
                    "Alexander Vilinskyy",
                    username: "vilinskyy",
                    profilePic: "Alexander",
                    body: "Icon Designer"
                )
            } label: {
                Label("Credits", systemImage: "person.crop.square.filled.and.at.rectangle")
            }
        }

        @ViewBuilder
        func userView(
            _ name: String,
            username: String,
            profilePic: String,
            body: String
        ) -> some View {
            Button {
                if let url = URL(string: "https://twitter.com/" + username) {
                    openUrl(url)
                }
            } label: {
                HStack {
                    Image("Credits/" + profilePic)
                        .resizable()
                        .aspectRatio(1 / 1, contentMode: .fit)
                        .frame(height: 45)
                        .clipShape(RoundedRectangle(cornerRadius: 6, style: .continuous))

                    VStack(alignment: .leading) {
                        HStack {
                            Text(name)
                                .font(.headline)
                                .fixedSize(horizontal: true, vertical: false)
                            Text("@" + username)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .foregroundStyle(.secondary)
                                .font(.callout)
                        }
                        Text(body)
                    }
                }
            }.buttonStyle(.plain)
        }
    }

#if os(tvOS)
    struct GroupBox<Content: View, LabelContent: View>: View {
        let content: () -> Content
        let label: () -> LabelContent

        init(
            @ViewBuilder content: @escaping () -> Content,
            @ViewBuilder label: @escaping () -> LabelContent
        ) {
            self.content = content
            self.label = label
        }

        var body: some View {
            VStack {
                label()
                    .frame(maxWidth: .infinity, alignment: .leading)
                content()
            }
        }
    }
#endif
}
