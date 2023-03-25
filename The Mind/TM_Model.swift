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
    // 4 = Level Up
    // 5 = Life Lost
    // 6 = Game Won
    // 7 = Game Over
    // 8 = Play Shuriken
    
    var resumeGame: Bool = true
    var showPopupWin: Bool = false
    var showPopupLost: Bool = false
    var showPopupMenu: Bool = false
    var activateView: Bool = true
    
    // game
    var level: Int = 1  // would update +1 on win
    var life: Int = 3
    var lifeLost = false
    var shurikens = 1
    
    var deck: Array<Card>
    var boardCard: Card = Card(id: 0, value: 0)
    var boardCardPrevious: Card = Card(id: 0, value: 0)
    
    var gameChange: Bool = true
    var gameTime: Double = 0.0
    var gameTimePrevious: Double = 0.0
    
    // user
    var playerHand: Array<Card>
    var playerShuriken = false
    
    // bots
    var bots: Array<Bot>
    var botsActive = false
    var nBots = 3
    
    // bot model
    var trial: Int = 0
    var shortestEstimate: Double = 0
    var shortestEstimatePrevious: Double = 0
    
    init(){
        deck = Array<Card>()
        playerHand = Array<Card>()
        bots = Array<Bot>()
        
        deck = generateDeck()
        playerHand = generateHand()
        
        for i in 0..<nBots{
            let bot = Bot(id: i, hand: generateHand())
            bots.append(bot)
        }
    }
    
    // MARK: - GAME LOOP
    // This is the gameLoop which runs each second and check various states of the game.
    mutating func gameLoop(){
        gameTime += 1
        
        // if a change on the board was made, the bot prediction will be recalculated.
        // if not, the game waits till the timer ticks over the prediction to play the card
        if gameChange == true{
            
            generateChunks(bias: false)
            
            print("\nBOTS UPDATING MODEL")
            
            var totalHands = playerHand.count
            for i in 0..<bots.count{totalHands += bots[i].hand.count}
            
            for i in 0..<bots.count{
                
                // estimates when the bot will play their card, if they want to play a shuriken, what their emotion is and their difficulty scaling
                if !bots[i].hand.isEmpty {
                    (bots[i].estimate, bots[i].shuriken, bots[i].emotion, bots[i].scalar) = prediction(bot: bots[i],
                                                                                                       nBots: nBots,
                                                                                                       boardCard: boardCard,
                                                                                                       life: life,
                                                                                                       lifeLost: lifeLost,
                                                                                                       level: level,
                                                                                                       trial: trial,
                                                                                                       previousDeckCard: boardCardPrevious.value,
                                                                                                       RTpreviousRound: shortestEstimate,
                                                                                                       totalHands: totalHands)
                    bots[i].estimate += gameTime
                }
                else{
                    // no cards in hand anymore
                    bots[i].estimate = 100000000
                }
            }
            
            // sort according to lowest estimate first, meaning the bot[0] plays first
            bots = bots.sorted{$0.estimate < $1.estimate}
            shortestEstimatePrevious = shortestEstimate
            shortestEstimate = bots.min{$0.estimate < $1.estimate}!.estimate
            
            gameChange = false
        }
        else{
            
            print("\ngameTime: \(gameTime)s")
            
            for i in 0..<bots.count{
                
                if !bots[i].hand.isEmpty && (bots[i].estimate <= gameTime || emptyHand(id: bots[i].id) == true){
                    print("BOT \(bots[i].id) PLAYING CARD: \(bots[i].hand.last!.value)")
                    bots[i].hand = playCard(hand: bots[i].hand)
                    break
                }
                
                if !bots[i].hand.isEmpty{
                    let x = Double(round(100 * bots[i].estimate) / 100)
                    let y = Double(round(100 * bots[i].emotion) / 100)
                    print("BOT \(bots[i].id) - ESTIMATE: \(x)s - CARD: \(bots[i].hand[bots[i].hand.count - 1].value) - JOKER: \(bots[i].shuriken) - EMOTION: \(y)")
                }
            }
        }
        
        // checks if the level has been won
        if winCondition(){
            
            // if level 10 has been reached, the game was won, otherwise level up
            if level >= 10{
                gameState = 6
                botsActive = false
            }else{
                levelUp()
                activateView = false
                showPopupWin = true
                botsActive = false
            }
        }
        
        // check if a mistake was made, if true reduce a life and remove lower cards.
        // still needs a life lost screen and card burn feedback
        else if looseCondition(){
            
            // game over
            if life <= 1{
                gameState = 7
                botsActive = false
            }else{
                removeCards()
                life -= 1
                lifeLost = true
                generateChunks(bias: true)
                gameChange = true
                //popup
                activateView = false
                showPopupLost = true
                botsActive = false
            }
        } else if(shurikens > 0 && bots.allSatisfy{$0.shuriken} && playerShuriken){
            shurikens -= 1
            print("SHOW CARDS")
            // set the first card in the hands to reveal.
            if !playerHand.isEmpty{playerHand[playerHand.count - 1].reveal = true}
            for i in 0..<bots.count where !bots[i].hand.isEmpty{bots[i].hand[bots[i].hand.count - 1].reveal = true}
        }
        
        lifeLost = false
    }
    
    // ==================================== AUXILIARY FUNCTIONS ==================================== //
    
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
    
    // upgrade the level and generates a new hand
    mutating func levelUp(){
        
        if level == 3 || level == 6 || level == 9{
            life += 1
            print("EXTRA LIFE")
        }
        
        if level == 2 || level == 5 || level == 8 {
            shurikens += 1
            print("EXTRA SHURIKEN")
        }
        
        level += 1
        
        deck = generateDeck()
        playerHand = generateHand()
        
        for i in 0..<bots.count{
            bots[i].hand = generateHand()
        }
        
        boardCard = Card(id: 0, value: 0)
        gameChange = true
    }
    
    mutating func removeCards(){
        
        while playerHand.count != 0 && playerHand[playerHand.count - 1].value < boardCard.value {
            playerHand.removeLast()
        }
        
        for i in 0..<bots.count where bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
            while bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
                bots[i].hand.removeLast()
            }
        }
    }
    
    // checks if the game has been won
    mutating func winCondition() -> Bool{
        
        if (!playerHand.isEmpty){
            return false
        }
        
        for i in 0..<bots.count where !bots[i].hand.isEmpty{
            return false
        }
        return true
    }
    
    // checks if the game has been lost
    mutating func looseCondition() -> Bool{
        
        if playerHand.count != 0 && playerHand[playerHand.count - 1].value < boardCard.value{
            return true
        }
        
        for i in 0..<bots.count where bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
            if bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
                return true
            }
        }
        return false
    }
    
    // generate a chunk for when correct and incorrect plays are made
    mutating func generateChunks(bias: Bool){
        trial += 1
        for i in 0..<bots.count{
            let chunk = Chunk(s: "bias\(bias) trial\(trial) card\(boardCard.value)", m: bots[i].model)
            chunk.setSlot(slot: "currentDifference", value: Double(abs(boardCard.value - boardCardPrevious.value)))
            chunk.setSlot(slot: "temporalProfile", value: Double(time_to_pulses(shortestEstimate) + (bias ? 1 : 0)))
            bots[i].model.dm.addToDM(chunk)
            bots[i].model.time += gameTime - gameTimePrevious
        }
        gameTimePrevious = gameTime
    }
    
    
    // MARK: - GAME CONTROL
    
    // starts the game on the main menu.
    mutating func play(){
        gameState = 2
        botsActive = true
    }
    
    mutating func instructions(){
        gameState = 3
    }
    
    mutating func mainMenu(){
        gameState = 1
        botsActive = false
    }
    
    // restarts the game at level 1 when the cross is clicked.
    mutating func reset(){
        self = TM_Model()
    }
    
    
    // plays the lowest card from the array, and returns the updated hand.
    mutating func playCard(hand: Array<Card>) -> Array<Card>{
        var hand = hand
        
        if (hand.count != 0){
            boardCardPrevious = boardCard
            boardCard = hand.removeLast()
        }
        
        gameChange = true
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
}

//     MARK: - Card
struct Card: Identifiable {
    var id: Int
    var value: Int
    var reveal = false
    var filename: String {return "\(value)"}
}

// MARK: - Bot
struct Bot {
    var id: Int
    var model = Model()
    var hand: Array<Card>
    var estimate = 100.0
    var shuriken = false
    var emotion = 0.0
    var scalar = 1.0
}
