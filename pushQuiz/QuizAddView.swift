//
//  ContentView.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/08.
//

import SwiftUI
import UserNotifications

struct ViewPositionKey: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey2: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey3: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

struct ViewPositionKey4: PreferenceKey {
    static var defaultValue: [CGRect] = []

    static func reduce(value: inout [CGRect], nextValue: () -> [CGRect]) {
        value.append(contentsOf: nextValue())
    }
}

enum addActiveAlert {
    case duplicate, blank, contain, none
}

struct QuizAddView: View {
    @State private var question: String = ""
    @State private var optionA: String = ""
    @State private var optionB: String = ""
    @State private var optionC: String = ""
    @State private var optionD: String = ""
    @State private var answer: String = ""
//    @State private var question: String = "ああああ"
//    @State private var optionA: String = "a"
//    @State private var optionB: String = "b"
//    @State private var optionC: String = "c"
//    @State private var optionD: String = "d"
//    @State private var answer: String = "a"
    @State private var flag: Bool = true
    @State private var showStyle: Bool = false
    @State private var showAlert = false
    @State private var selectedIntervalType = "分" // Pickerの種類を選ぶためのセグメント
    @State private var selectedMinute: Int = 1
    @State private var selectedHour: Int = 1
    @State private var selectedDay: Int = 1
    @State private var isQuestionValid: Bool = true
    @Environment(\.presentationMode) var presentationMode
    @State private var tutorialNum: Int = 0
    @State private var styleNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var buttonRect4: CGRect = .zero
    @State private var bubbleHeight4: CGFloat = 0.0
    @FocusState  var isActive:Bool
    @State private var enableNotifications: Bool = true
    @State private var showBlankAlert = false
    @State private var showDuplicateOptionsAlert = false
    @State private var activeAlert: addActiveAlert = .none

    private var quizManager = QuizManager()
    let intervalTypes = ["分", "時"]
    let minutes = Array(1...60)
    let hours = Array(1...24)
    let days = Array(1...30)
    
