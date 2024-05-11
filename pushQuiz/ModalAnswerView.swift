//
//  ModalAnswer.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/15.
//

import SwiftUI

struct ModalCorrectView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @State var correct: String
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    HStack{
                        Circle()
                            .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                        //                                                .opacity(0.7)
                            .foregroundColor(.red)
                            .frame(width: 26)
                        Text("正解です")
                            .font(.system(size: 30))
                            .padding(.horizontal,5)
//                            .padding(.top,5)
                    }
                    Text("\(correct)")
                        .font(.system(size: fontSize(for: correct, isIPad: isIPad())))
                    Text("が正解です")
                        .font(.system(size: 20))
                }
                .frame(maxWidth:.infinity)
                .padding(20)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                .padding(.horizontal,20)
                
                HStack{
                    Spacer()
                    Button(action: {
                        if isButtonActive {
//                            showReward = true // ご褒美獲得画面を表示
                            isPresented = false // 現在の画面を閉じる
                        }
                    }) {
                        HStack{
                            Text("戻る")
                            
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color("backgroundColor"))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                    .disabled(!isButtonActive)
                }
                .padding(.trailing,40)
                //            .padding(10)
                .cornerRadius(8)
                .shadow(radius: 10)
                //            .padding()
            }
        }

    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 6
            } else if text.count >= 11 {
                return baseFontSize - 4
            } else if text.count >= 8 {
                return baseFontSize - 2
            } else {
                return baseFontSize
            }
        }
    }
}

struct ModalInCorrectView: View {
    @Binding var isPresented: Bool
    @State private var isContentView: Bool = false
    @State private var isDaily: Bool = false
    @State private var isButtonActive = true
    @State var correct: String
            
    var body: some View {
        ZStack {
            VStack{
                VStack(spacing: 15) {
                    HStack{
                        Image(systemName: "xmark")
                            .resizable()
                            .opacity(0.7)
                            .foregroundColor(.blue)
                            .frame(width: 20,height:20)
                        Text("不正解です")
                            .font(.system(size: 30))
                            .padding(.horizontal,5)
//                            .padding(.top,5)
                    }
                    Text("\(correct)")
                        .font(.system(size: fontSize(for: correct, isIPad: isIPad())))
                    Text("が正解です")
                        .font(.system(size: 20))
                }
                .frame(maxWidth:.infinity)
                .padding(20)
                .background(Color("backgroundColor"))
                .cornerRadius(20)
                .shadow(radius: 10)
                .padding(20)
                .padding(.horizontal,20)
                
                HStack{
                    Spacer()
                    Button(action: {
                        if isButtonActive {
//                            showReward = true // ご褒美獲得画面を表示
                            isPresented = false // 現在の画面を閉じる
                        }
                    }) {
                        HStack{
                            Text("戻る")
                            
                        }
                        .padding()
                        .foregroundColor(.black)
                        .background(Color("backgroundColor"))
                        .cornerRadius(8)
                        .shadow(radius: 1)
                    }
                    .disabled(!isButtonActive)
                }
                .padding(.trailing,40)
                //            .padding(10)
                .cornerRadius(8)
                .shadow(radius: 10)
                //            .padding()
            }
        }

    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 34 : 30 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 14 {
                return baseFontSize - 6
            } else if text.count >= 11 {
                return baseFontSize - 4
            } else if text.count >= 8 {
                return baseFontSize - 2
            } else {
                return baseFontSize
            }
        }
    }
}

#Preview {
    ModalInCorrectView(isPresented: .constant(false), correct: "正解")
}
