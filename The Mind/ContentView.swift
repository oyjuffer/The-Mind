//
//  ContentView.swift
//  The Mind
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .stroke(lineWidth: 3)
                .foregroundColor(/*@START_MENU_TOKEN@*/.red/*@END_MENU_TOKEN@*/)
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("The Mind")
        }
        .padding(/*@START_MENU_TOKEN@*/.all/*@END_MENU_TOKEN@*/)
        
        
    }
}















// This generates the preview in Xcode. Don't tinker with this.
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
