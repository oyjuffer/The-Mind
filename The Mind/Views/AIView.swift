//
//  AIView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/25/23.
//

import SwiftUI

struct AIView: View {
    @ObservedObject var game: TM_ViewModel
    @State private var numberOfBots = 3
    @State private var levelDifficulty = 1.0
    
    var body: some View {
        ZStack {
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)

            VStack {
                // Title at the top
                Image("title")
                    .resizable()
                    .frame(width: 400, height: 100)
                
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.clear)
                    .frame(width: 100, height: 100)

                // Picker
                VStack(spacing: 20) {

                    Picker("Number of Bots", selection: $numberOfBots) {
                        Text("1 Bot")
                            .tag(1)
                            .foregroundColor(.white)
                            .font(.system(size: 40))
                        Text("2 Bots")
                            .tag(2)
                            .foregroundColor(.white)
                        Text("3 Bots").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .foregroundColor(.white)
                    .padding()
                    .onChange(of: numberOfBots) { value in
                        game.setBots(bots: value)
                            }
                    
                    // Picker
                    Picker("Difficulty", selection: $levelDifficulty) {
                        Text("Easy").tag(0.75)
                        Text("Medium").tag(1.0)
                        Text("Hard").tag(1.25)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    .onChange(of: levelDifficulty) { value in
                        game.setDifficulty(difficulty: value)
                            }
                    
                    Spacer()
                    
                    Button(action: {
                        game.play()
                        print(game.difficultyLevel)
                        print(game.nBots)
                    }) {
                        Text("Play")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 60)
                            .background(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                            .cornerRadius(25)
                    }
                    
                    Spacer()
                }
            }
        }
    }
}
