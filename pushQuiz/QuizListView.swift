//
//  QuizListView.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/11.
//

import SwiftUI

struct QuizListView: View {
    @StateObject var quizManager = QuizManager()
    @State private var showFlag: Bool = false
    @State private var checkFlag: Bool = false
    @State private var showAuthManager: Bool = false
    @State private var showPostView: Bool = false
    @State private var isLoading: Bool = true  // デフォルトは true で読み込み中とする
    @State private var showDeleteAlert = false
    @State private var indexSetToDelete: IndexSet?
    @State private var deleteQuizName: String?
    @State private var tutorialNum: Int = 0
    @State private var buttonRect: CGRect = .zero
    @State private var bubbleHeight: CGFloat = 0.0
    @State private var buttonRect2: CGRect = .zero
    @State private var bubbleHeight2: CGFloat = 0.0
    @State private var buttonRect3: CGRect = .zero
    @State private var bubbleHeight3: CGFloat = 0.0
    @State private var buttonRect4: CGRect = .zero
    @State private var bubbleHeight4: CGFloat = 0.0
    @ObservedObject var authManager = AuthManager()
    
    var body: some View {
        NavigationView {
            ZStack{
                VStack{
                    BannerView()
                        .frame(height: 70)
                    HStack{
                        Image("問題リスト")
                            .resizable()
                            .frame(width:210,height:50)
                            .padding(.bottom,10)
                            .padding(.leading)
                        Spacer()
                        Button(action: {
                            tutorialNum =  7 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 7) { success in
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
                    
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    } else if quizManager.quizzes.isEmpty {
                        Spacer()
                            .frame(height:isSmallDevice() ? 100 : 110)
                        Text("問題が設定されていません\n右下のプラスボタンから追加してください")
                            .font(.system(size: 18))
                        Image("問題がない")
                            .resizable()
                            .scaledToFit()
                            .padding(.horizontal,40)
                    } else {
                        List {
                            ForEach(quizManager.quizzes) { quiz in
                                Button(action: {
                                    quizManager.toggleFlag(for: quiz.id)
                                    if checkFlag {
                                        checkFlag = false
                                    } else {
                                        checkFlag = true
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: quiz.flag ? "checkmark.circle.fill" : "circle")
                                            .background(GeometryReader { geometry in
                                                Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                            })
                                        Text(quiz.question)
                                    }
                                    .background(GeometryReader { geometry in
                                        Color.clear.preference(key: ViewPositionKey2.self, value: [geometry.frame(in: .global)])
                                    })
                                }
                            }
                            .onDelete(perform: confirmDelete)
                        }
                        
                    }
                    Spacer()
                    NavigationLink("", destination: QuizAddView().navigationBarBackButtonHidden(true), isActive: $showPostView)
                }
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
                                            Color.clear.preference(key: ViewPositionKey3.self, value: [geometry.frame(in: .global)])
                                        })
                                        .padding()
                                }
                            }
                        }
                    }
                )
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
                if tutorialNum == 7 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 8 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 8) { success in
                                }
                            }
                    }
                    VStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: .zero) {
                            VStack{
                                Text("こちらの画面では自分で追加した問題を一覧形式で確認することができます\n通知する問題の切り替えなども行えます")
                                Image("一覧")
                                    .resizable()
                                    .frame(width:150, height:140)
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
                            tutorialNum =  8 // タップでチュートリアルを終了
                            authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 8) { success in
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
                if tutorialNum == 8 {
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
                                tutorialNum = 9 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 9) { success in
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
                            .frame(height: buttonRect.minY + bubbleHeight + 50)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("チェックマークをつけると通知対象として設定中の問題となります")
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
                        tutorialNum = 9 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 9) { success in
                        }
                    }
                }
                if tutorialNum == 9 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                RoundedRectangle(cornerRadius: 8, style: .continuous)
                                    .padding(.horizontal,-400)
                                    .padding(.vertical,-10)
                                    .frame(width: buttonRect2.width, height: buttonRect2.height)
                                    .position(x: buttonRect2.midX, y: buttonRect2.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 10 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 10) { success in
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
                            .frame(height: buttonRect2.minY + bubbleHeight2  + 50)
                        VStack(alignment: .trailing, spacing: .zero) {
                            Text("左にスワイプすると削除ボタンが表示されます")
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
                        tutorialNum = 10 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 10) { success in
                        }
                    }
                }
                if tutorialNum == 10 {
                    GeometryReader { geometry in
                        Color.black.opacity(0.5)
                        // スポットライトの領域をカットアウ
                            .overlay(
                                Circle()
                                    .frame(width: buttonRect3.width, height: buttonRect3.height)
                                    .position(x: buttonRect3.midX, y: buttonRect3.midY)
                                    .blendMode(.destinationOut)
                            )
                            .ignoresSafeArea()
                            .compositingGroup()
                            .background(.clear)
                            .onTapGesture{
                                tutorialNum = 0 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
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
                            .frame(height: buttonRect3.minY + bubbleHeight3 - 100)
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
                        tutorialNum = 0 // タップでチュートリアルを終了
                        authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 0) { success in
                        }
                    }
                }
            }
            .alert("削除の確認", isPresented: $showDeleteAlert) {
                Button("キャンセル", role: .cancel) {
                    // キャンセル時は削除するクイズの名前をリセット
                    deleteQuizName = nil
                }
                Button("削除", role: .destructive) {
                    if let indexSet = indexSetToDelete {
                        deleteQuiz(at: indexSet)
                    }
                }
            } message: {
                // deleteQuizNameがnilでなければその名前を表示し、nilであれば空のTextを表示
                Text(deleteQuizName != nil ? "「\(deleteQuizName!)」を削除してもよろしいですか？" : "")
            }
            .listStyle(.grouped)
            .scrollContentBackground(.hidden)
            .background(Color("backgroundColor"))
            .foregroundColor(Color.primary)
            .onAppear {
                quizManager.fetchQuizzes() {
                    self.isLoading = false  // fetchQuizzes 完了後に isLoading を false に
                }
            }
            .onChange(of: checkFlag) { isflag in
                quizManager.fetchQuizzes() {
                    self.isLoading = false  // fetchQuizzes 完了後に isLoading を false に
                }
            }
        }
//        .navigationViewStyle(StackNavigationViewStyle())
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
    
    func isIPad() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    func confirmDelete(at offsets: IndexSet) {
       indexSetToDelete = offsets
       // 削除するクイズの名前を取得し、状態変数に保存
       if let index = offsets.first {
           deleteQuizName = quizManager.quizzes[index].question
       }
       showDeleteAlert = true
   }

   // 実際の削除処理を行うメソッド
   func deleteQuiz(at offsets: IndexSet) {
       offsets.forEach { index in
           let quizId = quizManager.quizzes[index].id
           quizManager.deleteQuiz(quizId: quizId)
       }
       indexSetToDelete = nil
       deleteQuizName = nil  // 削除後に削除するクイズの名前をリセット
   }
    
    func isSmallDevice() -> Bool {
        return UIScreen.main.bounds.width < 390
    }
}


#Preview {
//    QuizListView()
    TopView()
}
