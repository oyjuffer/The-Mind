//
//  GameOverView.swift
//  The Mind
//
//  Created by O.Y. Juffer on 24/03/2023.
//

import SwiftUI

struct GameOverView: View {
    @ObservedObject var game: TM_ViewModel

    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
//            Color.black.opacity(0.4) // Semi-transparent black background
//                .edgesIgnoringSafeArea(.all)
                    
            VStack {
                Text("Game Over!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)
                Text("Congratulations, you super suck!")
                        
                Button("Return") { // Button to dismiss the popup
                    game.reset()// Perform the action when the user taps the button
                }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(20)
                .shadow(radius: 20)
            }
    }
}
