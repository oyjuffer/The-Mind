//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model<cardContent>{
    var gameState: Int = 1
    // 1 = Main Menu
    // 2 = Game
    // 3 = Instructions
    // 4 = Button 3
    
    // Variables relating the game setup.
    var level: Int = 1  // would update +1 on win
    var life: Int = 3
    var joker: Int = 1
    var botsActive: Bool = false
    
    var deck: Array<Card>
    var playerHand: Array<Card>
    var bots: [Array<Card>]
    var boardCard: Card = Card(id: 0, value: 0)
    
    
    // This would be the AI model.
    var model = Model()
    
    init(){
        deck = Array<Card>()
        playerHand = Array<Card>()
        bots = [Array<Card>]()
        
        deck = generateDeck()
        playerHand = generateHand()
        bots = [generateHand(), generateHand(), generateHand()]
    }
    
    // MARK: - GAME LOGIC
    // generates a deck of 100 cards.
    mutating func generateDeck() -> Array<Card>{
        var deck = Array<Card>()
        for i in 1..<(101){
            deck.append(Card(id: i, value: i))
        }
        return deck
    }
    
    // generates a hand of cards based on level, sorted highest value first.
    mutating func generateHand() -> Array<Card>{
        var hand = Array<Card>()
        for _ in 0..<level{
            if let index = deck.indices.randomElement(){
                let card = deck.remove(at: index)
                hand.append(card)
                hand.sort{$0.value > $1.value}
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
        boardCard = Card(id: 0, value: 0)
        
        print("GAME WON")
        return (win != 0)
        
    }
    
    // checks if the game has been lost
    mutating func looseCondition(){
        
        // tracks if a loss was detected.
        var loss = false
        
        // check if player card is lower then on board.
        while playerHand.count != 0 && playerHand[playerHand.count - 1].value < boardCard.value {
            playerHand.removeLast()
            loss = true
        }
        
        // check if any bots have a card lower then on the board.
        for i in 0..<bots.count where bots[i].count != 0 && bots[i][bots[i].count - 1].value < boardCard.value{
            while bots[i].count != 0 && bots[i][bots[i].count - 1].value < boardCard.value{
                bots[i].removeLast()
                loss = true
            }
        }
        
        // if a loss was detected, they remove a life and check if the game is over.
        if loss == true{
            life -= 1
            print("LIFE LOST, \(life) left.")
            if life <= 0 {botsActive = false; print("GAME LOST")}
        }
    }
    
    // MARK: - MENU CONTROL
    
    // starts the game
    mutating func play(){
        gameState = 2
        botsActive = true
    }
    
    // restarts the game at level 1.
    mutating func reset(){
        self = TM_Model()
    }
    
    // MARK: - GAME CONTROLS
    
    // plays a card
    mutating func playCard (){
        if (playerHand.count != 0){
            boardCard = playerHand[playerHand.count - 1]
            playerHand.removeLast()
        }
        if !winCondition(){
            looseCondition()
        }
    }
    
    // signals that a joker wants to be played
    mutating func playJoker(){
    }
    
    // MARK: - BOT CONTROL
    // This loop checks whether the stupid bots play their card each 5 seconds.
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
            boardCard = hand[hand.count - 1]
            hand.removeLast()
        }
        return hand
    }
    
    
    // MARK: - Card
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
        var filename: String {return "\(value)"}
    }
}
