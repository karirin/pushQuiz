//
//  QuizEditView.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/14.
//

import SwiftUI

struct QuizEditView: View {
    @ObservedObject var quizManager = QuizManager()
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            List(quizManager.trueQuiz) { quiz in
                // NavigationLinkのdestinationをEditViewに変更
                NavigationLink(destination: EditView(quiz: quiz)) {
                    Text(quiz.question)
                }
            }
            .onAppear {
                quizManager.fetchFlaggedQuizzes()
            }
            .navigationBarTitle("フラグが立っているクイズ", displayMode: .inline)
        }
    }
}

struct EditView: View {
    @ObservedObject var quizManager = QuizManager()
    @Environment(\.presentationMode) var presentationMode
    var quiz: Quiz
    @State private var question: String
    @State private var optionA: String
    @State private var optionB: String
    @State private var optionC: String
    @State private var optionD: String
    @State private var answer: String
    @State private var selectedIntervalType = "分" // Pickerの種類を選ぶためのセグメント
    @State private var selectedMinute: Int = 1
    @State private var selectedHour: Int = 1
    @State private var selectedDay: Int = 1
    @State private var enableNotifications: Bool = true
    @State private var styleNum: Int = 0
    @State private var showStyle: Bool = false
    @State private var showBlankAlert = false
    @State private var showAlert = false
    @State private var showDuplicateOptionsAlert = false
    @State private var activeAlert: addActiveAlert = .none
    @State private var isIntervalChanged = false

//    let intervalTypes = ["分", "時"]
    let minutes = Array(1...60)
    let hours = Array(1...24)
    let days = Array(1...30)

    init(quiz: Quiz) {
        self.quiz = quiz
        _question = State(initialValue: quiz.question)
        _optionA = State(initialValue: quiz.optionA)
        _optionB = State(initialValue: quiz.optionB)
        _optionC = State(initialValue: quiz.optionC)
        _optionD = State(initialValue: quiz.optionD)
        _answer = State(initialValue: quiz.answer)
        if let interval = quiz.notificationInterval, interval > 0 {
            // 86400で割り切れる場合は「日」、3600で割り切れる場合は「時」、それ以外は「分」と判断
//            if interval % 3600 == 0 {
//                _selectedIntervalType = State(initialValue: "日")
//                _selectedDay = State(initialValue: interval / 3600)
//            } else 
            if interval > 60 {
                _selectedIntervalType = State(initialValue: "時")
                _selectedHour = State(initialValue: interval / 60)
            } else {
                _selectedIntervalType = State(initialValue: "分")
                _selectedMinute = State(initialValue: interval)
            }
        } else {
            // 通知が設定されていない場合、デフォルトのPickerの初期値を使用
            _selectedIntervalType = State(initialValue: "分")
            _selectedMinute = State(initialValue: 1)
        }
//        _enableNotifications = State(initialValue: quiz.notificationInterval != 0)
        _enableNotifications = State(initialValue: quiz.notificationInterval != nil && quiz.notificationInterval! > 0)
        UINavigationBar.appearance().titleTextAttributes = [.foregroundColor: UIColor(named: "fontGray") ?? .black]
    }

