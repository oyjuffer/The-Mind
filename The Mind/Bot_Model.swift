// Importing of Libaries

import Foundation
import Accelerate
import GameplayKit




// Hyperparameter - can be tuned
let mixingPrediction = true // can also be false
let mixingPredictionPercent = 0.8
let factorPP = 0.01 // one precent impact of previous game
let factorGD = 0.01 // one precent reduced speed when for each element making the game more difficult (2 (100% of the game speed) vs 4 player (98% of the game speed)
let adaptation = 3 // [0, 1, 2, 3] -> [0 means no adaptation, 1 means short term, 2 means long term, 3 means short & longterm]
let gamespeed = 0.25 // gamespeed > 1 means we slow it dowm. gamespeed < 1, we increase speed (can be used for game difficulty)


// new
let noiseImpact = true // [True | False] = True for realistic model, more difficult, translation between numbers and waiting time more disrupted
let strategy = "Counting" // ["Counting", "Gabs"]
let typeofActivation = "linear " // ["linear", "exponential"," Sigmoid_custome"]


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Function used for translation and prediction and joker procedure

func prediction(bot: Bot, nBots: Int, playerShuriken: Bool, boardCard: Card, revealedCards: Array<Card>, life: Int, lifeLost: Bool , level: Int, trial: Int, previousDeckCard: Int, RTpreviousRound: Double, totalHands: Int, difficultyLevel: Double) -> (Double, Bool, Int, Double){
        
    // TRANSLATION from values to information used throughut this model:
    let cardsPlayer = bot.hand
    var cardsPlayerValues = Array<Int>()
    for card in cardsPlayer{
        cardsPlayerValues.append(card.value)
    }
    
    // array of revealed cards, When a joker has been played we generate this
    var cardsShown = Array<Int>()
    for card in revealedCards{
        cardsShown.append(card.value)
    }
    let minCardPlayer = cardsPlayerValues[cardsPlayerValues.count - 1]
    let nrOfPlayer = nBots + 1
    let playerAmountOfCards = totalHands
    let tableCard = boardCard.value
    let totalLife = life
    let m = bot.model
    let trialNr = trial
    let lifeLostPreviousRound = lifeLost
    let previousDeckCard = previousDeckCard
    let RTpreviousRound = RTpreviousRound
    let scalar = bot.scalar
    let level = level
    let jokerRequest = playerShuriken
    
    var rt = 0.0
    var joker = false
    var newScalar = scalar
    let perception_time = 0.11 // Time to perceive the stimulus
    let response_time = 0.2 // for execution of motor response
        
// Two path.
    // 1) no joker has been used and we dont change our prediction based on that
    if cardsShown.count == 0 {
        
        (rt, joker, newScalar) = onePrediction(Deck: cardsPlayerValues, minCardPlayer: minCardPlayer, tableCard: tableCard, nrOfPlayer: nrOfPlayer, JokerRequest: jokerRequest, totalLife: totalLife, PlayerAmountofCards: playerAmountOfCards, m: m, trialNr: trialNr, lifeLostpreviousRound: lifeLostPreviousRound, bot: bot, RTpreviousRound: RTpreviousRound, previoustablecard: previousDeckCard, scalar: scalar, level: level)
        
    // 2) A joker has been played
    }else{
        
        
        // three conditions
        let minValueRevealedCards = Int(cardsShown.min() ?? 100)
        
        // I have the lowest card revealed
        if (minCardPlayer == minValueRevealedCards){
            rt = perception_time + pulses_to_time(3) + response_time
            
            
        }else{
            
            // I have the lowest card -> but its lower then the revealed cards (e.g. revealed cards = [3, 6, 9, 10] and after i played 3, i my hand is [4, 45].
            if  (minCardPlayer < minValueRevealedCards){
                rt = perception_time + pulses_to_time(1) + response_time
            }else{
                // We know we dont have lowest card, we wait
                if (minCardPlayer > minValueRevealedCards){
                    rt = perception_time + pulses_to_time(50) + response_time
                }
            }
        }
    }
    
    // Adaptation of game speed
    rt *= gamespeed
        
    // samples an emotion from a normal with the range of -rt/3 and +rt/3
    let distribution = GKGaussianDistribution(lowestValue: -Int(round(rt/3)), highestValue: Int(round(rt/3)))
    let emotion = distribution.nextInt()
    
    return (rt*difficultyLevel, joker, emotion, newScalar)
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// This function is used to generate the RT prediction

func onePrediction(Deck: [Int], minCardPlayer: Int, tableCard: Int, nrOfPlayer: Int, JokerRequest: Bool, totalLife: Int, PlayerAmountofCards: Int, m: Model, trialNr: Int, lifeLostpreviousRound: Bool, bot: Bot, RTpreviousRound: Double, previoustablecard: Int, scalar: Double, level: Int) -> (Double, Bool, Double) {
    
    let perception_time = 0.11 // Time to perceive the stimulus
    let response_time = 0.2 // for execution of motor response
    var pulses: Int = 0
    
    
    
    // Edge Case: I have card 1, my card is the next higher one or there is only one card left
    if minCardPlayer == 1 || abs(minCardPlayer - tableCard) == 1 || PlayerAmountofCards == 1{
        var waiting = difference_to_pulses(0.0, tableCard: tableCard)
        waiting = Int(pulses_to_time(Int(waiting)))
        let RT = perception_time + response_time + Double(waiting)
        return (RT, false, scalar)
        
        
        
    }else{
        
        // A joker request has been made by the player
        if JokerRequest {
            let pulses = difference_to_pulses(100.0, tableCard:  tableCard)
            let waiting = Int(pulses_to_time(Int(pulses)))
            let RT = perception_time + response_time + Double(waiting)
            return (RT, true, scalar)}
    }
    
    // No request and no Edge case - determine pulses
    pulses = determinePulses(m: m, Deck: Deck, nrPlayer: nrOfPlayer, tableCard: tableCard, totalLife: totalLife, trialNr: trialNr) // Counting (linear & non-linear
    
    var waiting: Double = 0.0
    waiting = pulses_to_time(Int(pulses))
    
    // Adaptation
    if strategy == "Custome"{
        waiting = Double(pulses)
    }else {
        waiting = pulses_to_time(Int(pulses))
    }
    
    var RT = perception_time + waiting + response_time
    switch adaptation {
    case 0: // NO ADAPTATION
        RT *= 1
    case 1: // LONG TERM ADAPTATION
        var scalar = scalar
        scalar *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        RT *= scalar
    case 2: // Short TERM ADAPTATION
        RT *= gameDifficulty(nrOfPlayer: nrOfPlayer, totalLife: totalLife, lifeLostpreviousRound: lifeLostpreviousRound, trialNr: trialNr, level: level, totalAmoundCards: PlayerAmountofCards, tableCard: tableCard, minCardPlayer: minCardPlayer)
        RT *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
    default: // LONG & Short TERM ADAPTATION
        var scalar = scalar
        scalar *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        RT *= scalar
        RT *= gameDifficulty(nrOfPlayer: nrOfPlayer, totalLife: totalLife, lifeLostpreviousRound: lifeLostpreviousRound, trialNr: trialNr, level: level, totalAmoundCards: PlayerAmountofCards, tableCard: tableCard, minCardPlayer: minCardPlayer)
        RT *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
    }
    
    return (RT, false, scalar)
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func determinePulses(m: Model, Deck: [Int], nrPlayer: Int, tableCard: Int, totalLife: Int, trialNr: Int) -> Int {
    
    let currentDifference = Double(Deck[Deck.count-1] - tableCard)
    var pulses: Int = 0
    
    let chunk = Chunk(s: "retrieve", m: m)
    chunk.setSlot(slot: "currentDifference", value: currentDifference)
    let (_, memoryTrace)  = m.dm.partialRetrieve(chunk: chunk, mismatchFunction: mismatchFunction)
    
    
    // If we never encountered this situation, i employ a strategy
    if memoryTrace == nil{
        pulses = difference_to_pulses(Double(currentDifference), tableCard: tableCard)
        
        
    // We encountered this situation, so we retrieve
    }else{
        
        let differenceMemory = Int((memoryTrace?.slotvals["currentDifference"]?.number())!)
        let aparte = abs(differenceMemory - Int(currentDifference))
        
        
        // check if the difference between memory and situation is too big and we adapt
        if aparte > 3{
            
            pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!)
            if differenceMemory > Int(currentDifference){
                pulses =  Int((memoryTrace?.slotvals["temporalProfile"]?.number())!) - difference_to_pulses(Double(aparte), tableCard: tableCard)
            }else{
                pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!) + difference_to_pulses(Double(aparte), tableCard: tableCard)
            }
            
            
        // continue if we dont need to adapt
        }else{
            pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!)
        }
    }
    
    
    // Combining the results or not
    if mixingPrediction == false || memoryTrace == nil {
    
        return pulses
        
    }else{
        
        let pulsesStrategy = difference_to_pulses(Double(currentDifference), tableCard: tableCard)
        let componentOne = mixingPredictionPercent * Double(pulses)
        let componentTwo = ((1-mixingPredictionPercent) * Double(pulsesStrategy))
        
        return Int(componentOne + componentTwo)
        
    }
    
    

}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
/// Used as a helper function. Receives two arguments and returnes the level of missmatch
///


