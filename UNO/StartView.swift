//
//  ContentView.swift
//  UNO
//
//  Created by 敬祐 on 2026/03/27.
//

import SwiftUI

enum Route: Hashable {
    case game
    case result(win: Bool)
}

struct StartView: View {
    @State var flipped: Bool = false
    @State var cardIndex: Int = randomCard()
    @State private var rotation: Double = 0
    @State private var isAnimating = false
    
    @State private var path: [Route] = []
    @State private var move = false
    
    
    let cardData = CardData()
    
    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 50) {
                Image("logo")
                    .resizable()
                    .frame(width: 326, height: 46)
                
                
                
                VStack(spacing: 10) {
                    Text("↓ TAP ↓")
                        .font(.title)
                        .fontWeight(.bold)
                        .offset(y: move ? 0 : -20)
                        .onAppear {
                            withAnimation(
                                .easeInOut(duration: 0.8)
                                .repeatForever(autoreverses: true)
                            ) {
                                move.toggle()
                            }
                        }
                    
                    Button(action: {
                        if !isAnimating {
                            isAnimating = true
                            flipped.toggle()
                            if flipped { cardIndex = randomCard() }
                            
                            withAnimation(.easeInOut(duration: 0.5)) {
                                rotation += 180
                            }
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                                isAnimating = false
                            }
                        }
                    }) {
                        ZStack {
                            // 表
                            Image("card")
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .opacity(rotation.truncatingRemainder(dividingBy: 360) < 90 ||
                                         rotation.truncatingRemainder(dividingBy: 360) > 270 ? 1 : 0)
                            
                            // 裏
                            Image(cardData.cardData[cardIndex].name)
                                .resizable()
                                .frame(width: 200, height: 300)
                                .cornerRadius(20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2)
                                )
                                .rotation3DEffect(.degrees(180), axis: (x: 0, y: 1, z: 0))
                                .opacity(rotation.truncatingRemainder(dividingBy: 360) >= 90 &&
                                         rotation.truncatingRemainder(dividingBy: 360) <= 270 ? 1 : 0)
                        }
                        .rotation3DEffect(
                            .degrees(rotation),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.6
                        )
                    }
                    .buttonStyle(.plain)
                    
                    Text(flipped ? cardData.cardData[cardIndex].name : "???")
                        .font(.title)
                        .fontWeight(.bold)
                }
                
                
                VStack(spacing: 40) {
                    NavigationLink(value: Route.game) {
                        Text("ゲームを始める")
                            .font(.system(size: 22, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                            .frame(width: 260, height: 80)
                            .background(
                                ZStack {
                                    // ベース（黒カード）
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(Color.black)
                                    
                                    // グラデ（カードの光）
                                    RoundedRectangle(cornerRadius: 25)
                                        .fill(
                                            LinearGradient(
                                                colors: [
                                                    Color.blue.opacity(0.8),
                                                    Color.purple.opacity(0.6),
                                                    Color.blue.opacity(0.8)
                                                ],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .blur(radius: 20)
                                        .opacity(0.6)
                                    
                                    // 枠（カードっぽい）
                                    RoundedRectangle(cornerRadius: 25)
                                        .stroke(Color.white.opacity(0.15), lineWidth: 2)
                                }
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(Color.blue.opacity(0.6), lineWidth: 1)
                            )
                    }
                    .buttonStyle(NeoCardButtonStyle())
//                    NavigationLink(destination: RuleView()) {
//                        Text("ルールを読む")
//                            .font(.title2)
//                            .fontWeight(.bold)
//                            .foregroundStyle(.white)
//                            .frame(width: 250, height: 70)
//                            .background(Color.blue)
//                            .clipShape(.rect(cornerRadius: 20))
//                        
//                    }
                    
                    
                }
                
            }
            .padding()
            .navigationDestination(for: Route.self) { route in
                switch route {
                case .game:
                    GameView(path: $path)
                    
                case .result(let win):
                    ResultView(path: $path, win: win)
                }
            }
        }
    }
}
struct NeoCardButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.93 : 1.0)
            .brightness(configuration.isPressed ? -0.08 : 0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}


#Preview {
    StartView()
}
