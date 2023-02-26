//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model<cardContent>{
    let nCards: Int = 100   // number of cards in deck
    var level: Int = 1  // would update +1 on win
    
    var deck: Array<Card>
    var playerHand: Array<Card>
    var boardCard: Card = Card(id: 0, value: 0)
    var running: Bool = false
    init(level: Int){
        
        // generates a deck from 1 tp 100
        deck = Array<Card>()
        for i in 1..<(nCards+1){
            deck.append(Card(id: i, value: i))
        }
        
        // selects the player cards
        playerHand = Array<Card>()
        for _ in 0..<level{
            if let index = deck.indices.randomElement(){
                let card = deck.remove(at: index)
                playerHand.append(card)
                playerHand.sort{$0.value < $1.value}
            }
        }
    }
    
    // This loop should check the status of the three bots.
    // Some sort of action queue where the player and the AI can place their actions.
    // The loop would check whats in the queue and make changes so TM_View can update.
    // The problem is that nothing else can happen while this loop is running, so the user input is ignored.
    func gameLoop(){
//        while(true){
//            print("running")
//        }
    }
    
    // checks if the game has been won and either ends it or goes to next level
    func winCondition(){

    }
    
    func looseCondition(){
        
    }
    
    // allows the player to play their cards.
    mutating func playCard (){
        
        if (playerHand.count != 0){
            boardCard = playerHand[0]
            playerHand.removeFirst()
        }
    }
    
    // restarts the game at level 1.
    mutating func playReset(){
        self = TM_Model(level: 1)
    }
    
    
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
}
