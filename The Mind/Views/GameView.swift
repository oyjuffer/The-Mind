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
                            botView(content: bot.hand.count)
                                .aspectRatio(1/0.8, contentMode: .fit)
                        }
                    }
                    // board view
                    boardView(card: game.boardCard)

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
                            
                            
                            

                            
//                            ZStack{
//                                if syncPressed == true {
//                                    playButton()
//                                }
//                                else {
//                                    syncButton()
//                                }
//                            }
                        }
                        
                        Spacer()
                        
                        LazyVGrid(columns: [GridItem(
                            .adaptive(minimum:80), spacing: -50, alignment: .trailing)], alignment: .trailing){
                                ForEach(game.playerHand.suffix(5)) { card in
                                    cardView(cardName: card.filename)
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

struct syncButton: View {
    @GestureState var tap = false
    @State var press = false
    
    var body: some View {
        ZStack{
            Text("Sync")
                .opacity(press ? 0 : 1)
                .scaleEffect(press ? 0 : 1)
            
            Text("Play2")
                .opacity(press ? 1 : 0)
                .scaleEffect(press ? 1 : 0)
        }
        .frame(width: 70, height: 70)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(press ? #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) : #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) )]), startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .stroke(Color.clear, lineWidth: 10)
                    .shadow(color: Color(press ? #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) : #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) ), radius: 3, x: 3, y: 3)
            }
        )
        .clipShape(Circle())
        .overlay(
            Circle()
                .trim(from: tap ? 0.001 : 1, to: 1)
                .stroke(Color(press ? #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) : #colorLiteral(red: 0.3847309053, green: 0.6923297048, blue: 0.9472768903, alpha: 1)), style:  StrokeStyle(lineWidth: 5, lineCap: .round))
                .frame(width: 65, height: 65)
                .rotationEffect(Angle(degrees: 90))
                .rotation3DEffect(Angle(degrees: 180), axis: (x: 1, y: 0, z: 0))
                .animation(Animation.easeInOut)
        )
        .scaleEffect(tap ? 1.2 : 1)
        .gesture(LongPressGesture().updating($tap) {currentState, gestureState, transaction in
            gestureState = currentState
        }
            .onEnded{value in self.press.toggle()
                syncPressed = false
            }
        )
    }
}

struct playButton: View {
    @GestureState var tap = false
    @State var press = false
    
    var body: some View {
        ZStack{
            Text("Play")
        }
        .frame(width: 70, height: 70)
        .background(
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color(press ? #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) : #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) )]), startPoint: .topLeading, endPoint: .bottomTrailing)
                Circle()
                    .stroke(Color.clear, lineWidth: 10)
                    .shadow(color: Color(press ? #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) : #colorLiteral(red: 0.9229335189, green: 0.9617477059, blue: 0.995072186, alpha: 1) ), radius: 3, x: 3, y: 3)
            }
        )
        .clipShape(Circle())
        .scaleEffect(tap ? 1.1 : 1)
    }
}

struct cardView: View {
    var cardName: String
    var body: some View {
        Image(cardName)
            .resizable()
            .aspectRatio(2/3, contentMode: .fit)
    }
}

// generates the board
struct boardView: View {
    var card: Card
    @State private var cardOffset: CGSize = .zero
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .frame(height: 300)
            
            if card.value != 0 {
                cardView(cardName: card.filename)
                    .frame(width: 80.0, height: 300.0)
                    .offset(cardOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                cardOffset = gesture.translation
                            }
                            .onEnded { _ in
                                withAnimation {
                                    cardOffset = .zero
                                }
                            }
                    )
            }
        }
    }
}
// generates bot frames
struct botView: View {
    var content: Int
    
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
        }
    }
}
