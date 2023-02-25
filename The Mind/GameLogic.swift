import Foundation

struct GameLogic <cardContent>{
    var deck: Array<Card>
    var playerHand: Array<Card>
    
    init(n: Int, level: Int){
        
        // generates a deck from 1 tp 100
        deck = Array<Card>()
        for i in 1..<(n+1){
            deck.append(Card(id: i, value: i))
        }
        
        // selects the player cards
        playerHand = Array<Card>()
        for _ in 0..<level{
            if let index = deck.indices.randomElement(){
                let card = deck.remove(at: index)
                playerHand.append(card)
            }
        }
    }
    
    func running(){
        
    }
    
    
    
    func playCard (_ card: Card){
        
    }
    
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
    
}
