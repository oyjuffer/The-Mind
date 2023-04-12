//
//  LevelUpView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/19/23.
//

import SwiftUI

struct LevelUpView: View {
    @ObservedObject var game: TM_ViewModel

    var body: some View {
            VStack {
                Text("Level Up!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)
                Text("Congratulations, you reached level \(game.level)!")
                    
                if game.level == 4 || game.level == 7 || game.level == 10{
                    Text("You have earned an extra life!")
                }
                    
                if game.level == 3 || game.level == 6 || game.level == 9 {
                    Text("You have earned an extra shuriken!")
                }

                Button("Continue") { // Button to dismiss the popup
                    game.closePopup()
                    game.resume()
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
