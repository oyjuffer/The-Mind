//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model<cardContent>{
    var level: Int = 1  // would update +1 on win
    var life: Int = 30
    var joker: Int = 1
    
    var deck: Array<Card>
    var playerHand: Array<Card>
    
    var bots: [Array<Card>]
    
    var bot1Hand: Array<Card>
    var boardCard: Card = Card(id: 0, value: 0)
    
    var botStop: Bool = false
    
    init(){
        deck = Array<Card>()
        playerHand = Array<Card>()
        bot1Hand = Array<Card>()
        bots = [Array<Card>]()
        
        deck = generateDeck()
        playerHand = generateHand()
        bot1Hand = generateHand()
        
        bots = [generateHand(), generateHand(), generateHand()]
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
        
        var win = 1
        
        if (playerHand.count != 0){
            win *= 0
            return (win != 0)
        }
        
        for i in 0..<bots.count where bots[i].count != 0{
            win *= 0
            return (win != 0)
        }
        
        
        level += 1
        deck = generateDeck()
        playerHand = generateHand()
        bots = [generateHand(), generateHand(), generateHand()]
        bot1Hand = generateHand()
        boardCard = Card(id: 0, value: 0)
        
        print("GAME WON")
        return (win != 0)
        
    }
    
    // checks if the game has been lost
    mutating func looseCondition(){
        
        var loss = false
        
        if (playerHand.count != 0 && playerHand[0].value < boardCard.value){
            loss = true
        }
        else{
            for i in 0..<bots.count where bots[i].count != 0 && bots[i][0].value < boardCard.value{
                loss = true
            }
        }
        
        if loss == true && life > 1{
            life -= 1
            while playerHand.count != 0 && playerHand[0].value < boardCard.value {playerHand.removeFirst()}
            
            for i in 0..<bots.count where bots[i].count != 0 && bots[i][0].value < boardCard.value{
                while bots[i].count != 0 && bots[i][0].value < boardCard.value{bots[i].removeFirst()}
            }
            print("LIFE LOST, \(life) left.")
            
        } else if loss == true && life <= 1{
            botStop = true
            print("GAME LOST")
        }
    }
    
    // restarts the game at level 1.
    mutating func playReset(){
        self = TM_Model()
    }
    
    // MARK: - USER CONTROL
    // plays a card
    mutating func playCard (){
        if (playerHand.count != 0){
            boardCard = playerHand[0]
            playerHand.removeFirst()
        }
        if !winCondition(){
            looseCondition()
        }
    }
    
    // signals that a joker wants to be played
    mutating func playJoker(){
    }
    
    // MARK: - BOT CONTROL
    // This loop checks whether the bots play their card each second.
    mutating func botLoop(){
        
        print("\nBOTS EVALUATING:")
        
        for i in 0..<bots.count where bots[i].count != 0{
            
            let random = Float.random(in: 1..<100)
            let difference = (Float(100) - Float(bots[i][0].value - boardCard.value)) / 1.8
            
            print("BOT\(i) Roll: \(difference) > \(random)")
            
            if difference > random{
                bots[i] = botPlayCard(hand: bots[i])
            }
        }
        
        if !winCondition(){
            looseCondition()
        }
    }
    
    // plays the bots card
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
