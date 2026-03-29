//
//  ResultView.swift
//  UNO
//
//  Created by 敬祐 on 2026/03/29.
//

import SwiftUI

struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var gravity: CGFloat
    var angle: Double
    var vr: Double
    var size: CGFloat
    var color: Color
    var sway: CGFloat
}

struct LaunchConfettiView: View {
    @State private var particles: [ConfettiParticle] = []
    
    let colors: [Color] = [.red, .yellow, .blue, .green, .pink, .purple, .white]
    
    var body: some View {
        GeometryReader { geo in
            TimelineView(.animation) { _ in
                ZStack {
                    ForEach(particles) { p in
                        Rectangle()
                            .fill(p.color)
                            .frame(width: p.size, height: p.size * 1.4)
                            .rotationEffect(.degrees(p.angle))
                            .position(x: p.x, y: p.y)
                    }
                }
                .onAppear {
                    spawn(in: geo.size)
                }
                .task {
                    update(size: geo.size)
                }
            }
        }
        .ignoresSafeArea()
    }
    
    func spawn(in size: CGSize) {
        particles = (0..<140).map { _ in
            ConfettiParticle(
                // 画面下全体から発射
                x: CGFloat.random(in: 0...size.width),
                y: size.height + 20,
                
                vx: CGFloat.random(in: -2...2),
                
                // 🔥 高く打ち上げる
                vy: CGFloat.random(in: -18 ... -12),
                
                gravity: CGFloat.random(in: 0.2...0.35),
                
                angle: Double.random(in: 0...360),
                vr: Double.random(in: -10...10),
                
                size: CGFloat.random(in: 6...12),
                color: colors.randomElement()!,
                
                sway: CGFloat.random(in: 0...100)
            )
        }
    }
    
    func update(size: CGSize) {
        Task {
            let terminalVelocity: CGFloat = 6.0 // ←終端速度
            
            while !particles.isEmpty {
                try? await Task.sleep(nanoseconds: 16_000_000)
                
                for i in particles.indices {
                    
                    // 重力
                    particles[i].vy += particles[i].gravity
                    
                    // 🔥 終端速度制限（速くなりすぎない）
                    if particles[i].vy > terminalVelocity {
                        particles[i].vy = terminalVelocity
                    }
                    
                    // 横移動
                    particles[i].x += particles[i].vx
                    
                    // ひらひら
                    particles[i].x += sin(particles[i].y / 25 + particles[i].sway) * 1.8
                    
                    // 落下
                    particles[i].y += particles[i].vy
                    
                    // 回転
                    particles[i].angle += particles[i].vr
                    
                    // 空気抵抗（ふわっと）
                    particles[i].vx *= 0.995
                    particles[i].vy *= 0.998
                }
                
                particles.removeAll { $0.y > size.height + 50 }
            }
        }
    }
}
struct ResultView: View {
    
    @Binding var path: [Route]
    var win: Bool
    
    @State private var scale: CGFloat = 0.9
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            // 背景（白）
            Color.white
                .ignoresSafeArea()
            
            
            VStack(spacing: 40) {
                
                // 結果カード
                VStack(spacing: 20) {
                    
                    Text(win ? "🎉 YOU WIN 🎉" : "💀 YOU LOSE 💀")
                        .font(.largeTitle)
                        .fontWeight(.heavy)
                        .foregroundColor(win ? .orange : .gray)
                    
                    Text(win ? "勝ち！" : "負け！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 25)
                        .fill(Color.white)
                        .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 25)
                        .stroke(win ? Color.orange : Color.gray, lineWidth: 3)
                )
                .scaleEffect(scale)
                .opacity(opacity)
                
                
                // ボタン
                Button(action: {
                    path = []
                }) {
                    Text("ホームに戻る")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        .frame(width: 220)
                        .background(
                            RoundedRectangle(cornerRadius: 15)
                                .fill(win ? Color.orange : Color.gray)
                        )
                        .foregroundColor(.white)
                        .shadow(radius: 4)
                }
                .scaleEffect(scale)
                .opacity(opacity)
            }
            
            
            if win {
                LaunchConfettiView()
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5)) {
                scale = 1.0
                opacity = 1.0
            }
        }
    }
}
#Preview {
    @Previewable @State var path: [Route] = []
    ResultView(path: $path, win: true)
}
