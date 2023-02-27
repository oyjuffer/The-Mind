//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model<cardContent>{
    let nCards: Int = 100   // number of cards in deck
    var level: Int = 1  // would update +1 on win
    var botStop: Bool = false
    
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
    
    // This loop checks if the bots play their card.
    // Alternatively it can track time until a play is made
    // Eitherway dump the AI model in this function.
    func botLoop(){
        print("BOTS DO SOMETHING")
        print("BOTS DO SOMETHING")
        print("BOTS DO SOMETHING")
        print()
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
        botStop = true
    }
    
    
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
}
