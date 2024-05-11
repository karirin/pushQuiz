//
//  TopVIew.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/11.
//

import SwiftUI

enum ActiveAlert {
    case correct, incorrect, none
}

struct QuizTopView: View {
    
    @ObservedObject var quizManager = QuizManager()
    @State private var showingAlert: Bool = false
    @State private var showingEdit: Bool = false
    @State private var correctFlag: Bool = false
    @State private var inCorrectFlag: Bool = false
    @State private var showPostView: Bool = false
    @State private var showNotificationFlag: Bool = false
    @State private var notificationFlag: Bool = false
    @State private var correctMessage = ""
    @State private var inCorrectMessage = ""
    @State private var activeAlert: ActiveAlert = .none
    @State private var intervalInMinutes: Int? = nil
    @State private var isLoading: Bool = true
    @State private var tutorialNum: Int = 0
    @State private var quizId: String = ""
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var buttonRect4: CGRect = .zero
    @State private var bubbleHeight4: CGFloat = 0.0
    @ObservedObject var authManager = AuthManager()
    @State private var currentQuiz: Quiz?
    @State private var tutorialFlag: Bool = false
    @State private var csFlag: Bool = false
    @State private var showingNotificationAlert = false
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm" // 日本の標準的な日付形式に変更
        formatter.timeZone = TimeZone(identifier: "Asia/Tokyo") // 日本時間に設定
        return formatter
    }()
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack {
                    BannerView()
                        .frame(height: 70)
//                        .padding(.top,isSmallDevice() ? -20 : -10)
                    HStack{
//                        Button(action: {
//                            tutorialNum =  1 // タップでチュートリアルを終了
//                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
//                            }
//                        }) {
//                            Image(systemName: "questionmark.circle.fill")
//                                .resizable()
//                                .frame(width:35,height:35)
//                                .foregroundColor(Color("fontGray"))
//                        }
//                        .padding(.leading)
//                        .opacity(0)
//                        Spacer()
                        Image("設定中の問題")
                            .resizable()
                            .frame(width:210,height:50)
                            .padding(.bottom,10)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            tutorialNum =  1 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
                            }
                        }) {
                            Image(systemName: "questionmark.circle.fill")
                                .resizable()
                                .frame(width:35,height:35)
                                .foregroundColor(Color("fontGray"))
                        }
                        .padding(.trailing)
//                        .padding(.bottom,10)
                    }