    var body: some View {
        VStack{
            List {
                Section(header: Text("問題を入力")) {
                    TextField("奥さんの好きな食べ物は？", text: $question, axis: .vertical)
//                        .frame(height:65,alignment : .topLeading)
                        .toolbar { // ここにToolbarを追加
                            ToolbarItemGroup(placement: .keyboard) { // キーボードの上にツールバーを配置
                                Spacer() // 左側にスペースを入れて右寄せにする
                                Button("閉じる") {
                                    hideKeyboard() // キーボードを閉じる処理
                                }
                            }
                        }
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
                                if answer == "\(optionB)" {
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
                                if answer == "\(optionC)" {
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
                                if answer == "\(optionD)" {
                                    Image(systemName: "checkmark")
                                }
                            }.frame(width: 30)
                            TextField("クロワッサン", text: $optionD)
                                .multilineTextAlignment(.leading)
                            Spacer()
                        }
                    }
                }
                Section(header: Text("正解")) {
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
                }
                Section(header: Text("通知間隔の設定")) {
                    Toggle(isOn: $enableNotifications) {
                        if enableNotifications {
                            Text("通知を設定する")
                        } else {
                            Text("通知を設定しない")
                        }
                    }
                    if enableNotifications {
                    Picker("間隔の種類", selection: $selectedIntervalType) {
                        Text("分").tag("分")
                        Text("時").tag("時")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .disabled(!enableNotifications)
                        if selectedIntervalType == "分" {
                            Picker("分を選択", selection: $selectedMinute) {
                                ForEach(minutes, id: \.self) { minute in
                                    Text("\(minute) 分")
                                }
                            }
                            .onChange(of: selectedMinute) { newValue in
                                setIntervalChanged(newValue)
                            }
                        } else if selectedIntervalType == "時" {
                            Picker("時を選択", selection: $selectedHour) {
                                ForEach(hours, id: \.self) { hour in
                                    Text("\(hour) 時")
                                }
                            }
                            .onChange(of: selectedHour) { newValue in
                                setIntervalChanged(newValue)
                            }
                        }
//                        } else if selectedIntervalType == "日" {
//                            Picker("日を選択", selection: $selectedDay) {
//                                ForEach(days, id: \.self) { day in
//                                    Text("\(day) 日")
//                                }
//                            }
//                            .onChange(of: selectedDay) { newValue in
//                                setIntervalChanged(newValue)
//                            }
//                        }
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
                Button("クイズを編集") {
                    if question.isEmpty || optionA.isEmpty || optionB.isEmpty || optionC.isEmpty || optionD.isEmpty {
                        activeAlert = .blank
                        showAlert = true
                    } else if areOptionsDuplicate() {
                        activeAlert = .duplicate
                        showAlert = true
                    } else if [optionA, optionB, optionC, optionD].contains(answer) {
                        self.presentationMode.wrappedValue.dismiss()
                        let notificationDate = computeNotificationDate()  // 通知日時を計算
        //                        let intervalInSeconds = notificationDate.flatMap {
        //                            Calendar.current.dateComponents([.second], from: Date(), to: $0).second
        //                        }
                        
                        let timeInterval = computeTimeIntervalInSeconds() ?? 0
                        
        //                        let intervalInMinutes = intervalInSeconds.map { seconds in
        //                            max(1, (seconds + 30) / 60)  // 秒数を60で割り、小数点以下を四捨五入し、最低でも1を返す
        //                        }
                        let intervalInMinutes = Int(timeInterval / 60)  // 分単位に変
                        //                    quizManager.saveQuiz(quiz: quiz)
                        
                        let options = [optionA, optionB, optionC, optionD]
                        if !enableNotifications {
                            print("¥¥¥¥")
                            let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: 0,correct: 0,incorrect: 0)
                            quizManager.cancelAllNotifications()
                            quizManager.updateQuizzesWithFlagAndInterval(quizId: editQuiz.id)
                            quizManager.updateQuiz(quiz: editQuiz)
                        } else {
                            print("¥¥¥")
                            // 分、時の値が変わったらtrue
                            if isIntervalChanged {
                                let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: intervalInMinutes,correct: 0,incorrect: 0)
                                quizManager.updateQuiz(quiz: editQuiz)
                                
                                if styleNum == 0 {
                                    quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                                } else if styleNum == 1 {
                                    quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                } else {
                                    quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                }
                            } else {
                                // 分、時の値を変えてないが、通知設定の有無だけ変えているとき
                                if quiz.notificationInterval == 0 && enableNotifications {
                                    print("quiz.notificationInterval == 0 && enableNotifications true")
                                    let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: 1,correct: 0,incorrect: 0)
                                    quizManager.updateQuiz(quiz: editQuiz)
                                
                                    if styleNum == 0 {
                                        quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                                    } else if styleNum == 1 {
                                        quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                    } else {
                                        quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                    }
                                } else {
                                    print("quiz.notificationInterval == 0 && enableNotifications false")
                                    let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: quiz.notificationInterval,correct: 0,incorrect: 0)
                                    quizManager.updateQuiz(quiz: editQuiz)
                                
                                    if styleNum == 0 {
                                        quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                                    } else if styleNum == 1 {
                                        quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                    } else {
                                        quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                                    }
                                }
                            }
                        }
                    } else {
                        activeAlert = .contain
                        showAlert = true
                    }
                }
            }
            .listStyle(GroupedListStyle())
        }
        .foregroundColor(Color.primary)
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

        .sheet(isPresented: $showStyle) {
            QuizNotificationView(styleNum: $styleNum)
                .presentationDetents([.large,
//                                              .height(400),
                                      // 画面に対する割合
                    .fraction(isSmallDevice() ? 0.75 : 0.55)
                ])
        }
        .background(Color("backgroundColor"))
        .onAppear{
            quizManager.fetchFlaggedQuizzes()
//            print("onAppear quiz.notificationInterval:\(quiz.notificationInterval)")
//            if let interval = self.quiz.notificationInterval, interval > 0 {
//                if interval % 86400 == 0 {
//                    self.selectedIntervalType = "日"
//                    self.selectedDay = interval / 3600
//                } else if interval % 3600 == 0 {
//                    self.selectedIntervalType = "時"
//                    self.selectedHour = interval / 60
//                } else {
//                    print("onAppear interval:\(interval)")
//                    self.selectedIntervalType = "分"
//                    self.selectedMinute = interval
//                    print("onAppear self.selectedMinute:\(self.selectedMinute)")
//                }
//            }
        }
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
                self.presentationMode.wrappedValue.dismiss()
                let notificationDate = computeNotificationDate()  // 通知日時を計算
