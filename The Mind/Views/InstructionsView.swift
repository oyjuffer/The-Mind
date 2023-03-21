//
//  InstructionsView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/19/23.
//

import SwiftUI

struct InstructionsView: View {
    var body: some View {
        ZStack(alignment: .top){
            Image("background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)
                .opacity(0.8)
            
            ScrollView {
                VStack(alignment: .center, spacing: 20) {
                    Image("title")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                    
                    Text("The deck contains cards numbered 1-100, and during the game you try to complete 12, 10, or 8 levels of play with 2, 3, or 4 players. In a level, each player receives a hand of cards equal to the number of the level: one card in level 1, two cards in level 2, etc. Collectively you must play these cards into the center of the table on a single discard pile in ascending order but you cannot communicate with one another in any way as to which cards you hold.")
                        .padding()
                        .multilineTextAlignment(.center)
//                        .textAlignment = NSTextAlignment.Justified
                            
                            ForEach(0..<20) { index in
                                Text("Scrolling Content \(index)")
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    
                            }
                        }
                    }
            
            
        }
        
    }
}

struct InstructionsView_Previews: PreviewProvider {
    static var previews: some View {
        InstructionsView()
    }
}