    init() {
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "fontGray") ?? .black]
    }
    
    var body: some View {
        ZStack {
            NavigationView {
                VStack{
                    List {
                        Section(header: Text("問題を入力")) {
                            VStack{
                                TextField("奥さんの好きな食べ物は？", text: $question, axis: .vertical)
//                                    .frame(maxWidth: .infinity, minHeight:65,alignment : .topLeading)
                                    .padding(.horizontal)
                                    .onChange(of: question) { newValue in
                                        isQuestionValid = !newValue.isEmpty
                                    }
                                    .focused($isActive)
                                    .toolbar { // ここにToolbarを追加
                                        ToolbarItemGroup(placement: .keyboard) { // キーボードの上にツールバーを配置
                                            Spacer() // 左側にスペースを入れて右寄せにする
                                            Button("閉じる") {
                                                hideKeyboard() // キーボードを閉じる処理
                                            }
                                        }
                                    }
                            }
                            //                        .background(GeometryReader { geometry in
                            //                            Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                            //                        })
                        }
                        
                        Section(header: Text("選択肢(左をクリックすると正解を選択できます)")) {
                                Button(action: { self.answer = "\(optionA)" }) {
                                    HStack {
                                        HStack{
                                            if answer == "\(optionA)" {
                                                Image(systemName: "checkmark")
                                            }
                                        }.frame(width: 30)
                                        TextField("チョコケーキ", text: $optionA)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Button(action: { self.answer = "\(optionB)" }) {
                                    HStack {
                                        HStack{
                                            if answer == "\(optionB)" && answer != "" {
                                                Image(systemName: "checkmark")
                                            }
                                        }.frame(width: 30)
                                        TextField("お寿司", text: $optionB)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Button(action: { self.answer = "\(optionC)" }) {
                                    HStack {
                                        HStack{
                                            if answer == "\(optionC)" && answer != "" {
                                                Image(systemName: "checkmark")
                                            }
                                        }.frame(width: 30)
                                        TextField("ラーメン", text: $optionC)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                                }
                                Button(action: { self.answer = "\(optionD)" }) {
                                    HStack {
                                        HStack{
                                            if answer == "\(optionD)" && answer != "" {
                                                Image(systemName: "checkmark")
                                            }
                                        }.frame(width: 30)
                                        TextField("クロワッサン", text: $optionD)
                                            .multilineTextAlignment(.leading)
                                        Spacer()
                                    }
                            }
                        }
                        
                        Section(header: Text("正解")){
                            HStack{
                                if answer != "" {
                                    Text(answer)
                                } else {
                                    Text("チョコケーキ")
                                        .foregroundColor(.gray)
                                        .opacity(0.5)
                                }
                                Spacer()
                            }
                            //                        .background(GeometryReader { geometry in
                            //                            Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                            //                        })
                        }
                        Section(header: Text("通知時間の設定")){
                            Toggle(isOn: $enableNotifications) {
                                if enableNotifications == true {
                                    Text("通知を設定する")
                                } else {
                                    Text("通知を設定しない")
                                }
                            }
                            if enableNotifications == true {
                                VStack{
                                    Picker("間隔の種類", selection: $selectedIntervalType) {
                                        ForEach(intervalTypes, id: \.self) { type in
                                            Text(type)
                                        }
                                    }
                                    .pickerStyle(SegmentedPickerStyle())
                                    .disabled(!enableNotifications)
                                    
                                    if selectedIntervalType == "分" {
                                        Picker("分を選択", selection: $selectedMinute) {
                                            ForEach(minutes, id: \.self) { minute in
                                                Text("\(minute) 分")
                                            }
                                        }
                                    } else if selectedIntervalType == "時" {
                                        Picker("時を選択", selection: $selectedHour) {
                                            ForEach(hours, id: \.self) { hour in
                                                Text("\(hour) 時")
                                            }
                                        }
                                    } 
//                                    else if selectedIntervalType == "日" {
//                                        Picker("日を選択", selection: $selectedDay) {
//                                            ForEach(days, id: \.self) { day in
//                                                Text("\(day) 日")
//                                            }
//                                        }
//                                    }
                                }
                                .disabled(!enableNotifications)
                                
                                Button(action: {
                                    showStyle = true
                                }) {
                                    HStack{
                                        Text("詳細な通知設定")
                                        Spacer()
                                        if styleNum == 0 {
                                            Text("全て表示")
                                                .foregroundColor(.gray)
                                        }else if styleNum == 1 {
                                            Text("問題だけ表示")
                                                .foregroundColor(.gray)
                                        } else {
                                            Text("何も表示しない")
                                                .foregroundColor(.gray)
                                        }
                                    }
                                }
                            }
                        }
                        VStack{
                            Button("クイズを保存") {
                                if question.isEmpty || optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty {
                                    activeAlert = .blank
                                    showAlert = true
                                } else if areOptionsDuplicate() {
                                    activeAlert = .duplicate
                                    showAlert = true
                                } else if [optionA, optionB, optionC, optionD].contains(answer) {
                                    let timeIntervalInSeconds = computeTimeIntervalInSeconds() ?? 0  // 秒単位で時間を計算
                                    let timeIntervalInMinutes = Int(timeIntervalInSeconds / 60)  // 分単位に変換
                                    
                                    let options = [optionA, optionB, optionC, optionD]
                                    if !enableNotifications {
                                        let quiz = Quiz(id: UUID().uuidString, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: 0, correct: 0, incorrect: 0)
                                        quizManager.cancelAllNotifications()
                                        quizManager.updateQuizzesWithFlagAndInterval(quizId: quiz.id)
                                        quizManager.saveQuiz(quiz: quiz)
                                    } else {
                                        let quiz = Quiz(id: UUID().uuidString, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: timeIntervalInMinutes, correct: 0, incorrect: 0)
                                        if styleNum == 0 {
                                            quizManager.scheduleCustomNotification(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))  // 秒単位で通知をスケジュール
                                        } else if styleNum == 1 {
                                            quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))
                                        } else {
                                            quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))
                                        }
                                        quizManager.saveQuiz(quiz: quiz)
                                    }
                                    
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                                        self.presentationMode.wrappedValue.dismiss()
                                    }
                                } else {
                                    activeAlert = .contain
                                    showAlert = true
                                }
                            }
                        }
                        //                    .background(GeometryReader { geometry in
                        //                        Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                        //                    })
                    }
//                    .foregroundColor(Color("fontGray"))
                    .foregroundColor(Color.primary)
                    .background(Color("backgroundColor"))
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
                    .alert(isPresented: $showAlert) {
                        switch activeAlert {
                        case .contain:
                            return Alert(
                                title: Text("エラー"),
                                message: Text("入力された正解が選択肢のいずれにも含まれていません。"),
                                dismissButton: .default(Text("閉じる"))
                            )
                        case .blank:
                            return Alert(
                                title: Text("エラー"),
                                message: Text("問題と選択肢は空白にできません。"),
                                dismissButton: .default(Text("閉じる"))
                            )
                        case .duplicate:
                            return Alert(
                                title: Text("エラー"),
                                message: Text("選択肢に重複があります。異なる選択肢を入力してください。"),
                                dismissButton: .default(Text("閉じる"))
                            )
                        case .none:
                            fatalError("Unexpected alert without an error condition")
                        }
                    }

//                        case .achievement:
//                            return Alert(
//                                title: Text("習慣達成"),
//                                message: Text(alertMessage),
//                                dismissButton: .default(Text("OK"))
//                            )
//                        }

                }
                .sheet(isPresented: $showStyle) {
                    QuizNotificationView(styleNum: $styleNum)
                        .presentationDetents([.large,
//                                              .height(400),
                                              // 画面に対する割合
                            .fraction(isSmallDevice() ? 0.75 : 0.55)
                        ])
                }
            }
//        .onPreferenceChange(ViewPositionKey.self) { positions in
//            self.buttonRect = positions.first ?? .zero
//        }
//        .onPreferenceChange(ViewPositionKey2.self) { positions in
//            self.buttonRect2 = positions.first ?? .zero
//        }
//        .onPreferenceChange(ViewPositionKey3.self) { positions in
//            self.buttonRect3 = positions.first ?? .zero
//        }
//        .onPreferenceChange(ViewPositionKey4.self) { positions in
//            self.buttonRect4 = positions.first ?? .zero
//        }
            .listStyle(GroupedListStyle())
            .navigationBarItems(leading: Button(action: {
                self.presentationMode.wrappedValue.dismiss()
            }) {
                Image(systemName: "chevron.left")
                    .foregroundColor(Color("fontGray"))
                Text("戻る")
                    .foregroundColor(Color("fontGray"))
            })
            .navigationBarItems(trailing: Button(action: {
                if question.isEmpty || optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty {
                    activeAlert = .blank
                    showAlert = true
                } else if areOptionsDuplicate() {
                    activeAlert = .duplicate
                    showAlert = true
                } else if [optionA, optionB, optionC, optionD].contains(answer) {
                    let timeIntervalInSeconds = computeTimeIntervalInSeconds() ?? 0  // 秒単位で時間を計算
                    let timeIntervalInMinutes = Int(timeIntervalInSeconds / 60)  // 分単位に変換
                    
                    let options = [optionA, optionB, optionC, optionD]
                    if !enableNotifications {
                        let quiz = Quiz(id: UUID().uuidString, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: 0, correct: 0, incorrect: 0)
                        quizManager.cancelAllNotifications()
                        quizManager.updateQuizzesWithFlagAndInterval(quizId: quiz.id)
                        quizManager.saveQuiz(quiz: quiz)
                    } else {
                        let quiz = Quiz(id: UUID().uuidString, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: timeIntervalInMinutes, correct: 0, incorrect: 0)
                        if styleNum == 0 {
                            quizManager.scheduleCustomNotification(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))  // 秒単位で通知をスケジュール
                        } else if styleNum == 1 {
                            quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))
                        } else {
                            quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: Double(timeIntervalInSeconds))
                        }
                        quizManager.saveQuiz(quiz: quiz)
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.presentationMode.wrappedValue.dismiss()
                    }
                } else {
                    activeAlert = .contain
                    showAlert = true
                }
            }) {
                Text("保存する")
                    .foregroundColor(Color("fontGray"))
            })
            .navigationBarTitle("問題を追加", displayMode: .inline)
            }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func areOptionsDuplicate() -> Bool {
        let options = [optionA, optionB, optionC, optionD]
        let uniqueOptions = Set(options)
        return uniqueOptions.count != options.count
    }
    
    func computeTimeIntervalInSeconds() -> TimeInterval? {
        switch selectedIntervalType {
        case "分":
            return Double(selectedMinute * 60)
        case "時":
            return Double(selectedHour * 3600)
//        case "日":
//            return Double(selectedDay * 86400)
        default:
            return nil
        }
    }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }

}

extension UIApplication {
    func closeKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    QuizAddView()
//    TopView()
}
