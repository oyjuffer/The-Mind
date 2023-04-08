//
//  BotView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 4/7/23.
//

import SwiftUI

struct BotView: View {
    @ObservedObject var game: TM_ViewModel
    
    var content: Int
    var card: Card
    var bot: Bot
    let namespace: Namespace.ID
    @State private var cardOffset: CGSize = .zero
//    @State var wantsToPlay = false
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(#colorLiteral(red: 0.97, green: 0.94, blue: 0.89, alpha: 1)))
                .frame(width: 110, height: 110)
            
            Image("happy")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 80, height: 80)
                .clipShape(Circle())
                
            
            VStack {
                Spacer()
                
                HStack {
                    ZStack {

                    }
                    .offset(x: 1, y: -10)
                    
                    Spacer()
                    
                    ZStack {
                        Rectangle()
                            .fill(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                            .frame(width: 30, height: 30)
                            .cornerRadius(5)
                        
                        Text("\(content)")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                    .offset(x: 10, y: -10)
                }
            }
            
//            VStack {
//                if game.botsPlaying[bot.id]{
//                    let _ = print(bot.id)
//                    CardView(cardName: "20", namespace: namespace, cardHeight: 80)
//                        .animation(.spring())
//                        .onAppear {
//                            withAnimation {
//                                cardOffset = geometry(for: game.boardCard)
////                                game.playCard()
//                                game.setBoardCard(card: game.cardToPlay)
//
////                                game.boardCard = game.cardToPlay
//                                game.toggleBotsPlaying(id: bot.id)
//                                game.toggleBotPlays()
//                            }
//                        }
//                }
//            }
//            CardView(cardName: "\(card.value)", namespace: namespace, cardHeight: 80)
//                .onChange(of: bot.play) { _ in
//                    withAnimation {
//                        cardOffset = geometry(for: lastCard)
//                    }
//                }
        }
    }
    
    func geometry(for card: Card) -> CGSize {
        guard let index = game.playerHand.firstIndex(where: { $0.id == card.id}) else {
            return .zero
        }
        let cardWidth: CGFloat = 60
        let totalWidth = cardWidth * CGFloat(game.playerHand.count)
        let offset = (totalWidth / 2) - (cardWidth / 2) - (CGFloat(index) * cardWidth)
        return CGSize(width: offset, height: 0)
    }
}
