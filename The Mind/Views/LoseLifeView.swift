//
//  LoseLifeView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/19/23.
//

import SwiftUI

struct LoseLifeView: View {
        @ObservedObject var game: TM_ViewModel
        
    var body: some View {
            VStack {
                Text("Oh no!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)
                Text("You lost a life! You have \(game.life) lives left!")
                        
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
            }
        }
