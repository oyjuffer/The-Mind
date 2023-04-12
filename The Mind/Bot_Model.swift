//
//  Bot.swift
//  The Mind
//

import Foundation
import Accelerate
import GameplayKit

// Hyperparameter


let factorPP = 0.01 // one precent impact of previous game
let factorGD = 0.05 // five precent impact of game difficulty (each of the conditions reduces speed by 5%)
let adaptation = 0 // [0, 1, 2, 3]. 0 means no adaptation, 1 means short term, 2 means long term, 3 means short & longterm
let gamespeed = 0.25 // 33% atm, need to be adjusted to speed of player. (Can also be difficulty - the quicker we play the more difficult it becomes)

// new
let noise = true // True | False] = true if we want to have noise in the model
let strategy = "Gabs" // ["Counting", "Gabs", "Custome"] 0 is counting the to own number (1 sec ~ 1 step), 1 is guessing the amount of gabs i should wait (each gab containing roughly 2-4 numbers)
let typeofActivation = "exponential " // ["linear", "exponential"," Sigmoid_custome"]




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


func prediction(bot: Bot, nBots: Int, playerShuriken: Bool, boardCard: Card, life: Int, lifeLost: Bool , level: Int, trial: Int, previousDeckCard: Int, RTpreviousRound: Double, totalHands: Int) -> (Double, Bool, Int, Double){
    
    // TRANSLATION:
    let cardsPlayer = bot.hand
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
    let jokerRequest = playerShuriken
    
    var (rt, joker, newScalar) = onePrediction(Deck: cardsPlayerValues, minCardPlayer: minCardPlayer, tableCard: tableCard, nrOfPlayer: nrOfPlayer, JokerRequest: jokerRequest, totalLife: totalLife, PlayerAmountofCards: playerAmountOfCards, m: m, trialNr: trialNr, lifeLostpreviousRound: lifeLostPreviousRound, bot: bot, RTpreviousRound: RTpreviousRound, previoustablecard: previousDeckCard, scalar: scalar, level: level)
    rt *= gamespeed
        
    // samples an emotion from a normal with the range of -rt/3 and +rt/3
    let distribution = GKGaussianDistribution(lowestValue: -Int(round(rt/3)), highestValue: Int(round(rt/3)))
    let emotion = distribution.nextInt()
    
    return (rt, joker, emotion, newScalar)
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


func onePrediction(Deck: [Int], minCardPlayer: Int, tableCard: Int, nrOfPlayer: Int, JokerRequest: Bool, totalLife: Int, PlayerAmountofCards: Int, m: Model, trialNr: Int, lifeLostpreviousRound: Bool, bot: Bot, RTpreviousRound: Double, previoustablecard: Int, scalar: Double, level: Int) -> (Double, Bool, Double) {
    
    let perception_time = 0.11 // Time to perceive the stimulus
    let response_time = 0.2 // for execution of motor response
    let potentialNumbers = (100 - tableCard)
    var pulses: Int = 0
    
    // When I have card 1 or my card is the next higher one
    if minCardPlayer == 1 || abs(minCardPlayer - tableCard) == 1 {
        var waiting = difference_to_pulses(0.0, tableCard: tableCard)
        waiting = Int(pulses_to_time(Int(waiting)))
        let RT = perception_time + response_time + Double(waiting)
        return (RT, false, 0)
    }
    
    // When they have a joker Request i Accept
    if JokerRequest {
        let pulses = difference_to_pulses(0.0, tableCard:  tableCard)
        let waiting = Int(pulses_to_time(Int(pulses)))
        let RT = perception_time + response_time + Double(waiting)
        return (RT, true, 0)
    }
    
    // When my total life is low, or the amount of cards left and the amount of cards we have is the same (difficult)
    if (totalLife == 0 && 1 >= (potentialNumbers - (PlayerAmountofCards))) || trialNr == 0 {
        let pulses = difference_to_pulses(0.0, tableCard: tableCard)
        let waiting = pulses_to_time(Int(pulses))
        let RT = perception_time + response_time + waiting
        return (RT, true, 0)
    }
    
    pulses = determinePulses(m: m, Deck: Deck, nrPlayer: nrOfPlayer, tableCard: tableCard, totalLife: totalLife, trialNr: trialNr) // Counting (linear & non-linear
    
    var waiting: Double = 0.0
    // Adaptation
    if strategy == "Custome"{
        waiting = Double(pulses)
    }else {
        waiting = pulses_to_time(Int(pulses))
    }
    
    var RT = perception_time + response_time + waiting
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
    
    if memoryTrace == nil{
        pulses = difference_to_pulses(Double(currentDifference), tableCard: tableCard) // finetune the model (so one second is translated roughlz to one gab, however, those who are close to the card, have not one second, and those abit above are more )
        
        
    }else{
        
        
        let differenceMemory = Int((memoryTrace?.slotvals["currentDifference"]?.number())!)
        let aparte = abs(differenceMemory - Int(currentDifference))
        
        if aparte > 3{
            
            pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!)
            // If the difference in memory is f=higher, this means we that the gab is higher and we should
            if differenceMemory > Int(currentDifference){
                pulses =  Int((memoryTrace?.slotvals["temporalProfile"]?.number())!) - difference_to_pulses(Double(aparte), tableCard: tableCard)
            }else{
                pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!) + difference_to_pulses(Double(aparte), tableCard: tableCard)
            }
        }else{
            pulses = Int((memoryTrace?.slotvals["temporalProfile"]?.number())!)
        }
    }
    
    return pulses
}


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


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


func sigmoidcustom(x: Int, tableCard: Int) -> Double{
    
    let relativePosition = (Double(x)/Double(abs(tableCard - 100)))
    if relativePosition >= 0.05{
        return Double(x)
    }else{
        return Double(1/(1 + exp(1 - Double(x))))
    }
    
    
}

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


func previousPlayAdaptation(RTpreviousRound: Double, previousDeckCard: Int, tableCard: Int, m: Model) -> Double {
    // The idea is that we want to adapt to the previous play.
    
    let currentDifference = abs(previousDeckCard - tableCard)
    var scalar = 1.0
    let factor = factorPP
    
    let chunk = Chunk(s: "chunk", m:m)
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
    if noise == false{
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
    if noise == false{
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

