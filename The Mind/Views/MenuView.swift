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
            Image("bg_menu")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .padding(.bottom,150)
            
            VStack {
                // Title at the top
                Image("title")
                    .resizable()
                    .frame(width: 400, height: 100)

                // Buttons
                VStack(spacing: 15) {
                    Button(action: {
                        game.play()
                    }) {
                        Text("Play")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                            .cornerRadius(25)
                    }
                    
                    Button(action: {
                        game.instructions()
                    }) {
                        Text("Instructions")
                            .font(.title)
                            .foregroundColor(.white)
                            .frame(width: 200, height: 50)
                            .background(Color( #colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                            .cornerRadius(25)
                    }
                }
                .padding(.top, 360)
                .padding(.bottom, 150)
                
            }

        }
        
    }
}

