//
//  ViewModel.swift
//  The Mind
//

import Foundation

struct TM_Model{
    var gameState: Int = 1
    // 1 = Main Menu
    // 2 = Game
    // 3 = Instructions
    /// 4 = Ai View
    
    // UI popups
    var showPopupWin: Bool = false
    var showPopupLost: Bool = false
    var showPopupMenu: Bool = false
    var showPopupOver: Bool = false
    var showPopupWon: Bool = false
    var activateView: Bool = true
    
    // game
    var level: Int = 1  // would update +1 on win
    var lives: Int = 4
    var shurikens: Int = 1
    var lastLevel: Int = 8
    var lifeLost = false
    var deck: Array<Card> = Array<Card>()
    var boardCard: Card = Card(id: 0, value: 0)
    var boardCardPrevious: Card = Card(id: 0, value: 0)
    var gameChange: Bool = true
    var gameTime: Double = 0.0
    var gameTimePrevious: Double = 0.0
    var revealedCards: Array<Card> = Array<Card>()
    
    // player
    var player: Player = Player()
    
    // bots
    var bots: Array<Bot> = Array<Bot>()
    var botsActive = false
    var nBots: Int = 3
    
    // bot model
    var trial: Int = 0
    var shortestEstimate: Double = 0
    var shortestEstimatePrevious: Double = 0
    
    // MARK: - GAME LOOP
    // This is the gameLoop which runs each second and check various states of the game.
    mutating func gameLoop(){
        gameTime += 1
        
        // PRINTOUTS
        print("\ngameTime: \(gameTime)s")
        for i in 0..<bots.count{
            if !bots[i].hand.isEmpty{
                let x = Double(round(100 * bots[i].estimate) / 100)
                print("BOT \(bots[i].id) - ESTIMATE: \(x)s - CARD: \(bots[i].hand[bots[i].hand.count - 1].value) - JOKER: \(bots[i].shuriken) - EMOTION: \(bots[i].emotion)")
            }
        }
        
        // if a change on the board was made, the bot estimate will be recalculated.
        if gameChange == true{
            
            print("BOTS UPDATING MODEL")
            generateChunks(bias: false)
            
            for i in 0..<bots.count{
                
                // estimates when the bot will play their card, if they want to play a shuriken, what their emotion is and their difficulty scaling
                if !bots[i].hand.isEmpty {
                    (bots[i].estimate, bots[i].shuriken, bots[i].emotion, bots[i].scalar) = prediction(bot: bots[i],
                                                                                                       nBots: nBots,
                                                                                                       playerShuriken: player.shuriken,
                                                                                                       boardCard: boardCard,
                                                                                                       revealedCards: revealedCards,
                                                                                                       life: lives,
                                                                                                       lifeLost: lifeLost,
                                                                                                       level: level,
                                                                                                       trial: trial,
                                                                                                       previousDeckCard: boardCardPrevious.value,
                                                                                                       RTpreviousRound: shortestEstimate,
                                                                                                       totalHands: activeCards(),
                                                                                                       difficultyLevel: player.gameDifficuly)
                    bots[i].estimate += gameTime
                }
                else{
                    // no cards in hand anymore
                    bots[i].estimate = 100000000
                    bots[i].shuriken = true
                }
            }
            
            // tracks of the previous state
            shortestEstimatePrevious = shortestEstimate
            shortestEstimate = bots.min{$0.estimate < $1.estimate}!.estimate
            
            
            gameChange = false
        }else{
            
            for i in 0..<bots.count{
                
                // bot plays a card
                if !bots[i].hand.isEmpty && (bots[i].estimate <= gameTime || emptyHand(id: bots[i].id) == true){
                    print("BOT \(bots[i].id) PLAYING CARD: \(bots[i].hand.last!.value)")
                    bots[i].playingCard = true
                    bots[i].hand = playCard(hand: bots[i].hand)
                    break
                }
            }
        }
        
        // checks if the level has been won
        if winCondition(){
            
            // if level 10 has been reached, the game was won, otherwise level up
            if level >= lastLevel{
                showPopupWon = true
                botsActive = false
            }else{
                levelUp()
                // variables for UI popup
                activateView = false
                showPopupWin = true
                botsActive = false
            }
        }
        
        // check if a mistake was made, if true reduce a life and remove lower cards.
        else if looseCondition(){
            
            // game over
            if lives <= 1{
                showPopupOver = true
                botsActive = false
            }else{
                looseLife()
                // variables for UI popup
                activateView = false
                showPopupLost = true
                botsActive = false
                player.shuriken = false
            }
        }
        
        // play a shuriken if all agree
        else if(shurikens > 0 && bots.allSatisfy{$0.shuriken} && player.shuriken){
            print("PLAY JOKER")
            playShuriken()
        }
        
        lifeLost = false
    }
    
