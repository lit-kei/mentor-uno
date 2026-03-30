//
//  GameView.swift
//  UNO
//
//  Created by 敬祐 on 2026/03/27.
//

import SwiftUI

enum ColorOfCard {
    case red, orange, blue, skyblue, green, yellow, purple, pink, black
}
//red, blue, green, yellow, purple, pink

//enum Effect {
//    case none, changeColor, reverse, skip, plus4
//}
enum Statue {
    case onField, hidden, active, inactive
}

struct Card: Hashable {
    let cardID: Int
    let privateID: Int
    let statue: Statue
}



struct GameView: View {
    let distance: CGFloat = 45
    
    let cardData = CardData().cardData
    
    @State var canTakeCard: Bool = true
    
    @Binding var path: [Route]
    
    
    @State var cards: [[Card]] = [
        [],[],[],[]
    ]
    
    @State var isDrawing = false
    @State var isGetting = false
    @State var animatingCardID: Int? = nil
    @Namespace private var cardAnimation
    
    @State var submittingCardIDs: [Int] = []
    
    @State var field: Int = 0
    @State var nextCard: Int = 0
    @State var turn: Int = 0
    @State var frontCards: [Int] = []
    @State var flipped: Bool = false
    @State private var didFinish = false
    
    @State var animatingToFieldID: Int? = nil
    @State var animatingToField: (player: Int, id: Int)? = nil
    @State var submitQueue: [Int] = []
    @State private var drawAttention = false
    
    let offsetY: CGFloat = 4
    
    var body: some View {
        VStack(spacing: 80) {
            ZStack {
                ForEach(cards[2], id: \.self) { card in
                    ZStack {
                        Image("card")
                            .resizable()
                            .frame(width: 80, height: 120)
                            .cornerRadius(10)
                            /*.matchedGeometryEffect(
                                id: (animatingToField?.player == 2 && animatingToField?.id == card.privateID)
                                    ? "toField_\(2)_\(card.privateID)"
                                    : "cpu_\(2)_\(card.privateID)",
                                in: cardAnimation,
                                isSource: animatingToField?.player == 2 && animatingToField?.id == card.privateID
                            )*/
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2) // 枠線
                            )
                            .rotationEffect(.degrees(180))
                            
                    }
                    .offset(x: calcOffset(card: card, cards: cards[2]))
                        
                }
                
                VStack {
                    Spacer()
                    turnIndicator(for: 2)
                        .offset(y: 20)
                }
            }
                
            HStack(spacing: 80) {
                ZStack {
                    ForEach(cards[1], id: \.self) { card in
                        ZStack {
                            Image("card")
                                .resizable()
                                .frame(width: 80, height: 120)
                                .cornerRadius(10)
                                /*.matchedGeometryEffect(
                                    id: (animatingToField?.player == 1 && animatingToField?.id == card.privateID)
                                        ? "toField_\(1)_\(card.privateID)"
                                        : "cpu_\(1)_\(card.privateID)",
                                    in: cardAnimation,
                                    isSource: animatingToField?.player == 1 && animatingToField?.id == card.privateID
                                )*/
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2) // 枠線
                                )
                                .rotationEffect(.degrees(90))
                        }
                        .offset(y: calcOffset(card: card, cards: cards[1]))
                            
                    }
                    
