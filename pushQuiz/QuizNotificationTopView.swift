//
//  TopVIew.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/11.
//

import SwiftUI

struct QuizNotificationTopView: View {
    @ObservedObject var quizManager = QuizManager()
    @State private var showingAlert: Bool = false
    @State private var showingEdit: Bool = false
    @State private var correctFlag: Bool = false
    @State private var inCorrectFlag: Bool = false
    @State private var showPostView: Bool = false
    @State private var correctMessage = ""
    @State private var inCorrectMessage = ""
    @State private var activeAlert: ActiveAlert = .none
    @State private var intervalInMinutes: Int? = nil
    @State private var isLoading: Bool = true
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
                    HStack{
                        Button(action: {
                            showPostView = true
                        }) {
                            Image(systemName: "chevron.left")
                                .foregroundColor(.gray)
                            Text("戻る")
                                .foregroundColor(Color("fontGray"))
                        }
                        .padding(.leading)
                        Spacer()
                        Image("設定中の問題")
                            .resizable()
                            .frame(width:210,height:50)
                            .padding(.bottom,10)
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
                    }.padding(.top)
                    Spacer()
                        .frame(height:isSmallDevice() ? 0 : 50)
                    // クイズを取得していない場合にはローディング表示
                    if isLoading {
                        Spacer()
                        ProgressView()
                            .scaleEffect(2)
                        Spacer()
                    } else if quizManager.quizzes.filter { $0.flag == true }.isEmpty {
                        //                        viewModel.rewards.filter { $0.getFlag == 0 }.isEmpty
                        Spacer()
                            .frame(height:isSmallDevice() ? 50 : 50)
                            Text("問題が設定されていません\n問題を追加、選択してください")
                                .font(.system(size: 24))
                            Image("問題が設定されていません")
                                .resizable()
                                .scaledToFit()
                                .padding(.horizontal,40)
                   } else {
                        // 取得したクイズを表示

                           ForEach(quizManager.quizzes) { quiz in
                               if quiz.flag { // flagがtrueのクイズのみ表示
                                   VStack(alignment: .leading) {
                                       HStack{
                                           if quiz.notificationInterval != 0 {
                                               Image(systemName: "clock")
                                               Text("通知間隔: \(formatInterval(minutes: quiz.notificationInterval))")
                                           } else {
                                               Image(systemName: "clock")
                                               Text("通知なし")
                                           }
                                           Spacer()
//                                           Button(action: {
//                                               // ボタンが押された時のアクション
//                                               showingEdit = true
//                                           }) {
//                                               HStack{
//                                                   Image(systemName: "square.and.pencil")
//                                                   Text("編集する")
//                                               }
//                                               .padding(5)
//                                               .foregroundColor(Color("fontGray"))
//                                               .font(.system(size: 16))
//                                               .overlay(
//                                                RoundedRectangle(cornerRadius: 10)
//                                                    .stroke(Color("fontGray"), lineWidth: 1)
//                                               )
//                                           }
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
                                           
//                                           ScrollView{
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
//                                           }
                                       }
                                       .background(GeometryReader { geometry in
                                           Color.clear.preference(key: ViewPositionKey.self, value: [geometry.frame(in: .global)])
                                       })
                                   
                                   NavigationLink("", destination: EditView(quiz:quiz).navigationBarBackButtonHidden(true), isActive: $showingEdit)
                               }
                           }
                       }
                    }
                    Spacer()
                }
                .frame(maxWidth:.infinity,maxHeight:.infinity)
                if correctFlag {
                    ZStack{
                        Color.black.opacity(0.7)
                            .edgesIgnoringSafeArea(.all)
//                            .onTapGesture{
//                                correctFlag = false
//                                showPostView = true
//                            }
                        ModalCorrectView(isPresented: $correctFlag, correct: correctMessage)
//                            .onTapGesture{
//                                correctFlag = false
//                                showPostView = true
//                            }
                    }
                    .onTapGesture{
                        correctFlag = false
                        showPostView = true
                    }
                }
                if inCorrectFlag {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture{
                            inCorrectFlag = false
                            showPostView = true
                        }
                    ModalInCorrectView(isPresented: $inCorrectFlag, correct: correctMessage)
                        .onTapGesture{
                            inCorrectFlag = false
                            showPostView = true
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
                                Text("ダウンロードありがとうございます！\n\n覚えておきたいことを4択形式の問題で登録して、一定時間ごとに通知を出してくれるアプリです。\n初めに簡単な操作について説明します。")
                                    
                                Image("携帯")
                                    .resizable()
                                    .frame(width:280, height:230)
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
                            .frame(height: buttonRect.minY + bubbleHeight - 150)
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
                                tutorialNum = 6 // タップでチュートリアルを終了
                                authManager.updateTutorialNum(userId: authManager.currentUserId ?? "", tutorialNum: 6) { success in
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
                            Text("問題を通知する間隔の時間を確認できます")
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
                NavigationLink("", destination: TopView().navigationBarBackButtonHidden(true), isActive: $showPostView)
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
                quizManager.fetchFlaggedQuizzes()
                quizManager.fetchQuizzes() {}
                if flag == false {
                    showPostView = true
                }
            }
            .onChange(of: inCorrectFlag) { flag in
                quizManager.fetchFlaggedQuizzes()
                quizManager.fetchQuizzes() {}
                if flag == false {
                    showPostView = true
                }
            }
            .onAppear {
                quizManager.fetchQuizzes() {
                    self.isLoading = false
                }
                quizManager.fetchFlaggedQuizzes()
            }
            .onChange(of: showPostView) { flag in
                quizManager.fetchQuizzes(){
                    self.isLoading = false
                }
            }
        }
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
}

struct QuizNotificationTopView_Previews: PreviewProvider {
    static var previews: some View {
        QuizNotificationTopView()
    }
}
