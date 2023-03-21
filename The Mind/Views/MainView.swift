//
//  mainView.swift
//  The Mind
//
//  Created by O.Y. Juffer on 10/03/2023.
//

import SwiftUI

// Controls which view is displayed.

// WE NEED:
//  - Splashscreen / main menu screen
//  - Gamescreen (done)
//  - Postgamescreen?


// Check which view to display on the screen. 
struct MainView: View {
    @ObservedObject var game: TM_ViewModel
    
    var body: some View {
        
        if game.gameState == 1{
            MenuView(game: game)
        }
        else if game.gameState == 2{
            GameView(game: game)
        }
//        else if game.gameState == 3{
//            LevelUpView(game:game)
//        }
    }
}

// This generates the preview in Xcode. Don't tinker with this.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = TM_ViewModel()
        MainView(game: game)
    }
}
