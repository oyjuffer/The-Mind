//
//  TM_Menu.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/10/23.
//

import SwiftUI

struct MenuView: View {
    @ObservedObject var game: TM_ViewModel
    
    var body: some View {
        ZStack{
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
            
            VStack {
                // Title at the top
                Text("The Mind")
                    .font(.largeTitle)
                    .padding(.top, 50)
                
                // Three buttons in the middle with round corners
                VStack(spacing: 30) {
                    Button(action: {
                        game.play()
                    }) {
                        Text("Play")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.blue)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        // Action for button 2
                    }) {
                        Text("Instructions")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.green)
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        // Action for button 3
                    }) {
                        Text("Button 3")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color.orange)
                            .cornerRadius(25)
                    }
                }
                .padding(.top, 50)
                
                // Image at the bottom
                Image("mascot")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: UIScreen.main.bounds.width, height: 200)
                    .clipped()
            }
        }
    }
}

