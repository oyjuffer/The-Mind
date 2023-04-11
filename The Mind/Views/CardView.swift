//
//  CardView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/31/23.
//

import SwiftUI

struct CardView: View {
    @ObservedObject var game: TM_ViewModel
    var card: String
    var cardHeight: CGFloat
    
    var body: some View {
        ZStack{
            Image(card)
                .resizable()
                .aspectRatio(2/3, contentMode: .fit)
        }
        .frame(width: 100, height: cardHeight)
        .transition(.scale(scale: 1))
    }
}
