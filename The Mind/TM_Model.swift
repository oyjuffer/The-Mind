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
    // 5 = winScreen
    // 6 = loseScreen
    
    // Variables relating the game setup.
    var level: Int = 1  // would update +1 on win
    var life: Int = 3
    var previousLife: Int = 3
    var joker: Int = 1
    var botsActive: Bool = false
    
    var deck: Array<Card>
    var playerHand: Array<Card>
    var bots: Array<Bot>
    
    var boardCard: Card = Card(id: 0, value: 0)
    
    var gameChange: Bool = true
    var gameTime: Float = 0.0
//    var gameBuffer: Card
    
    
    // bot AI variables
    var trialNr: Int = 0
    var lowestRT: Double = 0
    
    init(){
        deck = Array<Card>()
        playerHand = Array<Card>()
        bots = Array<Bot>()
        
        deck = generateDeck()
        playerHand = generateHand()
        
        for i in 0...2{
            let bot = Bot(id: i, hand: generateHand())
            bots.append(bot)
        }
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
    
    // generates a hand of cards based on level, stacked with lowest first.
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
        
        for i in 0..<bots.count where bots[i].hand.count != 0{
            win *= 0
            return (win != 0)
        }
        
        // Generate the next level
        level += 1
        deck = generateDeck()
        playerHand = generateHand()
        
        for i in 0...2{
            bots[i].hand = generateHand()
        }
        
        boardCard = Card(id: 0, value: 0)
        gameChange = true
        
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
                
        for i in 0..<bots.count where bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
            while bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
                
//                let lastCard = bots[i].hand.last!.value
                
                bots[i].hand.removeLast()
                loss = true
            }
        }
        
        // if a loss was detected, they remove a life and check if the game is over.
        if loss == true{
            previousLife = life
            life -= 1
            print("LIFE LOST, \(life) left.")
            if life <= 0 {botsActive = false; print("GAME LOST")}
            gameChange = true
            
            // for each bot we make a new chunk on fail
            
        } else {
            previousLife = life
            
//            for i in 0..<bots.count where bots[i].hand.count != 0{
//
//                // For each bot we make a new chunk on successful play.
////                let chunk = Chunk(s: "success\(trialNr) card \(boardCard.value)", m: bots[i].model)
////                chunk.setSlot(slot: "currentDifference", value: Double(abs(boardCard.value - bots[i].hand.last!.value)))
////                chunk.setSlot(slot: "temporalProfile", value: Double(time_to_pulses(lowestRT) - 1))
////
////                bots[i].model.dm.addToDM(chunk)
//            }
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
    
    // MARK: - USER CONTROL
    
    // user plays a card
    mutating func playCard (){
        if (playerHand.count != 0){
            boardCard = playerHand[playerHand.count - 1]
            playerHand.removeLast()
        }
        
        gameChange = true
        trialNr += 1
        
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
        
        gameTime += 1
        
        
        // if a change on the board was made, the bot prediction will be recalculated.
        // if not, the game waits till the timer ticks over the prediction to play the card
        if gameChange == true{
            
            print("\nBOTS UPDATING MODEL")
            
            for i in 0..<bots.count{
                
                // stupid bot
                // this estimate needs to be replaced by the act-r estimate for when to play
                if bots[i].hand.count != 0 {
                    bots[i].estimate = Float(bots[i].hand.last!.value - boardCard.value) + gameTime
                }
                else{
                    // no cards in hand anymore
                    bots[i].estimate = -1
                }
            }
            
            // sort according to lowest estimate first, meaning the bot[0] plays first
            bots = bots.sorted{$0.estimate < $1.estimate}
            lowestRT = Double(bots[0].estimate)
            
            gameChange = false
        }
        else{
            
            print("\nBOTS:")
            print("gameTime: \(gameTime)")
            
            for i in 0..<bots.count{
                
                if bots[i].estimate != -1 && (bots[i].estimate <= gameTime || emptyHand(id: bots[i].id) == true){
                    print("BOT \(bots[i].id) PLAYING CARD: \(bots[i].hand.last!.value)")
                    bots[i].hand = botPlayCard(hand: bots[i].hand)
                    
                    gameChange = true
                    break
                }
                print("\(bots[i].id): \(bots[i].estimate)s")
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
        
        trialNr += 1
        return hand
    }
    
    // checks if a bot should empty their hand because they are the last left with cards
    mutating func emptyHand(id: Int) -> Bool{
        let id = id
        
        if playerHand.count != 0{
            return false
        }
        
        for i in 0..<bots.count where id != bots[i].id{
            
            if bots[i].hand.count != 0{
                return false
            }
        }
        
        print("emptying hand -->")
        return true
    }
    
    // MARK: - ACT-R Functions
    
    mutating func noise(_ s: Double) -> Double{
        let rand = Double.random(in: 0.001...0.999)
        return s * log((1 - rand) / rand)
    }
    
    mutating func time_to_pulses(_ time: Double, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true ) -> Int{
        var pulses = 0
        var pulseDuration = t_0
        var t = time
        
        while t >= pulseDuration{
            t -= pulseDuration
            pulses += 1
            pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration): 0.0)
        }
        
        return pulses
    }
    
    mutating func pulses_to_time(_ pulses: Int, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true ) -> Double{
        var time = 0.0
        var pulseDuration = t_0
        var remainingPulses = pulses
        
        while remainingPulses > 0{
            time += pulseDuration
            remainingPulses -= 1
            pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration): 0.0)
        }
        
        return time
    }
    
    // MARK: - Card
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
        var filename: String {return "\(value)"}
    }
    
    // MARK: - Bot
    struct Bot {
        var id: Int
        var model = Model()
        var hand: Array<Card>
        var estimate: Float = 100.0
        var joker: Bool = false
        var emotion = 0
    }
}
