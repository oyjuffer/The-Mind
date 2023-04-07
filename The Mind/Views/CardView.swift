//
//  CardView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/31/23.
//

import SwiftUI

struct CardView: View {
    var cardName: String
    let namespace: Namespace.ID
    var cardHeight: CGFloat
    
//    var body: some View {
//        Image(cardName)
//            .resizable()
//            .aspectRatio(2/3, contentMode: .fit)
//    }
    
    var body: some View {
        ZStack{
            Image(cardName)
                .resizable()
                .aspectRatio(2/3, contentMode: .fit)
        }
        .frame(width: 100, height: cardHeight)
        .matchedGeometryEffect(id: "\(cardName)",
                               in: namespace)
        .transition(.scale(scale: 1))
    }
}

struct CardView_Previews: PreviewProvider {
    // Create a wrapper view that will let us hold a @Namespace to pass to the view
    struct Wrapper: View {
        @Namespace var animation
        var body: some View {
            CardView(cardName: "1", namespace: animation, cardHeight: 80)
                .padding()
                .background(Color.gray)
        }
    }
    
    static var previews: some View {
        Wrapper()
    }
}
