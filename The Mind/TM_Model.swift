import Foundation

struct TM_Model<cardContent>{
    var deck: Array<Card>
    var playerHand: Array<Card>
    var boardCard: Card = Card(id: 0, value: 0)
    var running: Bool = false
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
    
    // This loop should check the status of the three bots.
    func gameLoop(){
        if running{
            print("running")
        }
    }
    
    // checks if the game has been won and either ends it or goes to next level
    func winCondition(){

    }
    
    func looseCondition(){
        
    }
    
    // allows the player to play their cards.
    mutating func playCard (){
        
        if (playerHand.count != 0){
            boardCard = playerHand[0]
            playerHand.removeFirst()
        }
    }
    
    mutating func playReset(){
        self = TM_Model(n: 100, level: 1)
    }
    
    
    // card structure that contains and ID and the card value. cardContent can be added later if we want to add an image.
    struct Card: Identifiable {
        var id: Int
        var value: Int
//        var content: cardContent
    }
}
