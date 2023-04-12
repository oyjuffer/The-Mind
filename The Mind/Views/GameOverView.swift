//
//  GameOverView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/25/23.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var game: TM_ViewModel

    var body: some View {
            VStack {
                Text("Game Over!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)
                Text("You reached level \(game.level)")
                Text("Play time: \(Int(game.gameTime))s")
                    
                Button("Back to menu") {
                    game.reset()
                    game.menu()
                }
                    .padding()
                    .background(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color(#colorLiteral(red: 0.97, green: 0.94, blue: 0.89, alpha: 1)))
                .cornerRadius(20)
                .shadow(radius: 20)
                .frame(width: 350, height: 200)
            }
    }