func mismatchFunction(_ x: Value, _ y: Value) -> Double? {
    
    if y.number() == nil || x.number() == nil{
        return nil
    }else{
        if x == y {
            return 0.0
        }else{
            let distance = abs(x.number()! - y.number()!)
            return -distance/100
        }
        
    }
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// Own implemented custom sigmoid function used for differentiating among the most difficult values

func sigmoidcustom(x: Int, tableCard: Int) -> Double{
    
    let relativePosition = (Double(x)/Double(abs(tableCard - 100)))
    if relativePosition >= 0.05{
        return Double(x)
    }else{
        return Double(1/(1 + exp(1 - Double(x))))
    }
    
    
}


//and its inverse
func sigmoidcustomBackWards(x: Double, tableCard: Int) -> Int{
    
    let relativePosition = Double(abs(tableCard - 100))
    let returnValue: Double
    
    if x >= 0.05{
        returnValue = x
        return Int(returnValue)
    }else{
        
        return Int(round(x * relativePosition))
    }
    
    
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///used to adapt to previous round


func previousPlayAdaptation(RTpreviousRound: Double, previousDeckCard: Int, tableCard: Int, m: Model) -> Double {

    
    let currentDifference = abs(previousDeckCard - tableCard)
    var scalar = 1.0
    let factor = factorPP // Hyperparameter currently 1%
    
    // conceptually we retrieve the chunk (memory from the last round)
    let chunk = Chunk(s: "chunk", m: m)
    
    //
    chunk.setSlot(slot:"CurrentDifference", value: Double(currentDifference))
    let (_, retrievedChunk) = m.dm.retrieve(chunk: chunk)
        
    if retrievedChunk != nil{
        
        let pulsesOfOther = Double(difference_to_pulses(RTpreviousRound, tableCard: tableCard))
        let myPulses = Double((retrievedChunk?.slotvals["temporal_profile"]?.number())!)
        
        if myPulses < pulsesOfOther {
            scalar += factor
        }
        
        if myPulses > pulsesOfOther {
            scalar -= factor
        }
    }
    return scalar
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


func gameDifficulty(nrOfPlayer: Int, totalLife: Int, lifeLostpreviousRound: Bool, trialNr: Int, level: Int, totalAmoundCards: Int, tableCard: Int, minCardPlayer: Int) -> Double {
    
    var scale = 1.0
    let factor = factorGD
    
    
    // player amount difficulty
    scale += Double(nrOfPlayer) * factor
    
    
    // total life difficulty
    scale += (4 - Double(totalLife)) * factor
    
    
    // level difficulty
    scale += Double(level) * factor
    
    
    // if we lost previous round
    if lifeLostpreviousRound {
        scale += factor
    }
    
    
    // At the beginning and end of each round, the game is more difficult so player play slower
    let NrCardsBeginning = level * nrOfPlayer
    let difference = Double(abs(NrCardsBeginning - totalAmoundCards))
    if difference <= 3 || totalAmoundCards < 3 {
        scale += difference * factor
    }

    
    return scale
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// MARK: - ACT-R Functions

func noise(_ s: Double) -> Double{
    let rand = Double.random(in: 0.001...0.999)
    return s * log((1 - rand) / rand)
}


func difference_to_pulses(_ difference: Double, tableCard: Int, t0: Double = 3, a: Double = 1.01, b: Double = 0.015 , addNoise: Bool = true) -> Int{
    var t0 = t0
    var a = a
    var b = b
    
    
    
    // Reflex like response for edge cases
    if difference == 0{
        return 1
    }
    
    
    
    
    
    
    
    
    
    // Strategy
    if strategy == "Counting" || strategy == "Sigmoid_custome"{ //["Counting", "Gabs", "Sigmoid_custome]
        t0 = 1 + Double.random(in: 0.000...0.005)
    }else{
        t0 = 3
    }
    
    
    // Activation function (linear/exponential)
    if typeofActivation == "Linear" ||  typeofActivation == "Sigmoid_custome" {// ["linear", "exponential"," Sigmoid_custome"]
        a = 1
    }else{
        a = 1.000001
    }
    
    
    // include noise
    if noiseImpact == false{
        b = 0
    }
    
    
    var pulseDuration = t0
    var pulses = 0
    var t = difference
    
    
    while t >= pulseDuration{
        t -= pulseDuration
        pulses += 1
        pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration): 0.0)
    }
    pulses = Int(pulses)
    
    if typeofActivation == "Sigmoid_custome"{
        return  Int(sigmoidcustom(x: pulses, tableCard: tableCard))
    }
    
    
    return pulses
}

func time_to_pulses(_ time: Double, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true ) -> Int{
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

func pulses_to_time(_ pulses: Int, t0: Double = 3, a: Double = 1, b: Double = 0.015, addNoise: Bool = true ) -> Double{
    var t0 = t0
    var a = a
    var b = b
    if strategy == "Counting" || strategy ==  "Sigmoid_custome"{ //["Counting", "Gabs", "Sigmoid_custome]
        t0 = 1 + Double.random(in: 0.000...0.005)
    }else{
        if strategy == "Gabs"{
            t0 = 3
        }
        
    }
    
    if typeofActivation == "Linear" {// new implemented + nois
        a = 1
    }else{
        if typeofActivation == "Exponential" {// new implemented
            a = 1.000001
        }
        
    }
    if noiseImpact == false{
        b = 0
    }
    
    var pulseDuration = t0
    var time = 0.0
    var remainingPulses = pulses
    while remainingPulses > 0{
        time += pulseDuration
        remainingPulses -= 1
        pulseDuration = a * pulseDuration + (addNoise ? noise(b * a * pulseDuration): 0.0)
    }
    
    return time
    
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

