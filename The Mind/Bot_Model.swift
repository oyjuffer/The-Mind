//
//  Bot.swift
//  The Mind
//

import Foundation


///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////// This function will be called by the phone and converts input to other datastructures   ///////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func prediction(bot: Bot, nBots: Int, boardCard: Card, life: Int, lifeLost: Bool , level: Int, trial: Int, previousDeckCard: Int, RTpreviousRound: Double, totalHands: Int) -> Double{

    
    // TRANSLATION:
    let cardsPlayer = bot.hand  // contains all the cards, of type <Card>.
    let tableCard = boardCard.value
    let trialNr = trial
    var m = bot.model
    var cardsPlayerValues = Array<Int>()
    for card in cardsPlayer{
        cardsPlayerValues.append(card.value)
    }
    let minCardPlayer = cardsPlayerValues[0]
    let nrOfPlayer = nBots
    var playerAmountOfCards = cardsPlayerValues.count
//    var card = 0
//    var livesPreviousRound = life - (lifeLost ? 1 : 0)
//    var livesCurrentRound = 0
    var lifeLostPreviousRound = lifeLost
    var totalLife = life
    var previousDeckCard = previousDeckCard
    var RTpreviousRound = RTpreviousRound
    var scalar = bot.scalar
    var level = level
    
    // NOT IMPLEMENTED YET
    var jokerRequest = bot.shuriken
    
    let (rt, joker, emotion, newScalar) = onePrediction(Deck: totalHands, minCardPlayer: cardsPlayerValues.min()!, tableCard: tableCard, NrOfPlayer: nrOfPlayer, JokerRequest: jokerRequest, totalLife: totalLife, PlayerAmountofCards: playerAmountOfCards, m: m, trialNr: trialNr, lifeLostpreviousRound: lifeLostPreviousRound, bot: bot, RTpreviousRound: RTpreviousRound, previoustablecard: previousDeckCard, scalar: scalar, level: level)
    
    
    print(rt, joker, emotion, newScalar)
    
    // results of the stupid bot, until we can get this prediction function working. 
    return Double(bot.hand.last!.value - boardCard.value)
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////// functions ///////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

func onePrediction(Deck: Int, minCardPlayer: Int, tableCard: Int, NrOfPlayer: Int, JokerRequest: Bool, totalLife: Int, PlayerAmountofCards: Int, m: Model, trialNr: Int, lifeLostpreviousRound: Bool, bot: Bot, RTpreviousRound: Double, previoustablecard: Int, scalar: Double, level: Int) -> (Double, Bool, Double, Double) {
    
    let perception_time = 0.11 // Time to perceive the stimulus
    let response_time = 0.2 // for execution of motor response
    let cardsLeft = Deck
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
        return (-1, true, -1, 0)
    }
    
    // When my total life is low, or the amount of cards left and the amount of cards we have is the same (difficult), When I have a higher confidence
    if totalLife == 1 || (totalLife == 0 && 1 >= (potentialNumbers - (cardsLeft + Deck))) || trialNr == 0 {
        let waiting = pulses_to_time(0.0)
        let RT = perception_time + response_time + waiting
        return (-1, true, -1, 0)
    }
    
    // For all other cases we have to judge the RT because it is neither high nor low
    else {
        let pulses = determinePulses(m: m, Deck: minCardPlayer, nrPlayer: NrOfPlayer, tableCard: tableCard, totalLife: totalLife, trialNr: trialNr)
        let waiting = pulses_to_time(pulses ?? 0)
        var RT = perception_time + response_time + waiting
        
        // LONG TERM ADAPTATION
        // We adapt, so we change the constant, "scalar" each iteration a bit and multiply it with the RT.
        scalar *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        RT *= scalar
        
        // SHORT TERM ADAPTATION We play slower with more player, slower with less life, slower if we lost previous round and at the beginning and end, when we dont know the style, each level is more difficult and should be played slower
        RT *= gameDifficulty(NrOfPlayer: NrOfPlayer, totalLife: totalLife, lifeLostpreviousRound: lifeLostpreviousRound, trialNr: trialNr, level: level, totalAmoundCards: PlayerAmountofCards, tableCard: tableCard, minCardPlayer: minCardPlayer)
        // Short Term Adaptation We slow down when we would have played the previous round the card quicker, and vice versa
        RT *= previousPlayAdaptation(RTpreviousRound: RTpreviousRound, previousDeckCard: previoustablecard, tableCard: tableCard, m: m)
        
        let emotion = RT / 4
        
        return (RT, false, emotion, scalar)
    }}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
////////////////////////////////Helping functions ///////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func determinePulses(m: Model, Deck: Int, nrPlayer: Int, tableCard: Int, totalLife: Int, trialNr: Int) -> Double? {
    
    let currentDifference = Deck - tableCard
    var pulses: Double? = 0

    let chunk = Chunk(s: "retrieve", m:m)
        
    chunk.setSlot(slot:"CurrentDifference", value: Double(currentDifference))
    let (latency, retrievedChunk)  = m.dm.retrieve(chunk: chunk)
    
    // Check with proff
//    var mismatch = mismatchFunction(x: chunk.slotvals["CurrentDifference"], y: currentDifference)

//    if mismatch == 0 {
//        let time = pulses_to_time(Double(currentDifference))
//        pulses = time_to_pulses(time)
//    } else {
//        pulses = chunk.slotvals["CurrentDifference"]
//    }
    pulses = retrievedChunk?.slotvals["CurrentDifference"]?.number()
    
    return pulses
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func mismatchFunction(x: Int, y: Int, min: Int, max: Int) -> Double {

    let distance = abs(x - y)
    let maxdistance = abs(max-min)
    let difference = 1 - (Double(distance) / Double(maxdistance))
    return difference
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func previousPlayAdaptation(RTpreviousRound: Double, previousDeckCard: Int, tableCard: Int, m: Model) -> Double {
    
    let currentDifference = abs(previousDeckCard - tableCard)
    var scalar = 1.0

    let chunk = Chunk(s: "chunk", m:m)
    chunk.setSlot(slot:"CurrentDifference", value: Double(currentDifference))
    let (latency, retrievedChunk) = m.dm.retrieve(chunk: chunk)

    if retrievedChunk != nil{

        let pulsesOfOther = Double(time_to_pulses(RTpreviousRound))
        let myPulses = retrievedChunk?.slotvals["temporal_profile"]?.number()

        if myPulses ?? pulsesOfOther < pulsesOfOther {
            scalar = 1.01
        }
        
        if myPulses ?? pulsesOfOther > pulsesOfOther {
            scalar = 0.99
        }
    
    }
    return scalar
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
func gameDifficulty(NrOfPlayer: Int, totalLife: Int, lifeLostpreviousRound: Bool, trialNr: Int, level: Int, totalAmoundCards: Int, tableCard: Int, minCardPlayer: Int) -> Double {
    
    var scale = 1.0
    let factor = 0.05 // hyperparameter
    
    // player amount difficulty
    scale -= Double(NrOfPlayer) * factor
    
    // total life difficulty
    scale -= (4 - Double(totalLife)) * factor
    
    // level difficulty
    scale -= Double(level) * factor
    
    // if we lost previous round
    if lifeLostpreviousRound {
        scale -= factor
    }
    
    // At the beginning and end of each round, the game is more difficult so player play slower
    let NrCardsBeginning = level * NrOfPlayer
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
