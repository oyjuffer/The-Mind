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
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color(#colorLiteral(red: 0.97, green: 0.94, blue: 0.89, alpha: 1)))
                .frame(width: 100, height: 100)
            
            // Calculates the time difference in order to show an emotion for the bot
            let timeDifference = Double(round(100 * bot.estimate) / 100) - game.gameTime
            
            if timeDifference <= 15 || game.popupWin{
                Image("happy")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            } else if timeDifference > 15 && timeDifference <= 50 {
                Image("normal")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            } else if timeDifference > 50 || game.popupLost{
                Image("sad")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 70, height: 70)
                    .clipShape(Circle())
            }
            

            VStack {
                Spacer()
                
                HStack {
                    ZStack {
                        if game.botsPlaying[bot.id]{
                            //Shows a card next to the bot whenever the bot wants to play
                            CardView(game: game, card: "back-card", cardHeight: 60)
                                .animation(.spring())
                                .onAppear {
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        game.toggleBotsPlaying(id: bot.id)
                                        
                                    }
                                }
                        } else {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.clear)
                                .frame(width: 100, height: 60)
                        }
                            
                    }
                    .offset(x: -15, y: 30)

                    ZStack {
                        //Shows the number of cards in the hand of the bot
                        Rectangle()
                            .fill(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                            .frame(width: 30, height: 30)
                            .cornerRadius(5)
                        
                        Text("\(content)")
                            .foregroundColor(.white)
                            .font(.system(size: 14))
                    }
                    .offset(x: -6, y: 15)
                }
            }
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
