//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class TM_ViewModel: ObservableObject{
    @Published private var model: TM_Model = TM_Model()
        
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
    
    var gameTime: Double{
        return model.gameTime
    }
    
    var playerHand: Array<Card> {
        return model.player.hand
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
    
    var popupWon: Bool{
        return model.showPopupWon
    }
    
    var popupOver: Bool{
        return model.showPopupOver
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
    
    var nBots: Int{
        return model.nBots
    }
    
    var difficultyLevel: Double {
        return model.player.gameDifficuly
    }
    
    // MARK: - MENU CONTROLS
    func play(){
        model.play()
        model.generateBotArray()
        looper()
    }
    
    func instructions(){
        model.instructions()
    }
    
    func AI(){
        model.AI()
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
    
    func setBoardCard(card: Card){
        model.boardCard = card
    }
    
    func reset(){
        model.reset()
    }
    
    func setBots(bots: Int){
        model.nBots = bots
    }
    
    func setDifficulty(difficulty: Double){
        model.player.gameDifficuly = difficulty
    }
    
    var playerShuriken: Bool{
        return model.player.shuriken
    }
    
    // MARK: - ANIMATIONS
    func botAnimation(){
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            for i in 0..<self.model.nBots{self.model.bots[i].playingCard = false}
        }
    }
    
    // MARK: - GAME CONTROLS
    
    // Player wishs to play a card.
    func playCard(){
        model.player.hand = model.playCard(hand: model.player.hand)
    }
    
    // Player wishs to play a shuriken.
    func toggleShuriken(){
        model.toggleShuriken()
    }
    
    func resume(){
        looper()
        model.botsActive = true
        model.activateView.toggle()
    }
    
    func closePopup(){
        if model.showPopupWin{
            model.showPopupWin.toggle()
        } else if model.showPopupLost{
            model.showPopupLost.toggle()
        } else if model.showPopupMenu{
            model.showPopupMenu.toggle()
        } else {
            model.showPopupOver.toggle()
        }
    }
    
}
