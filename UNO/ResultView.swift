//
//  ResultView.swift
//  UNO
//
//  Created by 敬祐 on 2026/03/29.
//

import SwiftUI

struct ResultView: View {
    
    @Binding var path: [Int]
    
    var body: some View {
            VStack {
                Text("勝ち！")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Button("ホームに戻る") {
                    path = []   // ←これで一番最初に戻る
                }
            }
        .navigationBarBackButtonHidden(true)
        
        
        
    }
        
}