//                    .padding(.top)
                    Spacer()
                        .frame(height:isSmallDevice() ? 0 : 0)
                    // クイズを取得していない場合にはローディング表示
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    } else if let quiz = currentQuiz {
                        
                        VStack(alignment: .leading) {
                            HStack{
                                if quizManager.notificationInterval != 0 {
                                    Image(systemName: "clock")
                                    Text("通知間隔: \(formatInterval(minutes: quiz.notificationInterval))")
                               .font(.system(size: 16))
                                } else {
                                    Image(systemName: "clock")
                                    Text("通知なし")
                                }
                                Spacer()
                                Button(action: {
                                    // ボタンが押された時のアクション
                                    showNotificationFlag = true
                                    quizId = quiz.id
                                }) {
                                    HStack{
                                        Image(systemName: "bell.slash.fill")
                                        Text("通知オフ")
                                    }
                                    .padding(5)
                                    .foregroundColor(Color("fontGray"))
                                    .font(.system(size:isSmallDevice() ? 14 : 16))
                                    .overlay(
                                     RoundedRectangle(cornerRadius: 10)
                                         .stroke(Color("fontGray"), lineWidth: 1)
                                    )
                                }
                                Button(action: {
                                    // ボタンが押された時のアクション
                                    showingEdit = true
                                }) {
                                    HStack{
                                        Image(systemName: "square.and.pencil")
                                        Text("編集する")
                                    }
                                    .padding(5)
                                    .foregroundColor(Color("fontGray"))
                                    .font(.system(size:isSmallDevice() ? 14 : 16))
                                    .overlay(
                                     RoundedRectangle(cornerRadius: 10)
                                         .stroke(Color("fontGray"), lineWidth: 1)
                                    )
                                }
                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                            })
                            .font(.system(size: 20))
                            .padding()
                            HStack {
                                Spacer()
                                HStack{
                                    Circle()
                                        .stroke(style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
                                    //                                                .opacity(0.7)
                                        .foregroundColor(.red)
                                        .frame(width: 22)
                                    Text("正解数：\(quizManager.correct)")
                                        .font(.system(size: 24))
                                }
                                Spacer()
                                HStack{
                                    Image(systemName: "xmark")
                                        .resizable()
                                        .opacity(0.7)
                                        .foregroundColor(.blue)
                                        .frame(width: 20,height:20)
                                    Text("不正解数：\(quizManager.incorrect)")
                                        .font(.system(size: 24))
                                }
                                Spacer()
                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                            })
                            VStack{
                                HStack{
                                    Text(quiz.question)
                                        .padding()
                                }
                                .frame(maxWidth:.infinity)
                                .background(.white)
                                .padding(.bottom)
                                
                                           ScrollView{
                                    Button(action: {
                                        correctMessage = quiz.answer
                                        showingAlert = true
                                        if quiz.optionA == quiz.answer {
                                            correctFlag = true
                                            quizManager.incrementCorrectCount(quizId: quiz.id)
                                        } else {
                                            inCorrectFlag = true
                                            quizManager.incrementIncorrectCount(quizId: quiz.id)
                                        }
                                    }) {
                                        Text("\(quiz.optionA)")
                                            .font(.system(size: fontSize(for: quiz.optionA, isIPad: isIPad())))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(Color("fontGray"))
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, isIPad() ? 10 : 2)
                                    
                                    Button(action: {
                                        correctMessage = quiz.answer
                                        showingAlert = true
                                        if quiz.optionB == quiz.answer {
                                            correctFlag = true
                                            quizManager.incrementCorrectCount(quizId: quiz.id)
                                        } else {
                                            inCorrectFlag = true
                                            quizManager.incrementIncorrectCount(quizId: quiz.id)
                                        }
                                    }) {
                                        Text("\(quiz.optionB)")
                                            .font(.system(size: fontSize(for: quiz.optionA, isIPad: isIPad())))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(Color("fontGray"))
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, isIPad() ? 10 : 2)
                                    Button(action: {
                                        correctMessage = quiz.answer
                                        showingAlert = true
                                        if quiz.optionC == quiz.answer {
                                            correctFlag = true
                                            quizManager.incrementCorrectCount(quizId: quiz.id)
                                        } else {
                                            inCorrectFlag = true
                                            quizManager.incrementIncorrectCount(quizId: quiz.id)
                                        }
                                    }) {
                                        Text("\(quiz.optionC)")
                                            .font(.system(size: fontSize(for: quiz.optionA, isIPad: isIPad())))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(Color("fontGray"))
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, isIPad() ? 10 : 2)
                                    Button(action: {
                                        correctMessage = quiz.answer
                                        showingAlert = true
                                        if quiz.optionD == quiz.answer {
                                            correctFlag = true
                                            quizManager.incrementCorrectCount(quizId: quiz.id)
                                        } else {
                                            inCorrectFlag = true
                                            quizManager.incrementIncorrectCount(quizId: quiz.id)
                                        }
                                    }) {
                                        Text("\(quiz.optionD)")
                                            .font(.system(size: fontSize(for: quiz.optionA, isIPad: isIPad())))
                                            .fixedSize(horizontal: false, vertical: true)
                                            .lineLimit(nil)
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .background(Color.white)
                                            .foregroundColor(Color("fontGray"))
                                            .cornerRadius(8)
                                            .shadow(radius: 1)
                                    }
                                    .padding(.horizontal)
                                    .padding(.vertical, isIPad() ? 10 : 2)
                                    .padding(.bottom,60)
                                }
                            }
                            .background(GeometryReader { geometry in
                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                            })
                        
                            NavigationLink("", destination: EditView(quiz:quiz).navigationBarBackButtonHidden(true), isActive: $showingEdit)
                    }
                
         }
                    else {
                        //                        viewModel.rewards.filter { $0.getFlag == 0 }.isEmpty
                        Spacer()
                            .frame(height:isSmallDevice() ? 50 : 50)
                            Text("問題が設定されていません\n問題を追加、選択してください")
                                .font(.system(size: 24))
                            Image("問題が設定されていません")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal,40)
                   }
                    Spacer()
                }
                .frame(maxWidth:.infinity,maxHeight:.infinity)
                .overlay(
                    ZStack {
                        Spacer()
                        HStack {
                            Spacer()
                            VStack{
                                Spacer()
                                HStack {
                                    Spacer()
                                    Button(action: {
                                        self.showPostView = true
                                    }, label: {
                                        Image(systemName: "plus")
                                            .foregroundColor(.gray)
                                            .font(.system(size: 24))
                                    }).frame(width: 60, height: 60)
                                        .background(Color("plusColor"))
                                        .cornerRadius(30.0)
                                        .shadow(radius: 5)
                                        .background(GeometryReader { geometry in
                                            Color.clear.preference(key: ViewPositionKey4.self, value: [geometry.frame(in: .global)])
                                        })
                                        .padding()
                                }
                            }
                        }
                    }
                )
                .alert("問題を通知するのを止めますか？", isPresented: $showNotificationFlag) {
                    Button("止める", role: .destructive) {
                        quizManager.cancelAllNotifications()
                        print("alert quizId:\(quizId)")
                        quizManager.updateQuizzesWithFlagAndInterval(quizId: quizId)
                        notificationFlag = true
                    }
                    Button("キャンセル", role: .cancel) {}
                }
                if csFlag == true {
                    HelpModalView(isPresented: $csFlag)
                }
                if showingNotificationAlert == true {
                    NotificationModalView(isPresented: $showingNotificationAlert)
                }
                if correctFlag {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture{
                            correctFlag = false
                        }
                    ModalCorrectView(isPresented: $correctFlag, correct: correctMessage)
                        .onTapGesture{
                            correctFlag = false
                        }
                }
                if inCorrectFlag {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture{
                            inCorrectFlag = false
                        }
                    ModalInCorrectView(isPresented: $inCorrectFlag, correct: correctMessage)
                        .onTapGesture{
                            inCorrectFlag = false
                        }
                }
                if tutorialFlag == true {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialFlag = false
                                let options = ["チョコケーキ", "お寿司", "ラーメン", "クロワッサン"]
                                quizManager.scheduleCustomNotification(date: Date(), quizQuestion: "奥さんの好きな食べ物は？", options: options, timeInterval: 300)
                                tutorialNum = 2 // タップでチュートリアルを終了
                                print("tutorialFlag onTapGesture")
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            VStack{
                                Text("ダウンロードありがとうございます！\n\n覚えておきたいことを4択形式の問題で登録して、一定時間ごとに通知を出してくれるアプリです\n初めに簡単な操作について説明します")
                                    
                                Image("携帯")
                                    .resizable()
                                    .frame(width:280, height:230)
                            }
                            .font(.callout)
                            .padding(5)
                            .font(.system(size: 24.0))
                            .padding(.all, 16.0)
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
                            .shadow(radius: 10)
                        }
                        .onTapGesture{
                            print("tutorialFlag onTapGesture")
                            tutorialFlag = false
                            let options = ["チョコケーキ", "お寿司", "ラーメン", "クロワッサン"]
                            quizManager.scheduleCustomNotification(date: Date(), quizQuestion: "奥さんの好きな食べ物は？", options: options, timeInterval: 300)
                            tutorialNum =  2 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack{
                        HStack{
                            Button(action: {
                                tutorialFlag = false
                                let options = ["チョコケーキ", "お寿司", "ラーメン", "クロワッサン"]
                                quizManager.scheduleCustomNotification(date: Date(), quizQuestion: "奥さんの好きな食べ物は？", options: options, timeInterval: 300)
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
                if tutorialNum == 1 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 2 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            VStack{
                                Text("ダウンロードありがとうございます！\n\n覚えておきたいことを4択形式の問題で登録して、一定時間ごとに通知を出してくれるアプリです\n初めに簡単な操作について説明します")
                                    
                                Image("携帯")
                                    .resizable()
                                    .frame(width:280, height:240)
                                    .padding()
                            }
                            .font(.callout)
                            .padding(5)
                            .font(.system(size: 24.0))
                            .padding(.all, 16.0)
                            .background(Color("backgroundColor"))
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(Color.gray, lineWidth: 15)
                            )
                            .cornerRadius(20)
                            .padding(.horizontal, 16)
                            .foregroundColor(Color("fontGray"))
                            .shadow(radius: 10)
                        }
                        .onTapGesture{
                            tutorialNum =  2 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 2) { success in
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack{
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
                if tutorialNum == 2 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .frame(width: buttonRect.width, height: buttonRect.height)
                                    .position(x: buttonRect.midX, y: buttonRect.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 3 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                                }
                            }
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom,20)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect.minY + bubbleHeight - 185)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("登録した問題が4択形式で表示されています\n通知される問題はこの画面で設定されている問題になります\n選択肢をクリックすると正解か不正解かをアラートで確認できます")
                                .padding(5)
                                .font(.callout)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                                .padding(.leading,isSmallDevice() ? 10 : 40)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 3 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 3) { success in
                        }
                    }
                }
                if tutorialNum == 3 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .padding(.horizontal)
                                    .padding(.vertical,-10)
                                    .frame(width: buttonRect2.width, height: buttonRect2.height)
                                    .position(x: buttonRect2.midX, y: buttonRect2.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 4 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                                }
                            }
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom,20)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect2.minY + bubbleHeight2 - 120)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("こちらでは問題の正答数を確認できます")
                                .padding(5)
                                .font(.callout)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                                .padding(.leading,isSmallDevice() ? 10 : 40)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 4 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 4) { success in
                        }
                    }
                }
                if tutorialNum == 4 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .padding(-10)
                                    .frame(width: buttonRect3.width, height: buttonRect3.height)
                                    .position(x: buttonRect3.midX, y: buttonRect3.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 5 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                                }
                            }
                    }
                    VStack{
                        Spacer()
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom,20)
                            Spacer()
                        }
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect3.minY + bubbleHeight3 + 50)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("問題を通知する間隔の時間を確認できます\n通知する時間は「編集する」をクリックすると変更できます\nまた、通知オフをクリックすると通知が来ないように設定されます")
                                .padding(5)
                                .font(.callout)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                                .padding(.leading,isSmallDevice() ? 10 : 40)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 5 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 5) { success in
                        }
                    }
                }
                if tutorialNum == 5 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                Circle()
                                    .frame(width: buttonRect4.width, height: buttonRect4.height)
                                    .position(x: buttonRect4.midX, y: buttonRect4.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 6 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                                }
                            }
                    }
                    VStack{
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            .padding(.bottom,20)
                            Spacer()
                        }
                        Spacer()
                    }
                    VStack {
                        Spacer()
                            .frame(height: buttonRect4.minY + bubbleHeight4 - 100)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("右下のプラスボタンをクリックすると\n新しい問題を設定することができます")
                                .padding(5)
                                .font(.callout)
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                                .padding(.leading,isSmallDevice() ? 10 : 40)
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    .onTapGesture{
                        tutorialNum = 6 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
                        }
                    }
                }
                if tutorialNum == 6 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("以上のような機能で覚えたいことを4択形式の問題で反復して解いて覚えることができるアプリになります\n\nぜひ、ご活用ください")
                                .font(.callout)
                                .padding(5)
                                .font(.system(size: 24.0))
                                .padding(.all, 16.0)
                                .background(Color("backgroundColor"))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 20)
                                        .stroke(Color.gray, lineWidth: 15)
                                )
                                .cornerRadius(20)
                                .padding(.horizontal, 16)
                                .foregroundColor(Color("fontGray"))
                                .shadow(radius: 10)
                        }
                        .onTapGesture{
                            tutorialNum =  0 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                            }
                        }
                        Spacer()
                    }
                    .ignoresSafeArea()
                    VStack{
                        HStack{
                            Button(action: {
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                                }
                            }) {
                                HStack{
                                    Text("スキップする")
                                        .font(.callout)
                                    Image(systemName: "forward")
                                }
                                .padding(5)
                                    .padding(.all, 16.0)
                                    .background(Color("backgroundColor"))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 20)
                                            .stroke(Color.gray, lineWidth: 15)
                                    )
                                    .cornerRadius(20)
                                    .padding(.horizontal, 16)
                                    .foregroundColor(Color("fontGray"))
                                    .shadow(radius: 10)
                            }
                            Spacer()
                        }
                        Spacer()
                    }
                }
                NavigationLink("", destination: QuizAddView().navigationBarBackButtonHidden(true), isActive: $showPostView)
