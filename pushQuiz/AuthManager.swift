//
//  AuthManager.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/11.
//

import SwiftUI
import Firebase

class AuthManager: ObservableObject {
    @Published var user: FirebaseAuth.User?
    @Published var rewardPoint: Int = 0
    @Published var dateRangeText: String = ""
    var onLoginCompleted: (() -> Void)?
    
    init() {
        user = Auth.auth().currentUser
//        if user == nil {
////            anonymousSignIn(){}
//        }
    }
    
    var currentUserId: String? {
        print("user?.uid:\(user?.uid)")
        return user?.uid
    }
    
    func anonymousSignIn(completion: @escaping () -> Void) {
        print("anonymousSignIn")
        Auth.auth().signInAnonymously { result, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
            } else if let result = result {
                print("Signed in anonymously with user ID: \(result.user.uid)")
                self.user = result.user
                self.onLoginCompleted?()
            }
            completion()
        }
    }
    
    func updateUserFlag(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateUserFlag2(userId: String, userFlag: Int, completion: @escaping (Bool) -> Void) {
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["userFlag2": userFlag]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func fetchUserFlag(completion: @escaping (Int?, Error?) -> Void) {
        guard let userId = user?.uid else {
            // ユーザーIDがnilの場合、すなわちログインしていない場合
            let error = NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ログインしていません。"])
            completion(nil, error)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        // "userFlag"の値を取得する
        userRef.child("userFlag").observeSingleEvent(of: .value) { snapshot in
            if let userFlag = snapshot.value as? Int {
                // userFlagが存在し、Int型として取得できた場合
                DispatchQueue.main.async {
                    completion(userFlag, nil)
                }
            } else {
                // userFlagが存在しない、または想定外の形式である場合
                let error = NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "userFlagを取得できませんでした。"])
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        } withCancel: { error in
            // データベースの読み取りに失敗した場合
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
    func fetchUserFlag2(completion: @escaping (Int?, Error?) -> Void) {
        guard let userId = user?.uid else {
            // ユーザーIDがnilの場合、すなわちログインしていない場合
            let error = NSError(domain: "AuthManager", code: 0, userInfo: [NSLocalizedDescriptionKey: "ログインしていません。"])
            completion(nil, error)
            return
        }

        let userRef = Database.database().reference().child("users").child(userId)
        // "userFlag"の値を取得する
        userRef.child("userFlag2").observeSingleEvent(of: .value) { snapshot in
            if let userFlag = snapshot.value as? Int {
                // userFlagが存在し、Int型として取得できた場合
                DispatchQueue.main.async {
                    completion(userFlag, nil)
                }
            } else {
                // userFlagが存在しない、または想定外の形式である場合
                let error = NSError(domain: "AuthManager", code: 1, userInfo: [NSLocalizedDescriptionKey: "userFlagを取得できませんでした。"])
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        } withCancel: { error in
            // データベースの読み取りに失敗した場合
            DispatchQueue.main.async {
                completion(nil, error)
            }
        }
    }
    
    func updateTutorialNum(userId: String, tutorialNum: Int, completion: @escaping (Bool) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        let updates = ["tutorialNum": tutorialNum]
        userRef.updateChildValues(updates) { (error, _) in
            if let error = error {
                print("Error updating tutorialNum: \(error)")
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateContact(userId: String, newContact: String, completion: @escaping (Bool) -> Void) {
        // contactテーブルの下の指定されたuserIdの参照を取得
        let contactRef = Database.database().reference().child("contacts").child(userId)
        // まず現在のcontactの値を読み取る
        contactRef.observeSingleEvent(of: .value, with: { snapshot in
            // 既存の問い合わせ内容を保持する変数を準備
            var contacts: [String] = []
            
            // 現在の問い合わせ内容がある場合、それを読み込む
            if let currentContacts = snapshot.value as? [String] {
                contacts = currentContacts
            }
            
            // 新しい問い合わせ内容をリストに追加
            contacts.append(newContact)
            
            // データベースを更新する
            contactRef.setValue(contacts, withCompletionBlock: { error, _ in
                if let error = error {
                    print("Error updating contact: \(error)")
                    completion(false)
                } else {
                    completion(true)
                }
            })
        }) { error in
            print(error.localizedDescription)
            completion(false)
        }
    }
    
    func deleteUserAccount(completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        let userRef = Database.database().reference().child("users").child(userId)
        userRef.removeValue { error, _ in
            if let error = error {
                completion(false, error)
                return
            }
            completion(true, nil)
        }
    }
        
    func createUser(completion: @escaping () -> Void) {
        guard let userId = user?.uid else {
            print("ユーザーがログインしていません")
            completion() // 早期リターン時にもコールバックを呼ぶ
            return
        }
        print("createUser")
        print("createUser userId:\(userId)")
        let userRef = Database.database().reference().child("users").child(userId)

        userRef.setValue(["tutorialNum": 1, "userFlag": 0, "userFlag2": 0]) { error, _ in
            DispatchQueue.main.async {
                if let error = error {
                    print("ユーザー作成時にエラーが発生しました: \(error.localizedDescription)")
                } else {
                    print("新しいユーザーが作成されました。")
                }
                completion() // エラーの有無にかかわらず、処理完了後にコールバックを実行
            }
        }
    }
}

struct AuthManager1: View {
    @ObservedObject var authManager = AuthManager()

    var body: some View {
        VStack {
            if authManager.user == nil {
                Text("Not logged in")
            } else {
                Text("Logged in with user ID: \(authManager.user!.uid)")
            }
            Button(action: {
                if self.authManager.user == nil {
                    self.authManager.anonymousSignIn(){}
                }
            }) {
                Text("Log in anonymously")
            }
        }
    }
}

struct AuthManager_Previews: PreviewProvider {
    static var previews: some View {
        AuthManager1()
    }
}
