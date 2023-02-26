//
//  The_MindApp.swift
//  The Mind
//
//  Created by Lemon on 18/02/2023.
//

import SwiftUI

@main
struct The_MindApp: App {
    let game = TM_ViewModel()
    var body: some Scene {
        WindowGroup {
            TM_View(game: game)
        }
    }
}
