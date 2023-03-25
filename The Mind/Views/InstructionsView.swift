//
//  InstructionsView.swift
//  The Mind
//
//  Created by Ioana - Andreea Cojocaru on 3/19/23.
//

import SwiftUI

struct InstructionsView: View {
    @ObservedObject var game: TM_ViewModel
    var body: some View {
        ZStack(alignment: .top){
            Rectangle()
                .fill(Color(#colorLiteral(red: 0.0007156967185, green: 0.002288779709, blue: 0.08772081882, alpha: 1)))
                .edgesIgnoringSafeArea(.all)
            
            ScrollView {
                HStack{
                    Spacer()
                    Button(action: {
                        game.menu()
                    }) {
                        ZStack {
                            Image(systemName: "xmark")
                                .foregroundColor(.white)
                                .padding(.trailing, 10)
                        }
                    }
                }
                VStack(alignment: .center, spacing: 20) {
                    Image("title")
                        .resizable()
                        .scaledToFit()
                        .frame(height: 80)
                    Group{
                        Text("Objective:")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        Text("Players must place their cards in ascending in the middle of the screen without communicating to eachother.")
                            .padding(.bottom)
                        .foregroundColor(.white)
                    }
                    
                    Group {
                        Text("AI Bots:")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        Text("At the beginning of the game, the number of bots can be chosen between 1 and 3. The number of bots can of course affect the difficulty of every level. Moreover, depending on the number of bots, the length of the game changes:")
                            .padding(.bottom)
                            .foregroundColor(.white)
                        Text("1 Bot - 12 Levels")
                            .foregroundColor(.white)
                        Text("2 Bots - 10 Levels")
                            .foregroundColor(.white)
                        Text("3 Bots - 8 Levels")
                            .foregroundColor(.white)
                        
                    }
                    Group{
                        Text("Gameplay:")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        Text("1. The deck of cards is shuffled, and each player receives cards depending on the level of the game: 1 card for level 1, 2 for level 2, and so on.")
                            .padding(.bottom)
                            .foregroundColor(.white)
                        Text("2. Players must play their cards in ascending order on the table, starting with the lowest card.")
                            .padding(.bottom)
                            .foregroundColor(.white)
                        Text("3. If all players successfully play their cards in ascending order, the level is completed.")
                            .padding(.bottom)
                            .foregroundColor(.white)
                        Text("4. If any player plays a card out of order, then one life is lost, and the cards lower than the one played are discarded. If there are any cards left in the game, then the game continues.")
                            .padding(.bottom)
                            .foregroundColor(.white)
                    }
                    Group {
                        Text("Jokers")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        HStack{
                            Text("Anyone in the game can request to use a joker. However, everyone has to agree on using it. The joker can be powerful, as when this is played, the lowest cards of each player are added to the stack in the middle of the board.")
                                .padding(.bottom)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            Image("star")
                                .resizable()
                                .frame(width: 100, height: 100)
                        }
                    }
                    
                    Group {
                        Text("Lives")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        HStack{
                            Text("At the beginning of the game there are 3 lives. Whenever someone plays a card out of order, a life is lost and the game continues by discarding the cards lower than the one played.")
                                .padding(.bottom)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.white)
                            Image("bg_menu")
                                .resizable()
                                .frame(width: 100, height: 180)
                        }
                    }
                    
                    Group {
                        Text("Extras")
                            .bold()
                            .padding(.top)
                            .foregroundColor(.white)
                        Text("Throughout the game, you can earn extra lives when you reach levels 3, 6, or 9.")
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)
                        Text("Extra jokers can be earned when reaching levels 2, 5, and 8.")
                            .padding(.bottom)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.white)

                    }
                }.padding(.horizontal, 20)
            }
        }
    }}
