//
//  ContentView.swift
//  The Mind
//

import SwiftUI

public var syncPressed = false

struct TM_View: View {
    @ObservedObject var game: TM_ViewModel
    
    @State private var cardOffset: CGSize = .zero
    @State private var showCard: Bool = false
    
    @State var bots = 3
    var bot = ["😃", "😎", "😴"]
    
    var body: some View {
        
        ZStack{
            backgroundView()
            
            
            VStack {
                
                //reset button
                HStack(){
                    
                    Spacer()
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.red, lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                        
                        Button {
                            game.playReset()
                        } label: {
                            Text("X")
                        }
                    }
                    
                }
                
                // bot view
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                    ForEach(bot[0..<bots], id: \.self){ bot in
                        botView(content: bot)
                            .aspectRatio(1/0.8, contentMode: .fit)
                    }
                }
                
                // Displays the game board.
                boardView(card: game.boardCard)
                
                // player view
                HStack(){
                    LazyVGrid(columns: [GridItem(
                        .adaptive(minimum:80), spacing: -50)]){
                            ForEach(game.playerHand.suffix(6)) { card in
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
                        .frame(width: /*@START_MENU_TOKEN@*/270.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                    
                    Spacer()
                    
                    // joker and play card buttons
                    VStack{
                        
                        ZStack{
                            Image("star")
                                .resizable()
                                .aspectRatio(1,contentMode: .fit)
                        }
                        
                        ZStack{
                            if syncPressed == true {
                                playButton()
                            }
                            else {
                                syncButton()
                            }
                        }
                    }
                }
            }
            .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)}
        
        
    }
    
    func geometry(for card: TM_Model<String>.Card) -> CGSize {
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
        Image("Background")
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
    var card: TM_Model<String>.Card
    @State private var cardOffset: CGSize = .zero
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .frame(height: 300)
            
            if card.value != 0 {
                cardView(cardName: card.filename)
                    .frame(width: 80.0, height: 100.0)
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
    var content: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(#colorLiteral(red: 0.97, green: 0.94, blue: 0.89, alpha: 1)))

            Image("happy")
                .resizable()
                .frame(width: 70.0, height: 70.0)
                
        }
    }
}


// This generates the preview in Xcode. Don't tinker with this.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let game = TM_ViewModel()
        TM_View(game: game)
    }
}
