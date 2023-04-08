//
//  GameView.swift
//
//  This is the game view which displays the game when it is running.

import SwiftUI

public var syncPressed = false

struct GameView: View {
    @ObservedObject var game: TM_ViewModel
    
    @State private var cardOffset: CGSize = .zero
    @State private var showCard: Bool = false
    @State private var showPopUp: Bool = false
    @State private var isMenuOpen: Bool = false
    
    @Namespace private var animation
    
    var body: some View {
        ZStack{
            ZStack(){
                backgroundView()
                
                VStack {
                    
                    //reset button
                    HStack(){
                        Spacer()
                        Text("Level \(game.level)")
                            .font(.system(size: 30))
                        Spacer()
                        
                        
                        ZStack{
                            Menu(content: {
                                // Menu items
                                Button(action: {
                                    if (game.activeBots){
                                        // Pause the game
                                        game.pause()
                                    } else {
                                        game.resume()
                                    }
                                    
                                }, label: {
                                    if (game.activeBots){
                                        // Pause the game
                                        Text("Pause Game")
                                    } else {
                                        Text("Resume Game")
                                    }
                                    
                                })
                                Button(action: {
                                    // Go back to main menu
                                    game.pause()
                                    game.toggleWarning()
                                }, label: {
                                    Text("Main Menu")
                                })
                            }, label: {
                                Button(action: {
                                    isMenuOpen.toggle()
                                }, label: {
                                    Image(systemName: "list.dash")
                                        .frame(width: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                                        .font(.system(size: 24, weight: .bold))
                                        .foregroundColor(.black)
                                })
                            })
                        }
                        
                    }
                    
                    // bot view
                    LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                        ForEach(game.bots, id: \.id) { bot in
                            
                            BotView(game: game, content: bot.hand.count, card: game.boardCard, bot: bot, namespace: animation)
                                .aspectRatio(1/0.8, contentMode: .fit)
                        }
                    }
                    
                    // joker show cards of bots
                    if (game.shurikenActivated){
                        LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                            ForEach(game.bots, id: \.id) { bot in
                                if let lastCard = bot.hand.last{
                                    CardView(game: game, card: lastCard.filename)
                                        .aspectRatio(1/2, contentMode: .fit)
                                        .matchedGeometryEffect(id: lastCard.id, in: animation)
                                        .transition(AnyTransition.asymmetric(insertion: .opacity, removal: .opacity))
                                } else{
                                    RoundedRectangle(cornerRadius: 20)
                                        .fill(Color.clear)
                                        .frame(height: 120)
                                }
                            }
                        }
                    }
                    
                    boardView(card: game.boardCard, animation: animation, namespace: animation, game: game)
                    
                    // player view
                    HStack(){
                        // joker and play card buttons
                        VStack{
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.clear)
                                    .frame(width: 70, height: 70)
                                
                                
                                Image("star")
                                    .resizable()
                                    .aspectRatio(1,contentMode: .fit)
                                
                                
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Spacer()
                                        
                                        Button(action: {
                                            game.toggleShuriken()
                                        }) {
                                            ZStack {
                                                Rectangle()
                                                    .fill(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                                                    .frame(width: 30, height: 30)
                                                    .cornerRadius(5)
                                                
                                                Text("\(game.shuriken)")
                                                    .foregroundColor(.white)
                                                    .font(.system(size: 14))
                                            }
                                            .offset(x: 10, y: -10)
                                        }
                                    }
                                }
                            }
                            
                            ZStack{
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(Color.clear)
                                    .frame(width: 70, height: 70)
                                
                                
                                Image("mascot")
                                    .resizable()
                                    .aspectRatio(1,contentMode: .fit)
                                
                                
                                VStack {
                                    Spacer()
                                    
                                    HStack {
                                        Spacer()
                                        
                                        ZStack {
                                            Rectangle()
                                            //                                                .fill(Color(#colorLiteral(red: 0.1205435768, green: 0.2792448401, blue: 0.4109080434, alpha: 1)))
                                                .fill(Color(#colorLiteral(red: 0.97, green: 0.94, blue: 0.89, alpha: 1)))
                                                .frame(width: 30, height: 30)
                                                .cornerRadius(5)
                                            
                                            Text("\(game.life)")
                                            //                                                .foregroundColor(.white)
                                                .foregroundColor(.black)
                                                .font(.system(size: 14))
                                        }
                                        .offset(x: 10, y: -10)
                                    }
                                }
                            }
                            Spacer()
                        }
                        
                        Spacer()
                        
                        LazyVGrid(columns: [GridItem(
                            .adaptive(minimum:80), spacing: -50, alignment: .trailing)], alignment: .trailing){
                                ForEach(game.playerHand.suffix(5)) { card in
                                    CardView(game: game, card: card.filename)
                                        .matchedGeometryEffect(id: card.id, in: animation)
                                        .aspectRatio(0.2, contentMode: .fill)
                                        .onTapGesture {
                                            withAnimation {
                                                cardOffset = geometry(for: card)
                                                showCard = true
                                                game.playCard()
                                            }
                                        }
                                }
                            }
                            .padding(.leading, CGFloat(40))
                        //                            .padding(.leading, UIScreen.main.bounds.width - CGFloat(40))
                            .frame(width: /*@START_MENU_TOKEN@*/270.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                        
                    } .allowsHitTesting(game.activateView)
                }
                .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
                
                
            }
            if game.popupWin {
                VStack {
                    LevelUpView(game: game)
                }
            } else if game.popupLost {
                VStack {
                    LoseLifeView(game: game)
                }
            } else if game.popupMenu {
                VStack {
                    WarningView(game: game)
                }
            } else if game.popupOver {
                VStack {
                    GameOverView(game: game)
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

// background image
struct backgroundView: View {
    var body: some View {
        Image("background")
            .resizable()
            .scaledToFill()
            .edgesIgnoringSafeArea(.all)
            .opacity(0.8)
    }
}


// generates the board
struct boardView: View {
    var card: Card
    @State private var cardOffset: CGSize = .zero
    let animation: Namespace.ID
    let namespace: Namespace.ID
    @ObservedObject var game: TM_ViewModel
    //    var botPlays: Bool
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .frame(height: 200)
            
            if card.value != 0 {
                
                CardView(game: game, card: card.filename)
                    .frame(width: 80.0, height: 200.0)
                    .offset(cardOffset)
                    .matchedGeometryEffect(id: card.id, in: animation)
//                    .gesture(
//                        DragGesture()
//                            .onChanged { gesture in
//                                cardOffset = gesture.translation
//                            }
//                            .onEnded { _ in
//                                withAnimation {
//                                    cardOffset = .zero
//                                    //                                        game.setBoardCard(card: game.cardToPlay)
//                                    //                                        game.boardCard = game.cardToPlay
//                                }
//                            }
//                    )
            }
        }
    }
}