//                    .navigationTitle("設定中の問題")
                    
//                    .navigationBarItems(leading:
//                                                HStack {
//                        Button(action: {
//                            tutorialNum =  1 // タップでチュートリアルを終了
//                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
//                            }
//                        }) {
//                            Image(systemName: "questionmark.circle.fill")
//                                .resizable()
//                                .frame(width:35,height:35)
//                                .foregroundColor(Color("fontGray"))
//                        }
//                        .padding(.leading)
//                        .opacity(0)
//                        Spacer()
//                        Image("設定中の問題")
//                            .resizable()
//                            .aspectRatio(contentMode: .fit)
////                            .padding(.vertical, 5)
//                        Spacer()
//                        Button(action: {
//                            tutorialNum =  1 // タップでチュートリアルを終了
//                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 1) { success in
//                            }
//                        }) {
//                            Image(systemName: "questionmark.circle.fill")
//                                .resizable()
//                                .frame(width:35,height:35)
//                                .foregroundColor(Color("fontGray"))
//                        }
////                        .padding(.trailing)
////                        .padding(.bottom,10)
//                    })
            }
            .foregroundColor(Color("fontGray"))
            .onPreferenceChange(ViewPositionKey.self) { positions in
                self.buttonRect = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey2.self) { positions in
                self.buttonRect2 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey3.self) { positions in
                self.buttonRect3 = positions.first ?? .zero
            }
            .onPreferenceChange(ViewPositionKey4.self) { positions in
                self.buttonRect4 = positions.first ?? .zero
            }
            .background(Color("backgroundColor"))
            .onChange(of: correctFlag) { flag in
                quizManager.fetchQuizzes() {}
                quizManager.fetchFlaggedQuizzes()
            }
            .onChange(of: inCorrectFlag) { flag in
                quizManager.fetchQuizzes() {}
                quizManager.fetchFlaggedQuizzes()
            }
            .onChange(of: notificationFlag) { flag in
                print("onChange notificationFlag")
                quizManager.fetchQuizzes() {
                    notificationFlag = false
                }
                quizManager.fetchFlaggedQuizzes()
            }
            .onAppear {
                
//                let options = ["4月20日", "4月21日", "4月22日", "4月23日"]
//                quizManager.scheduleCustomNotification(date: Date(), quizQuestion: "結婚記念日はいつ？aaa", options: options, timeInterval: 60) 
                let userDefaults = UserDefaults.standard
                if !userDefaults.bool(forKey: "hasLaunchedBeforeOnappear") {
                    // 初回起動時の処理
                    print("hasLaunchedBeforeOnappear")
                    let options = ["チョコケーキ", "お寿司", "ラーメン", "クロワッサン"]
                    quizManager.scheduleCustomNotification(date: Date(), quizQuestion: "奥さんの好きな食べ物は？", options: options, timeInterval: 300)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
//                        viewModel.isLoading = false
                        tutorialFlag = true
                        quizManager.fetchQuizzes() {
        //                    self.isLoading = false
                            setCurrentQuiz() {
                                quizManager.fetchFlaggedQuizzes()
                                self.isLoading = false
                            }
                        }
                    }
                    userDefaults.set(true, forKey: "hasLaunchedBeforeOnappear")
                    userDefaults.synchronize()
                }
                authManager.fetchUserFlag { userFlag, error in
                    if let error = error {
                        // エラー処理
                        print(error.localizedDescription)
                    } else if let userFlag = userFlag {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            print("authManager.fetchUserFlag1")
                            if userFlag == 0 {
                                print("authManager.fetchUserFlag2")
                                executeProcessEveryFifthTimes()
                            }
                        }
                    }
                }
                authManager.fetchUserFlag2 { userFlag, error in
                    if let error = error {
                        // エラー処理
                        print(error.localizedDescription)
                    } else if let userFlag2 = userFlag {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            print("authManager.fetchUserFlag1")
                            if userFlag2 == 0 {
                                print("authManager.fetchUserFlag2")
                                executeProcessEveryFiftyTimes()
                            }
                        }
                    }
                }
                quizManager.fetchQuizzes() {
//                    self.isLoading = false
                    setCurrentQuiz() {
                        self.isLoading = false
                        quizManager.fetchFlaggedQuizzes()
                    }
                }
            }
            .onChange(of: showPostView) { flag in
                quizManager.fetchQuizzes(){
//                    self.isLoading = false
                }
            }
        }
