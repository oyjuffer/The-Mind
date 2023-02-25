//
//  ViewModel.swift
//  The Mind
//

import SwiftUI

class Interpreter {
    private var model: GameLogic<String> = GameLogic<String>(n: 100, level: 7)
    
    var playerHand: Array<GameLogic<String>.Card> {
        return model.playerHand
    }
}
