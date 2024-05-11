//
//  TopView.swift
//  smallGaol
//
//  Created by Apple on 2024/03/23.
//

import SwiftUI

struct TopView: View {
    static let samplePaymentDates: [Date] = [Date()]
    @State private var isPresentingAvatarList: Bool = false
    @State private var isPresentingQuizList: Bool = false
    @State private var flag: Bool = false
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State var isAlert: Bool = false
    
    var body: some View {
           ZStack{
               VStack {
                   TabView {
                       QuizTopView()
                           .tabItem {
                               Image(systemName: "q.circle.fill")
                               Text("設定中の問題")
                           }
                       QuizListView()
                           .tabItem {
                               Image(systemName: "list.bullet")
                               Text("問題リスト")
                           }
                       ContactTabView()
                           .tabItem {
                               Image(systemName: "headphones")
                               Text("問い合わせ")
                           }
                       SettingView()
                           .tabItem {
                               Image(systemName: "gearshape.fill")
                               Text("設定")
                           }
                   }
               }
           }
       }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}

#Preview {
    TopView()
}
