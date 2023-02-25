//
//  ContentView.swift
//  The Mind
//

import SwiftUI

struct ContentView: View {
    var game: Interpreter
    
    @State var level = 8
    var values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    @State var bots = 3
    var bot = ["😃", "😎", "😴"]
    
    var body: some View {
        
        VStack {
            
            Text("Level \(level)")
            
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem()]) {
                ForEach(bot[0..<bots], id: \.self){ bot in
                    botView(content: bot)
                        .aspectRatio(1/0.8, contentMode: .fit)
                }
            }
            
            // game Board
            RoundedRectangle(cornerRadius: 20)
                .stroke(.red, lineWidth: 3)
                .frame(height: 300)
            
            // player Cards
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                ForEach(game.playerHand){ card in
                    playerView(card: card)
                        .aspectRatio(1/1.2, contentMode: .fit)
                }
            }
            
            Spacer()
            
            // play the selecte card button
            Button(action: {print("record clicked")}, label: {Text("Play Card")})
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
    }
}


// generates player cards.
struct playerView: View {
    let card: GameLogic<String>.Card
    
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .stroke(lineWidth: 3)
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
        let game = Interpreter()
        ContentView(game: game)
    }
}
