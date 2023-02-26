//
//  The_MindApp.swift
//  The Mind
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
