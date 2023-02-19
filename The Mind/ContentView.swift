//
//  ContentView.swift
//  The Mind
//

import SwiftUI

struct ContentView: View {
    
    @State var level = 8
    var values = ["1", "2", "3", "4", "5", "6", "7", "8", "9", "10"]
    
    var body: some View {
        
        VStack {
            
            Text("Level \(level)")
            
            // game Board
            RoundedRectangle(cornerRadius: 20)
                .stroke(.red, lineWidth: 3)
                .frame(height: 400)
            
            // player Cards
            LazyVGrid(columns: [GridItem(), GridItem(), GridItem(), GridItem(), GridItem()]) {
                ForEach(values[0..<level], id: \.self){ values in
                    PlayerCard(content: values)
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
struct PlayerCard: View {
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
        ContentView()
    }
}
