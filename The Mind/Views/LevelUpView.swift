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
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
//            Color.black.opacity(0.4) // Semi-transparent black background
//                .edgesIgnoringSafeArea(.all)
                    
            VStack {
                Text("Level Up!") // Display the message
                    .font(.title)
                    .fontWeight(.bold)
                Text("Congratulations, you reached level \(game.level)!")
                        
                Button("Continue") { // Button to dismiss the popup
                    game.resume()// Perform the action when the user taps the button
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
