//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class TM_ViewModel: ObservableObject{
    @Published private var model: TM_Model<String> = TM_Model<String>(n: 100, level: 10)
    
    var playerHand: Array<TM_Model<String>.Card> {
        return model.playerHand
    }
    
    var boardCard: TM_Model<String>.Card{
        print(model.boardCard.value)
        return model.boardCard
    }
    
    // MARK: - USER INTENT
    
    func playCard(){
        model.playCard()
    }
    
    func playJoker(){
        
    }
    
    func playExit(){
        
    }
}
