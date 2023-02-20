//
//  AcrylicApp.swift
//  Acrylic
//
//  Created by Ethan Lipnik on 2/19/23.
//

import SwiftUI

@main
struct AcrylicApp: App {
    var body: some Scene {
        WindowGroup {
#if os(tvOS)
            ScreensaverView()
#else
            ContentView()
#endif
        }
    }
}
