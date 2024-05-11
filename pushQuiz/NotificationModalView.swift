//
//  HelpModalView.swift
//  chatAi
//
//  Created by Apple on 2024/02/20.
//

import SwiftUI
import StoreKit

struct NotificationModalView: View {
    @ObservedObject var authManager = AuthManager()
    @Binding var isPresented: Bool
    @State var toggle = false
    @State private var text: String = ""
    @State private var showAlert = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .edgesIgnoringSafeArea(.all)
                .onTapGesture {
                    if toggle == true {
                        authManager.updateUserFlag2(userId: authManager.currentUserId!, userFlag: 1) { success in
                        }
                    }
                    isPresented = false
                }
            VStack(spacing: -25) {
                VStack(alignment: .center){
                    Text("アプリの機能を最大限に活かすため\n通知機能をオンにされることを推奨いたします")
                        .font(.system(size: isSmallDevice() ? 17 : 18))
                        .multilineTextAlignment(.center)
                        .padding(.vertical)
                    Image("通知")
                        .resizable()
                        .frame(width:160, height:130)
                        .padding()
                    Button(action: {
                        if toggle == true {
                            authManager.updateUserFlag2(userId: authManager.currentUserId!, userFlag: 1) { success in
                            }
                        }
                        openAppSettings()
                    }, label: {
                        Text("通知設定")
                            .fontWeight(.semibold)
                            .frame(width: 130, height:40)
                            .foregroundColor(Color.white)
                            .background(Color.gray)
                            .cornerRadius(24)
                    })
                    .shadow(radius: 3)
                    .padding(.top,10)

                    HStack{
                        Spacer()
                        Toggle("今後は表示しない", isOn: $toggle)
                            .frame(width:200)
                            .toggleStyle(SwitchToggleStyle())
                            .padding(.horizontal)
                            .padding(.top)
                    }
                }
            }
//            .alert(isPresented: $showAlert) { // アラートを表示する
//                Alert(
//                    title: Text("送信されました"),
//                    message: Text("お問い合わせありがとうございました。"),
//                    dismissButton: .default(Text("OK")) {
//                        isPresented = false
//                    }
//                )
//            }
            .frame(width: isSmallDevice() ? 290: 320)
            .foregroundColor(Color("fontGray"))
            .padding()
        .background(Color("backgroundColor"))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.gray, lineWidth: 15)
        )
        .cornerRadius(20)
        .shadow(radius: 10)
        .overlay(
            // 「×」ボタンを右上に配置
            Button(action: {
                if toggle == true {
                    authManager.updateUserFlag2(userId: authManager.currentUserId!, userFlag: 1) { success in
                    }
                }
                isPresented = false
            }) {
                Image(systemName: "xmark.circle.fill")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
                    .background(.white)
                    .cornerRadius(30)
                    .padding()
            }
                .offset(x: 35, y: -35), // この値を調整してボタンを正しい位置に移動させます
            alignment: .topTrailing // 枠の右上を基準に位置を調整します
        )
        .padding(25)
                }
//            }
        
                }
            //            .padding(50)
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
        }
//    }
    
//    func isSmallDevice() -> Bool {
//        return UIScreen.main.bounds.width < 390
//    }


#Preview {
    NotificationModalView(isPresented: .constant(true))
}