                    HStack {
                        Spacer()
                        turnIndicator(for: 1)
                            .offset(x: 50)
                        
                    }
                }
                    
                HStack(spacing: 10) {
                    ZStack {
                        Image(cardData[field].name)
                            .resizable()
                            .frame(width: 80, height: 120)
                            /*.matchedGeometryEffect(
                                id: {
                                    if let anim = animatingToField {
                                        return "toField_\(anim.player)_\(anim.id)"
                                    } else {
                                        return "field"
                                    }
                                }(),
                                in: cardAnimation,
                                isSource: false
                            )*/
                            
                            
                    }
                    .cornerRadius(10)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.black, lineWidth: 2)
                    )
                        
                    ZStack {
                        
                        Image("card")
                            .resizable()
                            .frame(width: 80, height: 120)
                            .cornerRadius(10)
                            .offset(y: offsetY)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color.black, lineWidth: 2) // 枠線
                            )
                        
                        Image("card")
                            .resizable()
                            .frame(width: 80, height: 120)
                            .cornerRadius(10)
                            .offset(y: offsetY - 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .offset(y: offsetY - 2)
                                    .stroke(Color.black, lineWidth: 2) // 枠線
                            )
                        Image("card")
                            .resizable()
                            .frame(width: 80, height: 120)
                            .cornerRadius(10)
                            .offset(x: 0, y: offsetY - 6)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .offset(x: 0, y: offsetY - 6)
                                    .stroke(Color.black, lineWidth: 2) // 枠線
                            )
                            
                            
                        Button(action: {
                            if turn == 0 && !isGetting && canTakeCard {
                                let newID = cards[0].count
                                canTakeCard = false
                                isGetting = true
                                    
                                    
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    flipped = true
                                    nextCard = randomCard()
                                }
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                    isDrawing = true
                                    withAnimation(nil) {
                                        flipped = false
                                    }
                                    let newCard = Card(
                                        cardID: nextCard,
                                        privateID: newID,
                                        statue: .inactive
                                    )
                                        
                                    animatingCardID = newID
                                    
                                    withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                                        cards[0].append(newCard)
                                    }
                                        
                                    // 終了後リセット
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                        isDrawing = false
                                        isGetting = false
                                        animatingCardID = nil
                                        
                                        if !cards[0].contains(where: {cardData[$0.cardID].number == cardData[field].number ||
                                            cardData[$0.cardID].color == cardData[field].color}) {
                                                
                                            turn = 1
                                            startCPUTurn()
                                        }
                                    }
                                }
                            }
                        }) {
                            ZStack {
                                Image("card")
                                    .resizable()
                                    .frame(width: 80, height: 120)
                                    .cornerRadius(10)
                                    .offset(y: offsetY - 6)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .offset(y: offsetY - 6)
                                            .stroke(Color.black, lineWidth: 2) // 枠線
                                    )
                                    .opacity(flipped ? 0 : 1)
                                    
                                
                                
                                Image(cardData[nextCard].name)
                                    .resizable()
                                    .frame(width: 80, height: 120)
                                    .matchedGeometryEffect(id: "drawCard", in: cardAnimation)
                                    .cornerRadius(10)
                                    .offset(y: offsetY - 6)
                                    .opacity(animatingCardID == nil ? 1 : 0)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .offset(y: offsetY - 6)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    .scaleEffect(x: -1)
                                    .opacity(flipped ? 1 : 0)
                            }
                            .opacity(isDrawing ? 0 : 1)
                            .offset(y: drawAttention ? -10 : 0)
                            .animation(
                                drawAttention
                                ? .easeInOut(duration: 0.8).repeatForever(autoreverses: true)
                                : .default,
                                value: drawAttention
                            )
                           
                        }
                        .buttonStyle(.plain)
                        .rotation3DEffect(
                            .degrees(flipped ? 180 : 0),
                            axis: (x: 0, y: 1, z: 0),
                            perspective: 0.6
                        )
                        .animation(.easeInOut(duration: 0.5), value: flipped)
                    }
                }
                    
                    
                ZStack {
                    ForEach(cards[3], id: \.self) { card in
                        ZStack {
                            Image("card")
                                .resizable()
                                .frame(width: 80, height: 120)
                                /*.cornerRadius(10).matchedGeometryEffect(
                                    id: (animatingToField?.player == 3 && animatingToField?.id == card.privateID)
                                        ? "toField_\(3)_\(card.privateID)"
                                        : "cpu_\(3)_\(card.privateID)",
                                    in: cardAnimation,
                                    isSource: animatingToField?.player == 3 && animatingToField?.id == card.privateID
                                )*/
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.black, lineWidth: 2) // 枠線
                                )
                                .rotationEffect(.degrees(-90))
                        }
                        .offset(y: calcOffset(card: card, cards: cards[3]))
                            
                    }
                    
                    HStack {
                        turnIndicator(for: 3)
                            .offset(x: -50)
                        Spacer()
                    }
                }
            }
                
            VStack(spacing: 10) {
                ZStack {
                    if frontCards.isEmpty {
                        Text("")
                            .frame(width: 60, height: 90)
                    } else {
                        ForEach(frontCards, id: \.self) { cardIndex in
                            Button(action: {
                                frontCards.removeAll(where: {$0 == cardIndex})
                            }) {
                                Image(cardData[cards[0][cardIndex].cardID].name)
                                    .resizable()
                                    .frame(width: 60, height: 90)
                                    .cornerRadius(5)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 5)
                                            .stroke(Color.black, lineWidth: 2)
                                    )
                                    
                            }
                            .buttonStyle(.plain)
                            .offset(x: calcPreviewOffset(index: frontCards.firstIndex(of: cardIndex)!, max: frontCards.count, d: distance))
                        }
                    }
                }
                    
                turnIndicator(for: 0)
                ZStack {
                    if frontCards.count == cards[0].count {
                        Text("")
                            .frame(width: 100, height: 150)
                    } else {
                        ForEach(cards[0], id: \.self) { card in
                            if !frontCards.contains(card.privateID) {
                                Button(action: {
                                    //カードが手前に出る処理
                                    if turn == 0 {
                                        if frontCards.firstIndex(of: card.privateID) == nil {
                                            frontCards.append(card.privateID)
                                        }
                                    }
                                }) {
                                    
                                    Image(cardData[card.cardID].name)
                                        .resizable()
                                        .frame(width: 100, height: 150)
                                        .cornerRadius(10)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(Color.black, lineWidth: 2)
                                        )
                                        .matchedGeometryEffect(
                                            id: animatingCardID == card.privateID ? "drawCard" : "hand_\(card.privateID)",
                                            in: cardAnimation
                                        )
                                    
                                }
                                .buttonStyle(.plain)
                                .disabled(!isAvailable(card: card))
                                .offset(x: calcOffsetHelper(index: card.privateID, max: cards[0].count, d: 80))
                            }
                            
                        }
                    }
                    
                }
                
                HStack(spacing: 100) {
                    Button(action: {
                        frontCards.removeAll()
                    }) {
                        Text("キャンセル")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 140, height: 50)
                            .background(.blue)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                    .disabled(frontCards.isEmpty)
                        
                        
                    Button(action: {
                        submitCards(player: 0, cards: frontCards)
                        frontCards.removeAll()
                        submittingCardIDs.removeAll()
                        
                        turn = 1
                        startCPUTurn()
                    }) {
                        Text("提出")
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .frame(width: 140, height: 50)
                            .background(frontCards.isEmpty ? .gray : .blue)
                            .clipShape(.rect(cornerRadius: 15))
                    }
                    .buttonStyle(.plain)
                    .disabled(frontCards.isEmpty)
                        
                }
                
            }
        }
        .onAppear {
            initGame()
        }
        .onChange(of: cards) { value, newValue in
            updateDrawSuggestion()
            if newValue.contains(where: { $0.isEmpty }) && !didFinish {
                didFinish = true
                if newValue[0].isEmpty { path.append(.result(win: true))}
                else { path.append(.result(win: false)) }
            }
        }
        .onChange(of: turn) { _, _ in
            updateDrawSuggestion()
        }
        .onChange(of: canTakeCard) { _, _ in
            updateDrawSuggestion()
        }
            
        
    }
    
    func initGame() {
        field = randomCard()
        nextCard = randomCard()
        for i in 0..<4 {
            for j in 0..<7 {
                if i == 0 {
                    cards[0].append(Card(cardID: randomCard(), privateID: j, statue: Statue.inactive))
                } else {
                    cards[i].append(Card(cardID: randomCard(), privateID: j, statue: Statue.hidden))
                }
            }
        }
    }
    
    func calcOffset(card: Card, cards: [Any]) -> CGFloat {
        return calcOffsetHelper(index: card.privateID, max: cards.count, d: distance)
    }
    func calcOffsetHelper(index: Int, max: Int, d: CGFloat) -> CGFloat {
        if max == 1 { return 0 }
        return CGFloat(index) * 2 * d / (CGFloat(max) - 1) - d
    }
    func calcPreviewOffset(index: Int, max: Int, d: CGFloat) -> CGFloat {
        if max == 1 { return 0 }
        let x: CGFloat = 2 * d / CGFloat(cards[0].count - 1)
        return (CGFloat(index) - ((CGFloat(max)-1) / 2)) * x
    }
    
    func isAvailable(card: Card) -> Bool {
        if turn != 0 { return false }
        if frontCards.isEmpty {
            if cardData[field].color != cardData[card.cardID].color &&
                cardData[field].number != cardData[card.cardID].number {
                return false
            }
            return true
        } else {
            return cardData[cards[0][frontCards[0]].cardID].number == cardData[card.cardID].number
        }
    }

    func shouldSuggestDraw() -> Bool {
        if turn != 0 { return false }
        if !canTakeCard { return false }
        
        return !cards[0].contains { isAvailable(card: $0) }
    }
    
    func updateDrawSuggestion() {
        if shouldSuggestDraw() {
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                drawAttention = true
            }
        } else {
            drawAttention = false
        }
    }
    
    func playNextCard() {
        // もう無いなら終了
        if submitQueue.isEmpty {
            animatingToFieldID = nil
            
            turn = 1
            startCPUTurn()
            return
        }
        
        // 次のカード
        let next = submitQueue.removeFirst()
        animatingToFieldID = next
        
        // 少し遅らせてアニメーション開始
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                submitCards(player: 0, cards: [next])
            }
        }
        
        // 次へ
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            playNextCard()
        }
    }
    
    func submitCards(player: Int, cards submitIDs: [Int]) {
        if submitIDs.isEmpty { return }
        
        // 最後に出したカードをfieldに反映
        if let lastID = submitIDs.last,
           let lastCard = cards[player].first(where: { $0.privateID == lastID }) {
            field = lastCard.cardID
        }

        // カード削除
        cards[player].removeAll { card in
            submitIDs.contains(card.privateID)
        }

        // privateID振り直し
        for i in 0..<cards[player].count {
            cards[player][i] = Card(
                cardID: cards[player][i].cardID,
                privateID: i,
                statue: cards[player][i].statue
            )
        }
    }
    func startCPUTurn() {
        Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
            
            cpuAction(player: turn)
            turn += 1
            
            if turn > 3 {
                timer.invalidate()
                turn = 0
                canTakeCard = true
            }
            
            
            
        }
    }
    func cpuAction(player: Int) {
        let hand = cards[player]
        
        // 出せるカードを抽出（例：fieldと一致）
        let playable = hand.filter { card in
            cardData[card.cardID].number == cardData[field].number ||
            cardData[card.cardID].color == cardData[field].color
        }
        
        if !playable.isEmpty {
            if let selected = playable.randomElement() {
                submitCards(player: player, cards: [selected.privateID])
                /*animatingToField = (player, selected.privateID)

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        submitCards(player: player, cards: [selected.privateID])
                    }
                }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                    animatingToField = nil
                }*/
            }
        } else {
            drawCard(player: player)
        }
    }
    func drawCard(player: Int) {
        let newCard = randomCard()
        
        let newID = cards[player].count
        let card = Card(
            cardID: newCard,
            privateID: newID,
            statue: .hidden
        )
        
        cards[player].append(card)
    }
    func turnIndicator(for player: Int) -> some View {
        Circle()
            .fill(turn == player ? Color.green : Color.clear)
            .frame(width: 15, height: 15)
            .animation(.easeInOut(duration: 0.2), value: turn)
    }
}

#Preview {
    @Previewable @State var path: [Route] = []
    return GameView(path: $path)
}
