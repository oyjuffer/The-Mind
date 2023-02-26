import Foundation

struct TM_Model<cardContent>{
    var deck: Array<Card>
    var playerHand: Array<Card>
    var boardCard: Card = Card(id: 0, value: 0)
    
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
                playerHand.sort{$0.value < $1.value}
            }
        }
    }
    
    func running(){
        
    }
    
    func winCondition(){

    }
    
    mutating func playCard (){
        
        if (playerHand.count != 0){
            boardCard = playerHand[0]
            playerHand.removeFirst()
        }
    }
    
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
    
}
