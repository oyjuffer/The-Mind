//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class TM_ViewModel: ObservableObject{
    @Published private var model: TM_Model<String> = TM_Model<String>()
        
    // This checks the status of the bots each 5 seconds.
    func looper(){
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.model.botsActive == false{
                print("BOTS STOPPED")
                timer.invalidate()
            }else{
                self.model.gameLoop()
            }
        }
    }
    
    // Returns the state of the game, f.ex: main menu, game, lose screen, splash screen.
    var gameState: Int{
        return model.gameState
    }
    
    var playerHand: Array<Card> {
        return model.playerHand
    }
    
    var boardCard: Card{
        return model.boardCard
    }
    
    var level: Int{
        return model.level
    }
    
    var life: Int{
        return model.life
    }
    
    var popupWin: Bool{
        return model.showPopupWin
    }
    
    var popupLost: Bool{
        return model.showPopupLost
    }
    
    var popupMenu: Bool{
        return model.showPopupMenu
    }
    
    var activateView: Bool{
        return model.activateView
    }
    
    var bots: Array<Bot>{
        return model.bots
    }
    
    var activeBots: Bool{
        return model.botsActive
    }
    
    var shuriken: Int{
        return model.shurikens
    }
    
    
    // MARK: - MENU CONTROLS
    func play(){
        model.play()
        looper()
    }
    
    func instructions(){
        model.instructions()
    }
    
    func menu(){
        model.mainMenu()
    }
    
    func pause(){
        model.botsActive = false
        model.activateView.toggle()
    }
    
    func toggleWarning(){
        model.showPopupMenu.toggle()
    }
    
    func reset(){
        model.reset()
    }
    
    // MARK: - GAME CONTROLS
    func playCard(){
        model.playerHand = model.playCard(hand: model.playerHand)
    }
        
    func playJoker(){
        model.playerShuriken = true
    }
    
    func resume(){
        looper()
        model.gameState = 2
        model.botsActive = true
        model.activateView.toggle()
    }
    
    func closePopup(){
        if model.showPopupWin{
            model.showPopupWin.toggle()
        } else if model.showPopupLost{
            model.showPopupLost.toggle()
        } else {
            model.showPopupMenu.toggle()
        }
    }
}
