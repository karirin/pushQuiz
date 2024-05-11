//
//  QuizNotificationView.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/18.
//

import SwiftUI

struct QuizNotificationView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var styleNum: Int
    
    var body: some View {
        NavigationView{
            VStack(spacing:0){
                Spacer()
                Button(action: {
                    styleNum = 0
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    VStack{
                        Image("全ての通知")
                            .resizable()
                            .frame(height:80)
                        Text("通知は問題と選択肢を表示")
                    }
                    .padding()
                }
                .background(styleNum == 0 ? Color("selectColor").opacity(0.3) : Color.clear)
                Divider()
                Button(action: {
                    styleNum = 1
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    VStack{
                        Image("問題だけの通知")
                            .resizable()
                            .frame(height:80)
                        Text("通知は問題だけを表示")
                    }
                    .padding()
                }
                .background(styleNum == 1 ? Color("selectColor").opacity(0.3) : Color.clear)
                Divider()
                Button(action: {
                    styleNum = 2
                    self.presentationMode.wrappedValue.dismiss()
                }) {
                    VStack{
                        Image("何も無い通知")
                            .resizable()
                            .frame(height:80)
                        Text("通知は問題については表示しない")
                    }
                    .padding()
                }
                .background(styleNum == 2 ?  Color("selectColor").opacity(0.3) : Color.clear)
                Divider()
            }
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("fontGray"))
                Text("戻る")
                    .foregroundColor(Color("fontGray"))
            })
            .navigationBarTitle("通知の表示を選択", displayMode: .inline)
            .foregroundColor(Color("fontGray"))
            .background(Color("backgroundColor"))
        }
    }
}

#Preview {
    QuizNotificationView(styleNum: .constant(0))
}