    // MARK: - GAME LOGIC
    // starts the game with selected variables
    mutating func startGame(){
        
        if nBots == 1{
            lives = 2
            shurikens = 1
            lastLevel = 12
        } else if nBots == 2{
            lives = 3
            shurikens = 1
            lastLevel = 10
        } else{
            lives = 4
            shurikens = 1
            lastLevel = 8
        }
        
        deck = generateDeck()
        
        player.hand = generateHand()
        for i in 0..<nBots{
            let bot = Bot(id: i, hand: generateHand())
            bots.append(bot)
        }
    }
    
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
            lives += 1
            print("EXTRA LIFE")
        }
        
        if level == 2 || level == 5 || level == 8 {
            shurikens += 1
            print("EXTRA SHURIKEN")
        }
        
        level += 1
        
        deck = generateDeck()
        
        player.hand = generateHand()
        player.shuriken = false
        
        for i in 0..<bots.count{
            bots[i].hand = generateHand()
            bots[i].shuriken = false
        }
        
        boardCard = Card(id: 0, value: 0)
        gameChange = true
    }
    
    // removes all cards lower then the current board card
    mutating func looseLife(){
        
        lives -= 1
        lifeLost = true
        generateChunks(bias: true)
        
        while player.hand.count != 0 && player.hand[player.hand.count - 1].value < boardCard.value {
            player.hand.removeLast()
        }
        
        for i in 0..<bots.count where bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
            while bots[i].hand.count != 0 && bots[i].hand.last!.value < boardCard.value{
                bots[i].hand.removeLast()
            }
        }
        
        for i in 0..<bots.count{
            bots[i].shuriken = false
        }
        
        gameChange = true
    }
    
    // checks if the game has been won
    mutating func winCondition() -> Bool{
        
        if (!player.hand.isEmpty){
            return false
        }
        
        for i in 0..<bots.count where !bots[i].hand.isEmpty{
            return false
        }
        return true
    }
    
    // checks if the game has been lost
    mutating func looseCondition() -> Bool{
        
        if player.hand.count != 0 && player.hand[player.hand.count - 1].value < boardCard.value{
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
    
    // calculate the total amount of cards in play
    mutating func activeCards() -> Int{
        
        var active = player.hand.count
        for i in 0..<bots.count{active += bots[i].hand.count}
        
        return active
    }
    
    // plays the joker and sets respective cards to reveal. Also saves these cards for the prediction function.
    mutating func playShuriken(){
        shurikens -= 1
        // set the first card in the hands to reveal.
        if !player.hand.isEmpty{player.hand[player.hand.count - 1].reveal = true}
        for i in 0..<bots.count where !bots[i].hand.isEmpty{bots[i].hand[bots[i].hand.count - 1].reveal = true}
        
        revealedCards = Array<Card>()
        
        if player.hand.count != 0 {
            revealedCards.append(player.hand.last!)
        }
        
        for i in 0..<bots.count where bots[i].hand.count != 0 {
            revealedCards.append(bots[i].hand.last!)
        }
        
        revealedCards.sort{$0.value < $1.value}
        player.shuriken = false
        
        for i in 0..<bots.count{
            bots[i].shuriken = false
        }
        
        gameChange = true
    }
    
    // checks if a bot should empty their hand because they are the last left with cards
    mutating func emptyHand(id: Int) -> Bool{
        let id = id
        
        if player.hand.count != 0{
            return false
        }
        
        for i in 0..<bots.count where id != bots[i].id{
            
            if bots[i].hand.count != 0{
                return false
            }
        }
        return true
    }
    
    // MARK: - GAME CONTROL
    // sets the state to main menu
    mutating func mainMenu(){
        gameState = 1
        botsActive = false
    }
    
    // changes the state to start the game
    mutating func play(){
        gameState = 2
        botsActive = true
    }
    
    // changes the state to the instructions
    mutating func instructions(){
        gameState = 3
    }
    
    // changes the state to the ai view
    mutating func AI(){
        gameState = 4
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
            
            if (revealedCards.count != 0) && (boardCard.id == revealedCards[0].id){
                revealedCards.removeFirst()
            }
        }
        
        gameChange = true
        return hand
    }
    
    // toggles the player desire to play a shuriken.
    mutating func toggleShuriken(){
        player.shuriken.toggle()
        gameChange = true
    }
}

// MARK: - Card
struct Card: Identifiable {
    var id: Int
    var value: Int
    var reveal = false
    var filename: String {return "\(value)"}
}

// MARK: - Player
struct Player: Identifiable{
    var id = "player"
    var hand: Array<Card> = Array<Card>()
    var shuriken = false
    var gameDifficuly = 1.0
}

// MARK: - Bot
struct Bot: Identifiable {
    var id: Int
    var model = Model()
    var hand: Array<Card>
    var playingCard = false
    var estimate = 100.0
    var shuriken = false
    var emotion = 0
    var scalar = 1.0
}
