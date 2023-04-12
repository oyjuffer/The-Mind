//
//  GameOverView.swift
//  The Mind
//
//  Created by O.Y. Juffer on 24/03/2023.
//

import SwiftUI

struct GameWonView: View {
    @ObservedObject var game: TM_ViewModel

    var body: some View {
            VStack {
                Text("Congrats!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)

                Text("You finished the game by reaching level \(game.level)")
                Text("Play time: \(game.gameTime)s")
                    
                Button("Play again") {
                    game.reset()
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
