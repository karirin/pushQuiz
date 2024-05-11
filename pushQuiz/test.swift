//
//  PersonRegistrationView.swift
//  persona
//
//  Created by hashimo ryoya on 2023/08/13.
//

import SwiftUI
import Firebase

struct Person: Identifiable {
    var firebaseKey: String
    var id: UUID
    var name: String
    var age: Int
    var bloodType: String
    var birthday: Date
    var relationship: String
    var hobby: String
    var likes: String
    var dislikes: String
    var mutualAcquaintances: String
    var icon: String
    var joy: String
    var anger: String
    var sorrow: String
    var pleasure: String
}

struct PersonRegistrationView: View {
    @State private var name = ""
    @State private var age = ""
    @State private var bloodType = ""
    @State private var birthday = Date()
    @State private var relationship = ""
    @State private var hobby = ""
    @State private var likes = ""
    @State private var dislikes = ""
    @State private var mutualAcquaintances = ""
    @ObservedObject var authManager = AuthManager()
    @State private var selectedIcon: String = "user1"
    @State private var showingIconPicker = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State private var joy = ""
    @State private var anger = ""
    @State private var sorrow = ""
    @State private var pleasure = ""
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/M/d"
        return formatter
    }()

    var body: some View {
        NavigationView {
            VStack{
                List {
                    Section(header: Text("アイコン")) {
                        HStack{
                            Text("アイコン")
                                .bold()
                            Spacer()
                            Button(action: {
                                self.showingIconPicker.toggle()
                            }) {
                                Image(selectedIcon)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 50, height: 50)
                            }
                        }
                    }

                    Section(header: Text("基本情報")) {
                        // 各セクションの間隔を設定
                        HStack{
                            Text("名前")
                                .bold()
                            Spacer()
                            TextField("ペルソナ　太郎", text: $name)
                                .multilineTextAlignment(.trailing)
                        }
                        //                            .frame(maxWidth:.infinity)
                        //                            .background(Color.white)
                        HStack{
                            Text("年齢")
                                .bold()
                            Spacer()
                            Picker("", selection: $age) {
                                Text("不明").tag("不明")
                                ForEach(0..<101) { age in
                                    Text("\(age)").tag(String(age))
                                }
                            }
                        }
                        HStack{
                            Text("血液型")
                                .bold()
                            Spacer()
                            Picker("", selection: $bloodType) {
                                Text("不明").tag("不明")
                                Text("A").tag("A")
                                Text("B").tag("B")
                                Text("O").tag("O")
                                Text("AB").tag("AB")
                            }
                            .pickerStyle(MenuPickerStyle())
                            .frame(width: 100)
                            .tint(.black)
                        }
                        HStack{
                            Text("誕生日")
                                .bold()
                            Spacer()
                            DatePicker("", selection: $birthday, displayedComponents: .date)
                                .environment(\.locale, Locale(identifier: "ja_JP"))
                        }
                    }
                    
                    Section(header: Text("その他の情報")) {
                        HStack{
                            Text("関係性")
                                .bold()
                            Spacer()
                            TextField("会社の上司", text: $relationship)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("趣味")
                                .bold()
                            Spacer()
                            TextField("釣り", text: $hobby)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("好きなもの")
                                .bold()
                            Spacer()
                            TextField("会社終わりの飲み会", text: $likes)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("嫌いなもの")
                                .bold()
                            Spacer()
                            TextField("敬語を使わない人", text: $dislikes)
                                .multilineTextAlignment(.trailing)
                        }
                        HStack{
                            Text("共通の知人")
                                .bold()
                            Spacer()
                            TextField("同僚の鈴木", text: $mutualAcquaintances)
                                .multilineTextAlignment(.trailing)
                        }
                    }
                    
                    Section(header: Text("喜怒哀楽")) {
                                    HStack{
                                        Text("喜")
                                            .bold()
                                        Spacer()
                                        TextField("仕事の成果を褒められたとき", text: $joy)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack{
                                        Text("怒")
                                            .bold()
                                        Spacer()
                                        TextField("部下が同じミスを繰り返すとき", text: $anger)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack{
                                        Text("哀")
                                            .bold()
                                        Spacer()
                                        TextField("年齢が高くみられたとき", text: $sorrow)
                                            .multilineTextAlignment(.trailing)
                                    }
                                    HStack{
                                        Text("楽")
                                            .bold()
                                        Spacer()
                                        TextField("週末は機嫌が良くなる", text: $pleasure)
                                            .multilineTextAlignment(.trailing)
                                    }
                                }
                    }
                .navigationBarTitle("ユーザー登録", displayMode: .inline)
                .listStyle(.grouped)
                .scrollContentBackground(.hidden)
                .background(Color.blue)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("戻る") {
                            self.presentationMode.wrappedValue.dismiss()
                        }
                        .foregroundColor(.black)
                    }
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("登録") {
                            guard let userId = self.authManager.user?.uid else {
                                print("ユーザーIDが取得できませんでした")
                                return
                            }
                            
                            let ref = Database.database().reference().child("persons")
                            let birthdayString = dateFormatter.string(from: self.birthday) // 誕生日を文字列に変換

                            let personData: [String: Any] = [
                                "userId": userId,
                                "name": self.name,
                                "age": Int(self.age) ?? 0,
                                "bloodType": self.bloodType,
                                "birthday": birthdayString,
                                "relationship": self.relationship,
                                "hobby": self.hobby,
                                "likes": self.likes,
                                "dislikes": self.dislikes,
                                "mutualAcquaintances": self.mutualAcquaintances,
                                "icon": self.selectedIcon,
                                "joy": self.joy,
                                "anger": self.anger,
                                "sorrow": self.sorrow,
                                "pleasure": self.pleasure
                            ]
                            ref.childByAutoId().setValue(personData) { (error, ref) in
                                if let error = error {
                                    print("データの保存に失敗しました: \(error.localizedDescription)")
                                } else {
                                    print("データの保存に成功しました")
                                    self.presentationMode.wrappedValue.dismiss() // ここでビューを閉じる
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .sheet(isPresented: $showingIconPicker) {
//            IconPickerView(selectedIcon: $selectedIcon, showingIconPicker: $showingIconPicker)
        }
    }
}

struct PersonRegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        PersonRegistrationView()
    }
}
