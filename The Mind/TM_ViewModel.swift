//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class TM_ViewModel: ObservableObject{
    @Published private var model: TM_Model<String> = TM_Model<String>()
    
    init() {
        looper()
    }
    
    // This checks the status of the bots each second.
    func looper(){
        Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { timer in
            if self.model.botStop == true{
                print("BOTS STOPPED")
                timer.invalidate()
            }else{
                self.model.botLoop()
            }
        }
    }
    
    var playerHand: Array<TM_Model<String>.Card> {
        return model.playerHand
    }
    
    var boardCard: TM_Model<String>.Card{
        return model.boardCard
    }
    
    // MARK: - USER INTENT
    
    func playCard(){
        model.playCard()
    }
        
    func playJoker(){
            
    }
        
    func playReset(){
        model.playReset()
        looper()
    }
}
