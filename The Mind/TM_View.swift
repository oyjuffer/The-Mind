//
//  ContentView.swift
//  The Mind
//

import SwiftUI

struct TM_View: View {
    @ObservedObject var game: TM_ViewModel
    
    @State var level = 8

    @State var bots = 3
    var bot = ["😃", "😎", "😴"]
    
    var body: some View {
        
        VStack {
            
            Text("Level \(level)")
            
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
                LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                    ForEach(game.playerHand){ card in
                        playerView(card: card)
                            .aspectRatio(0.8, contentMode: .fill)
                    }
                }
                .frame(width: /*@START_MENU_TOKEN@*/270.0/*@END_MENU_TOKEN@*/, height: /*@START_MENU_TOKEN@*/100.0/*@END_MENU_TOKEN@*/)
                
                Spacer()
                
//              joker and play card buttons
                VStack{
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.yellow, lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                        Text("Joker")
                    }
                    
                    ZStack{
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(.green, lineWidth: 3)
                            .aspectRatio(1, contentMode: .fit)
                        
                        Button {
                            game.playCard()
                        } label: {
                            Text("Play")
                        }
                    }
                }
            }
            
            
            
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}


// generates player cards.
struct playerView: View {
    let card: TM_Model<String>.Card
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
            Text("\(card.value)")
        }
    }
}

struct boardView: View {
    let card: TM_Model<String>.Card
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 20)
                .stroke(.red, lineWidth: 3)
                .frame(height: 300)
            RoundedRectangle(cornerRadius: 20)
                .stroke(.purple, lineWidth: 3)
                .frame(width: 80.0, height: 100.0)
            Text("\(card.value)")
        }
    }
}
// generates bot frames
struct botView: View {
    var content: String
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
            Text(content)
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
