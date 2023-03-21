//
//  Bot.swift
//  The Mind
//

import Foundation


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// This function will be called by the phone and converts input to other datastructures   ///////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func prediction(bot: Bot, nBots: Int, boardCard: Card, life: Int, lifeLost: Bool , level: Int, trial: Int, previousDeckCard: Int, RTpreviousRound: Double, totalHands: Int) -> (Double, Bool, Double, Double){

    
    // TRANSLATION:
    let cardsPlayer = bot.hand  // contains all the cards, of type <Card>.
    var cardsPlayerValues = Array<Int>()
    for card in cardsPlayer{
        cardsPlayerValues.append(card.value)
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
    let jokerRequest = bot.shuriken
    
    let (rt, joker, emotion, newScalar) = onePrediction(Deck: cardsPlayerValues, minCardPlayer: minCardPlayer, tableCard: tableCard, nrOfPlayer: nrOfPlayer, JokerRequest: jokerRequest, totalLife: totalLife, PlayerAmountofCards: playerAmountOfCards, m: m, trialNr: trialNr, lifeLostpreviousRound: lifeLostPreviousRound, bot: bot, RTpreviousRound: RTpreviousRound, previoustablecard: previousDeckCard, scalar: scalar, level: level)
    
    // results of the stupid bot, until we can get this prediction function working. 
    return (rt, joker, emotion, newScalar)
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// functions ///////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func onePrediction(Deck: [Int], minCardPlayer: Int, tableCard: Int, nrOfPlayer: Int, JokerRequest: Bool, totalLife: Int, PlayerAmountofCards: Int, m: Model, trialNr: Int, lifeLostpreviousRound: Bool, bot: Bot, RTpreviousRound: Double, previoustablecard: Int, scalar: Double, level: Int) -> (Double, Bool, Double, Double) {
    
    let perception_time = 0.11 // Time to perceive the stimulus
    let response_time = 0.2 // for execution of motor response
    let potentialNumbers = (100 - tableCard)
    var scalar = scalar
    
    // When I have card 1 or my card is the next higher one
    if minCardPlayer == 1 || minCardPlayer - tableCard == 1 {
        let waiting = pulses_to_time(0.0)
        let RT = perception_time + response_time + waiting
        return (RT, false, (RT)/4, 0)
    }
    
    // When they have a joker Request i Accept
    if JokerRequest {
        let waiting = pulses_to_time(0.0)
        let RT = perception_time + response_time + waiting
        return (RT, true, -1, 0)
    }
    
    // When my total life is low, or the amount of cards left and the amount of cards we have is the same (difficult), When I have a higher confidence
    if (totalLife == 0 && 1 >= (potentialNumbers - (PlayerAmountofCards))) || trialNr == 0 {
        let waiting = pulses_to_time(0.0)
        let RT = perception_time + response_time + waiting
        return (RT, true, -1, 0)
    }
    
    // For all other cases we have to judge the RT because it is neither high nor low
    else {
        let pulses = determinePulses(m: m, Deck: Deck, nrPlayer: nrOfPlayer, tableCard: tableCard, totalLife: totalLife, trialNr: trialNr)
        let waiting = pulses_to_time(Double(pulses))
        var RT = perception_time + response_time + waiting
        
        // LONG TERM ADAPTATION
        // We adapt, so we change the constant, "scalar" each iteration a bit and multiply it with the RT.
        scalar *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        RT *= scalar
//
//        // SHORT TERM ADAPTATION We play slower with more player, slower with less life, slower if we lost previous round and at the beginning and end, when we dont know the style, each level is more difficult and should be played slower
        RT *= gameDifficulty(nrOfPlayer: nrOfPlayer, totalLife: totalLife, lifeLostpreviousRound: lifeLostpreviousRound, trialNr: trialNr, level: level, totalAmoundCards: PlayerAmountofCards, tableCard: tableCard, minCardPlayer: minCardPlayer)
//        // Short Term Adaptation We slow down when we would have played the previous round the card quicker, and vice versa
        RT *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        
        let emotion = RT / 4
        
        return (RT, false, emotion, scalar)
    }}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Helping functions ///////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func determinePulses(m: Model, Deck: [Int], nrPlayer: Int, tableCard: Int, totalLife: Int, trialNr: Int) -> Int {
    
    let currentDifference = Double(Deck[0] - tableCard)
    var pulses: Int = 0

    let chunk = Chunk(s: "retrieve", m:m)
    chunk.setSlot(slot:"CurrentDifference", value:currentDifference)
    let (_, memoryTrace)  = m.dm.partialRetrieve(chunk: chunk, mismatchFunction: mismatchFunction)
    
    if memoryTrace == nil{
        let time = pulses_to_time(Double(currentDifference))
        pulses = time_to_pulses(time)
        return pulses
    }
    
    if memoryTrace?.slotvals["CurrentDifference"]?.number() == -1{
        let time = pulses_to_time(currentDifference)
        pulses = time_to_pulses(time)
    } else {
        
        pulses = Int((memoryTrace?.slotvals["CurrentDifference"]?.number())!)
    }
    
    return pulses
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func mismatchFunction(_ x: Value, _ y: Value) -> Double? {

    if y.number() == nil || x.number() == nil{
        return nil
    }
    
    let distance = abs(x.number()! - y.number()!)
    return -distance/100
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func previousPlayAdaptation(RTpreviousRound: Double, previousDeckCard: Int, tableCard: Int, m: Model) -> Double {
    
    let currentDifference = abs(previousDeckCard - tableCard)
    var scalar = 1.0

    let chunk = Chunk(s: "chunk", m:m)
    chunk.setSlot(slot:"CurrentDifference", value: Double(currentDifference))
    let (_, retrievedChunk) = m.dm.retrieve(chunk: chunk)

    if retrievedChunk != nil{

        let pulsesOfOther = Double(time_to_pulses(RTpreviousRound))
        let myPulses = Double((retrievedChunk?.slotvals["temporal_profile"]?.number())!)

        if myPulses < pulsesOfOther {
            scalar = 1.01
        }
        
        if myPulses > pulsesOfOther {
            scalar = 0.99
        }
    }
    return scalar
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func gameDifficulty(nrOfPlayer: Int, totalLife: Int, lifeLostpreviousRound: Bool, trialNr: Int, level: Int, totalAmoundCards: Int, tableCard: Int, minCardPlayer: Int) -> Double {
    
    var scale = 1.0
    let factor = 0.05 // hyperparameter
    
    // player amount difficulty
    scale -= Double(nrOfPlayer) * factor
    
    // total life difficulty
    scale -= (4 - Double(totalLife)) * factor
    
    // level difficulty
    scale -= Double(level) * factor
    
    // if we lost previous round
    if lifeLostpreviousRound {
        scale -= factor
    }
    
    // At the beginning and end of each round, the game is more difficult so player play slower
    let NrCardsBeginning = level * nrOfPlayer
    let difference = Double(abs(NrCardsBeginning - totalAmoundCards))
    if difference <= 3 || totalAmoundCards < 3 {
        scale += difference * factor
    }
    
    return scale
}

// MARK: - ACT-R Functions

func noise(_ s: Double) -> Double{
    let rand = Double.random(in: 0.001...0.999)
    return s * log((1 - rand) / rand)
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

func pulses_to_time(_ pulses: Double, t_0: Double = 0.011, a: Double = 1.1, b: Double = 0.015, addNoise: Bool = true ) -> Double{
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
