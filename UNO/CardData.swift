//
//  CardData.swift
//  UNO
//
//  Created by 敬祐 on 2026/03/28.
//

import Foundation

let cardKinds = 24

func randomCard() -> Int {
    return Int.random(in: 0..<cardKinds)
}

struct cardDef {
    let name: String
    let color: ColorOfCard
    let number: Int
}

class CardData {
    let cardData: [cardDef] = [
        cardDef(name: "あいりす", color: ColorOfCard.pink, number: 1),
        cardDef(name: "あるが", color: ColorOfCard.blue, number: 4),
        cardDef(name: "かいり", color: ColorOfCard.red, number: 6),
        cardDef(name: "きほもり", color: ColorOfCard.red, number: 4),
        cardDef(name: "けいたん", color: ColorOfCard.skyblue, number: 3),
        cardDef(name: "けーちゃん", color: ColorOfCard.pink, number: 4),
        cardDef(name: "こなん", color: ColorOfCard.red, number: 7),
        cardDef(name: "さくこ", color: ColorOfCard.purple, number: 7),
        cardDef(name: "せい", color: ColorOfCard.purple, number: 8),
        cardDef(name: "ダブル", color: ColorOfCard.orange, number: 3),
        cardDef(name: "てらもん", color: ColorOfCard.skyblue, number: 6),
        cardDef(name: "なつつ", color: ColorOfCard.skyblue, number: 8),
        cardDef(name: "ノース", color: ColorOfCard.yellow, number: 3),
        cardDef(name: "ぴーなつ", color: ColorOfCard.pink, number: 7),
        cardDef(name: "ピコ", color: ColorOfCard.pink, number: 9),
        cardDef(name: "ひなぽん", color: ColorOfCard.skyblue, number: 1),
        cardDef(name: "ましゅん", color: ColorOfCard.blue, number: 5),
        cardDef(name: "まるぴー", color: ColorOfCard.purple, number: 6),
        cardDef(name: "もりね", color: ColorOfCard.yellow, number: 5),
        cardDef(name: "ゆうゆ", color: ColorOfCard.blue, number: 6),
        cardDef(name: "ゆるゆる", color: ColorOfCard.green, number: 6),
        cardDef(name: "らい", color: ColorOfCard.yellow, number: 9),
        cardDef(name: "らむーる", color: ColorOfCard.skyblue, number: 7),
        cardDef(name: "りじ", color: ColorOfCard.purple, number: 1)
    ]
    
}