//                        let intervalInSeconds = notificationDate.flatMap {
//                            Calendar.current.dateComponents([.second], from: Date(), to: $0).second
//                        }
                
                let timeInterval = computeTimeIntervalInSeconds() ?? 0
                
//                        let intervalInMinutes = intervalInSeconds.map { seconds in
//                            max(1, (seconds + 30) / 60)  // 秒数を60で割り、小数点以下を四捨五入し、最低でも1を返す
//                        }
                let intervalInMinutes = Int(timeInterval / 60)  // 分単位に変
                //                    quizManager.saveQuiz(quiz: quiz)
                
                let options = [optionA, optionB, optionC, optionD]
                if !enableNotifications {
                    print("¥¥¥¥")
                    let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: 0,correct: 0,incorrect: 0)
                    quizManager.cancelAllNotifications()
                    quizManager.updateQuizzesWithFlagAndInterval(quizId: editQuiz.id)
                    quizManager.updateQuiz(quiz: editQuiz)
                } else {
                    print("¥¥¥")
                    // 分、時の値が変わったらtrue
                    if isIntervalChanged {
                        let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: intervalInMinutes,correct: 0,incorrect: 0)
                        quizManager.updateQuiz(quiz: editQuiz)
                        
                        if styleNum == 0 {
                            quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                        } else if styleNum == 1 {
                            quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                        } else {
                            quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                        }
                    } else {
                        // 分、時の値を変えてないが、通知設定の有無だけ変えているとき
                        if quiz.notificationInterval == 0 && enableNotifications {
                            print("quiz.notificationInterval == 0 && enableNotifications true")
                            let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: 1,correct: 0,incorrect: 0)
                            quizManager.updateQuiz(quiz: editQuiz)
                        
                            if styleNum == 0 {
                                quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                            } else if styleNum == 1 {
                                quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                            } else {
                                quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                            }
                        } else {
                            print("quiz.notificationInterval == 0 && enableNotifications false")
                            let editQuiz = Quiz(id: quiz.id, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: true, notificationInterval: quiz.notificationInterval,correct: 0,incorrect: 0)
                            quizManager.updateQuiz(quiz: editQuiz)
                        
                            if styleNum == 0 {
                                quizManager.scheduleCustomNotification(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))  // 秒単位で通知をスケジュール
                            } else if styleNum == 1 {
                                quizManager.scheduleCustomNotificationOnlyQuetion(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                            } else {
                                quizManager.scheduleCustomNotificationAllNothing(date: Date(), quizQuestion: editQuiz.question, options: options, timeInterval: Double(timeInterval))
                            }
                        }
                    }
                }
            } else {
                activeAlert = .contain
                showAlert = true
            }
        }) {
            Text("編集する")
                .foregroundColor(Color("fontGray"))
        })
        .navigationBarTitle("クイズを編集", displayMode: .inline)
    }
    
    func isSmallDevice() -> Bool {
            return UIScreen.main.bounds.width < 390
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
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    func setIntervalChanged<T>(_ value: T) {
        isIntervalChanged = true
    }
    
    func computeNotificationDate() -> Date? {
        // 基準となる日時を設定する（例として画面表示時の日時）
        let referenceDate = Date() // この部分を、ユーザーが画面に入ったときの時刻に設定する
        var dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: referenceDate)
        
        // 秒をリセット
        dateComponents.second = 0

        switch selectedIntervalType {
        case "分":
            dateComponents.minute! += selectedMinute
        case "時":
            dateComponents.hour! += selectedHour
//        case "日":
//            dateComponents.day! += selectedDay
        default:
            return nil // 何も選択されていない場合はnilを返す
        }
        
        return Calendar.current.date(from: dateComponents)
    }
}

struct EditView_Previews: PreviewProvider {
    static var previews: some View {
//        @State var dummyquizs = Quiz(id: "1", question: "test", optionA: "a", optionB: "b", optionC: "c", optionD: "d", answer: "answer", flag: true)
//        EditView(quiz: dummyquizs)
//        QuizEditView()
        TopView()
    }
}
