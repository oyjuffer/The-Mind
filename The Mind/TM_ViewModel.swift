//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class TM_ViewModel: ObservableObject{
    @Published private var model: TM_Model<String> = TM_Model<String>(level: 10)
    
    var botStop: Bool = false
    
    init() {
        
        // This checks the status of the bots each second. 
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.botStop == true{
                print("BOTS STOPPED")
                timer.invalidate()
            }else{
                print("BOT ACTION:")
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
        botStop = true
        model.playReset()
    }
}
