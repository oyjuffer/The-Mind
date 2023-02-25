//
//  The_MindApp.swift
//  The Mind
//
//  Created by Lemon on 18/02/2023.
//

import SwiftUI

@main
struct The_MindApp: App {
    let game = Interpreter()
    var body: some Scene {
        WindowGroup {
            ContentView(game: game)
        }
    }
}
