//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model<cardContent>{
    var level: Int = 1  // would update +1 on win
    var botStop: Bool = false
    
    var deck: Array<Card>
    var playerHand: Array<Card>
    var bot1Hand: Array<Card>
    
    var boardCard: Card = Card(id: 0, value: 0)
    var running: Bool = false
    init(){
        deck = Array<Card>()
        playerHand = Array<Card>()
        bot1Hand = Array<Card>()
        
        deck = generateDeck()
        playerHand = generateHand()
        bot1Hand = generateHand()
    }
    
    // MARK: - GAME CONTROL
    // generates a deck of 100 cards.
    mutating func generateDeck() -> Array<Card>{
        var deck = Array<Card>()
        for i in 1..<(101){
            deck.append(Card(id: i, value: i))
        }
        return deck
    }
    
    // generates a hand of cards based on level, sorted lowest value first.
    mutating func generateHand() -> Array<Card>{
        var hand = Array<Card>()
        for _ in 0..<level{
            if let index = deck.indices.randomElement(){
                let card = deck.remove(at: index)
                hand.append(card)
                hand.sort{$0.value < $1.value}
            }
        }
        return hand
    }
    
    // checks if the game has been won and generates the next level
    mutating func winCondition() -> Bool{

        if playerHand.count == 0 && bot1Hand.count == 0{
            level += 1
            deck = generateDeck()
            playerHand = generateHand()
            bot1Hand = generateHand()
            boardCard = Card(id: 0, value: 0)
            
            print("WIN")
            return true
        }
        return false
    }
    
    // checks if the game has been lost
    mutating func looseCondition(){
        
        if playerHand.count != 0 && playerHand[0].value < boardCard.value{
            botStop = true
            print("USER LOST")
        }
        
        if bot1Hand.count != 0 && bot1Hand[0].value < boardCard.value{
            botStop = true
            print("BOT LOST")
        }

    }
    // restarts the game at level 1.
    mutating func playReset(){
        self = TM_Model()
    }
    
    // MARK: - USER CONTROL
    mutating func playCard (){
        
        if (playerHand.count != 0){
            boardCard = playerHand[0]
            playerHand.removeFirst()
            
            if !winCondition(){
                looseCondition()
            }
        }
    }
    
    mutating func playJoker(){
    }
    
    // MARK: - BOT CONTROL
    // This loop checks whether the bots play their card each second.
    mutating func botLoop(){
        
        if bot1Hand.count != 0 {
            
            let random = Float.random(in: 1..<100)
            let difference = (Float(100) - Float(bot1Hand[0].value - boardCard.value)) / 1.5
            
            print("\nBOTS EVALUATING:")
            print("BOT1 Roll: \(difference) > \(random)")
            
            if difference > random{
                bot1Hand = botPlayCard(hand: bot1Hand)
            }
            
            if !winCondition(){
                looseCondition()
            }
            
            
        }
    }
    
    mutating func botPlayCard(hand: Array<Card>) -> Array<Card>{
        var hand = hand
        if (hand.count != 0){
            boardCard = hand[0]
            hand.removeFirst()
        }
        return hand
    }
    

    // MARK: - Card
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
}