//        .navigationViewStyle(StackNavigationViewStyle())
//        .navigationViewStyle(DefaultNavigationViewStyle())
        .modifier(NavigationViewStyleModifier(isIPad: isIPad()))
    }
    
    struct NavigationViewStyleModifier: ViewModifier {
        let isIPad: Bool

        func body(content: Content) -> some View {
            if isIPad {
                return AnyView(content.navigationViewStyle(StackNavigationViewStyle()))
            } else {
                return AnyView(content.navigationViewStyle(DefaultNavigationViewStyle()))
            }
        }
    }
    
    func executeProcessEveryFifthTimes() {
        // UserDefaultsからカウンターを取得
        let countForTenTimes = UserDefaults.standard.integer(forKey: "launchCountForThreeTimes") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(countForTenTimes, forKey: "launchCountForThreeTimes")
        
        // 3回に1回の割合で処理を実行
        if countForTenTimes % 10 == 0 {
            csFlag = true
        }
    }
    
    func executeProcessEveryFiftyTimes() {
        // UserDefaultsからカウンターを取得
        let countForTenTimes = UserDefaults.standard.integer(forKey: "launchCountForFiftyTimes") + 1
        
        // カウンターを更新
        UserDefaults.standard.set(countForTenTimes, forKey: "launchCountForFiftyTimes")
        
        // 3回に1回の割合で処理を実行
        if countForTenTimes % 15 == 0 {
            showingNotificationAlert = true
        }
    }
    
    func setCurrentQuiz(completion: @escaping () -> Void) {
        currentQuiz = quizManager.quizzes.first(where: { $0.flag })
        completion()
    }
    
    func fontSize(for text: String, isIPad: Bool) -> CGFloat {
        let baseFontSize: CGFloat = isIPad ? 24 : 20 // iPad用のベースフォントサイズを大きくする

        let englishAlphabet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ")
        let textCharacterSet = CharacterSet(charactersIn: text)

        if englishAlphabet.isSuperset(of: textCharacterSet) {
            return baseFontSize
        } else {
            if text.count >= 25 {
                return baseFontSize - 6
            } else if text.count >= 21 {
                return baseFontSize - 6
            } else if text.count >= 17 {
                return baseFontSize - 6
            } else {
                return baseFontSize - 4
            }
        }
    }
    
    func formatInterval(minutes: Int?) -> String {
        guard let minutes = minutes else {
            return "未設定"
        }
        
        let days = minutes / 1440
        let hours = (minutes % 1440) / 60
        let remainingMinutes = minutes % 60
        
        var result = ""
        if days > 0 {
            result += "\(days) 日 "
        }
        if hours > 0 {
            result += "\(hours) 時間 "
        }
        if remainingMinutes > 0 {
            result += "\(remainingMinutes) 分"
        }
        
        return result.isEmpty ? "0 分" : result
    }

    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func checkNotificationAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus != .authorized {
                DispatchQueue.main.async {
                    showingNotificationAlert = true
                }
            }
        }
    }
}

struct QuizTopView_Previews: PreviewProvider {
    static var previews: some View {
//        QuizTopView()
        TopView()
    }
}
