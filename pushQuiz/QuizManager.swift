//
//  QuizManager.swift
//  pushQuiz
//
//  Created by Apple on 2024/04/11.
//

import SwiftUI
import Firebase

struct Quiz: Identifiable {
    var id: String
    var question: String
    var optionA: String
    var optionB: String
    var optionC: String
    var optionD: String
    var answer: String
    var flag: Bool
    var notificationInterval: Int?
    var correct: Int
    var incorrect: Int
}

class QuizManager: ObservableObject {
    private var databaseRef: DatabaseReference!
    @Published var quizzes = [Quiz]()
    @Published var trueQuiz = [Quiz]()
    @Published var correct: Int = 0
    @Published var incorrect: Int = 0
    @Published var notificationInterval: Int = 0
    
    init() {
        databaseRef = Database.database().reference()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ" // ISO 8601形式、Firebaseに保存されている形式に応じて調整
        return formatter
    }()
    
    func fetchFlaggedQuizzes() {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        databaseRef.child("quizzes").child(userId).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                print("データが存在しません fetchFlaggedQuizzes")
                return
            }
            print("fetchFlaggedQuizzes")
            var newQuizzes = [Quiz]()
            for childSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let quizId = childSnapshot.key
                if let quizDict = childSnapshot.value as? [String: Any],
                   let question = quizDict["question"] as? String,
                   let options = quizDict["options"] as? [String: String],
                   let optionA = options["a"],
                   let optionB = options["b"],
                   let optionC = options["c"],
                   let optionD = options["d"],
                   let flag = quizDict["flag"] as? Bool,
                   let answer = quizDict["answer"] as? String,
                   let notificationInterval = quizDict["notificationInterval"] as? Int,
                   let correct = quizDict["correct"] as? Int,
                   let incorrect = quizDict["incorrect"] as? Int,
                   flag { // flagがtrueの場合のみ処理する
                    
                     self.correct = correct
                     self.incorrect = incorrect
                     self.notificationInterval = notificationInterval
                    let quiz = Quiz(id: quizId, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: notificationInterval,correct: correct, incorrect: incorrect)
                    newQuizzes.append(quiz)
                }
            }

            self.trueQuiz = newQuizzes
        })
    }
    
    func updateQuiz(quiz: Quiz) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        // クイズデータを辞書形式で準備
        let quizData: [String: Any] = [
            "question": quiz.question,
            "options": [
                "a": quiz.optionA,
                "b": quiz.optionB,
                "c": quiz.optionC,
                "d": quiz.optionD
            ],
            "answer": quiz.answer,
            "flag": quiz.flag,
            "notificationInterval": quiz.notificationInterval ?? 0, // nilの場合は0を設定
            "correct": quiz.correct,
            "incorrect": quiz.incorrect
        ]
        // Firebaseの該当するクイズIDのパスにデータを更新
        databaseRef.child("quizzes").child(userId).child(quiz.id).updateChildValues(quizData) { error, _ in
            if let error = error {
                print("クイズの更新に失敗しました: \(error.localizedDescription)")
            } else {
                print("クイズが更新されました。")
            }
        }
    }
    
    func fetchQuizzes(completion: @escaping () -> Void) {
           guard let userId = Auth.auth().currentUser?.uid else {
               print("ユーザーがログインしていません")
               return
           }

           databaseRef.child("quizzes").child(userId).observeSingleEvent(of: .value, with: { snapshot in
//               if !snapshot.exists() {
//                   print("データが存在しません fetchQuizzes")
//                   return
//               }
               print("fetchQuizzes1")
               var newQuizzes = [Quiz]()
               for childSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                   let quizId = childSnapshot.key
                   if let quizDict = childSnapshot.value as? [String: Any],
                      let question = quizDict["question"] as? String,
                      let options = quizDict["options"] as? [String: String],
                      let optionA = options["a"],
                      let optionB = options["b"],
                      let optionC = options["c"],
                      let optionD = options["d"],
                      let flag = quizDict["flag"] as? Bool,
                      let answer = quizDict["answer"] as? String,
                      let notificationInterval = quizDict["notificationInterval"] as? Int,
                      let correct = quizDict["correct"] as? Int,
                      let incorrect = quizDict["incorrect"] as? Int{
                       let quiz = Quiz(id: quizId, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: notificationInterval,correct: correct, incorrect: incorrect)
                       newQuizzes.append(quiz)
                   } else {
                       print("データ変換に失敗しました。")
                   }
               }

               self.quizzes = newQuizzes
               completion()  // データの解析が終わった後にコールバックを呼び出す
           })
       }
    
    func createSampleData() {
        guard let userId = Auth.auth().currentUser?.uid,
              !userId.isEmpty,
              !userId.contains("."), !userId.contains("#"),
              !userId.contains("$"), !userId.contains("["),
              !userId.contains("]") else {
            print("エラー: userIdが無効です。")
            return
        }

        let sampleQuizData: [String: Any] = [
            "answer": "チョコケーキ",
            "correct": 0,
            "flag": true,
            "incorrect": 0,
            "notificationInterval": 5,
            "options": [
                "a": "チョコケーキ",
                "b": "お寿司",
                "c": "ラーメン",
                "d": "クロワッサン"
            ],
            "question": "奥さんの好きな食べ物は？"
        ]
        
        databaseRef.child("quizzes").child(userId).childByAutoId().setValue(sampleQuizData) { error, _ in
            if let error = error {
                print("サンプルデータの保存に失敗しました: \(error.localizedDescription)")
            } else {
                print("サンプルデータを保存しました。")
            }
        }
    }
    
    func openAppSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString), UIApplication.shared.canOpenURL(url) else {
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    func deleteQuiz(quizId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        // Firebaseから指定されたクイズIDを削除
        databaseRef.child("quizzes").child(userId).child(quizId).removeValue { error, _ in
            if let error = error {
                print("クイズの削除に失敗しました: \(error.localizedDescription)")
            } else {
                print("クイズが削除されました。")
                // 内部のクイズリストからも削除
                DispatchQueue.main.async {
                    self.quizzes.removeAll { $0.id == quizId }
                }
            }
        }
    }
    
    func updateQuizzesWithFlagAndInterval(quizId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        // ユーザーのクイズデータにアクセス
        databaseRef.child("quizzes").child(userId).child(quizId).observeSingleEvent(of: .value, with: { snapshot in
            if !snapshot.exists() {
                print("データが存在しません")
                return
            }
            var updatedCount = 0
            if let quizDict = snapshot.value as? [String: Any], // snapshotの値を直接取得
               let flagValue = quizDict["flag"] as? Int,
               let notificationInterval = quizDict["notificationInterval"] as? Int {
                let flag = (flagValue == 1) // フラグが1ならtrueと解釈
                if flag && notificationInterval > 0 { // フラグがtrueかつnotificationIntervalが0より大きい場合のみ更新
                    print("updateQuizzesWithFlagAndInterval2")
                    var updatedQuizData = quizDict
                    updatedQuizData["notificationInterval"] = 0 // 通知間隔を0に更新
                    print("updateQuizzesWithFlagAndInterval quizId:\(quizId)")
                    // 更新したデータをFirebaseに保存
                    self.databaseRef.child("quizzes").child(userId).child(quizId).updateChildValues(updatedQuizData) { error, _ in
                        if let error = error {
                            print("クイズの更新に失敗しました: \(error.localizedDescription)")
                        } else {
                            updatedCount += 1
                            print("クイズ\(quizId)が更新されました")
                        }
                    }
                }
            }
            print("\(updatedCount)個のクイズが更新されました")
        })
    }




    
    func saveQuiz(quiz: Quiz) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        // 全てのクイズデータを取得
        databaseRef.child("quizzes").child(userId).observeSingleEvent(of: .value, with: { [weak self] snapshot in
//            if !snapshot.exists() {
//                print("データが存在しません")
//                return
//            }
            
            var newQuizzes = [Quiz]()
            for childSnapshot in snapshot.children.allObjects as! [DataSnapshot] {
                let quizId = childSnapshot.key
                if let quizDict = childSnapshot.value as? [String: Any],
                   let question = quizDict["question"] as? String,
                   let options = quizDict["options"] as? [String: String],
                   let optionA = options["a"],
                   let optionB = options["b"],
                   let optionC = options["c"],
                   let optionD = options["d"],
                   let flag = quizDict["flag"] as? Bool,
                   let answer = quizDict["answer"] as? String,
                   let notificationInterval = quizDict["notificationInterval"] as? Int,
                   let correct = quizDict["correct"] as? Int,
                   let incorrect = quizDict["incorrect"] as? Int {

                    let fetchedQuiz = Quiz(id: quizId, question: question, optionA: optionA, optionB: optionB, optionC: optionC, optionD: optionD, answer: answer, flag: flag, notificationInterval: notificationInterval, correct: correct, incorrect: incorrect)
                    newQuizzes.append(fetchedQuiz)
                }
            }

            self?.quizzes = newQuizzes

            // 全クイズのフラグをfalseに設定（現在保存しようとしているクイズを除く）
            for var existingQuiz in newQuizzes {
                if existingQuiz.id != quiz.id {
                    self?.updateQuizFlag(quizId: existingQuiz.id, flag: false)
                }
            }

            // 新しいクイズデータを辞書形式で準備してFirebaseに保存
            let quizData: [String: Any] = [
                "question": quiz.question,
                "options": [
                    "a": quiz.optionA,
                    "b": quiz.optionB,
                    "c": quiz.optionC,
                    "d": quiz.optionD
                ],
                "answer": quiz.answer,
                "flag": quiz.flag,
                "notificationInterval": quiz.notificationInterval,
                "correct": quiz.correct,
                "incorrect": quiz.incorrect
            ]
            
            self?.databaseRef.child("quizzes").child(userId).child(quiz.id).setValue(quizData, withCompletionBlock: { error, _ in
                if let error = error {
                    print("クイズの保存に失敗しました: \(error.localizedDescription)")
                } else {
                    print("クイズを保存しました。")
                }
            })
        })
    }
    
    func incrementCorrectCount(quizId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        let quizRef = databaseRef.child("quizzes").child(userId).child(quizId).child("correct")
        quizRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int ?? 0
            value += 1
            currentData.value = value
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, _ in
            if let error = error {
                print("正解数のインクリメントに失敗しました: \(error.localizedDescription)")
            } else if committed {
                print("正解数を更新しました。")
            }
        }
    }
    
    func incrementIncorrectCount(quizId: String) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }

        let quizRef = databaseRef.child("quizzes").child(userId).child(quizId).child("incorrect")
        quizRef.runTransactionBlock({ (currentData: MutableData) -> TransactionResult in
            var value = currentData.value as? Int ?? 0
            value += 1
            currentData.value = value
            return TransactionResult.success(withValue: currentData)
        }) { error, committed, _ in
            if let error = error {
                print("不正解数のインクリメントに失敗しました: \(error.localizedDescription)")
            } else if committed {
                print("不正解数を更新しました。")
            }
        }
    }
    
    func updateQuizFlag(quizId: String, flag: Bool) {
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        databaseRef.child("quizzes").child(userId).child(quizId).updateChildValues(["flag": flag])
    }

    func toggleFlag(for quizId: String) {
        
        guard let userId = Auth.auth().currentUser?.uid else {
            print("ユーザーがログインしていません")
            return
        }
        
        // 全クイズを取得して、選択されたクイズのflagを更新
        let updates = quizzes.map { quiz -> (String, [String: Any]) in
            var updatedQuiz = quiz
            if quiz.id == quizId {
                updatedQuiz.flag = !quiz.flag // flagをトグル
                let options = [quiz.optionA, quiz.optionB, quiz.optionC, quiz.optionD]
                if quiz.notificationInterval != 0 {
                    let timeIntervalInSeconds = Double(quiz.notificationInterval! * 60)
                    scheduleCustomNotification(date: Date(), quizQuestion: quiz.question, options: options, timeInterval: timeIntervalInSeconds)
                } else {
                    cancelAllNotifications()
                }
            } else if quiz.flag {
                updatedQuiz.flag = false // 他のflagがtrueのクイズをfalseに
            }
            return (updatedQuiz.id, ["flag": updatedQuiz.flag])
        }

        // Firebaseに更新
        for (id, data) in updates {
            databaseRef.child("quizzes").child(userId).child(id).updateChildValues(data)
        }
    }
    
//    func scheduleCustomNotification(date: Date, quizQuestion: String, options: [String], timeInterval: TimeInterval) {
//        cancelAllNotifications()
//        let content = UNMutableNotificationContent()
//        content.title = quizQuestion
//        let optionsText = options.enumerated().map { index, option in
//            return "\(index + 1). \(option)"
//        }.joined(separator: "\n")
//        content.body = optionsText
//        content.userInfo = ["destination": "quizTop"]
//
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
//        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
//
//        UNUserNotificationCenter.current().add(request) { error in
//            if let error = error {
//                print("Error scheduling notification: \(error)")
//            } else {
//                print("通知がカスタム日時に設定されました：\(date), 次の通知までの時間: \(timeInterval)秒")
//            }
//        }
//    }
    
    func scheduleCustomNotification(date: Date, quizQuestion: String, options: [String], timeInterval: TimeInterval) {
        cancelAllNotifications()
        let content = UNMutableNotificationContent()
        content.title = quizQuestion
        content.sound = UNNotificationSound.default
        
        let optionsText = options.enumerated().map { index, option in
            return "\(index + 1). \(option)"
        }.joined(separator: "\n")
        content.body = optionsText
        content.userInfo = ["destination": "quizTop"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("通知がカスタム日時に設定されました：\(date), 次の通知までの時間: \(timeInterval)秒")
            }
        }
    }
    
    func scheduleCustomNotificationOnlyQuetion(date: Date, quizQuestion: String, options: [String], timeInterval: TimeInterval) {
        cancelAllNotifications()
        let content = UNMutableNotificationContent()
        content.title = "問題です！"
        content.sound = UNNotificationSound.default
//        let optionsText = options.enumerated().map { index, option in
//            return "\(index + 1). \(option)"
//        }.joined(separator: "\n")
        content.body = quizQuestion
        content.userInfo = ["destination": "quizTop"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("通知がカスタム日時に設定されました：\(date), 次の通知までの時間: \(timeInterval)秒")
            }
        }
    }
    
    func scheduleCustomNotificationAllNothing(date: Date, quizQuestion: String, options: [String], timeInterval: TimeInterval) {
        cancelAllNotifications()
        let content = UNMutableNotificationContent()
        content.title = "問題です！"
        content.sound = UNNotificationSound.default
//        let optionsText = options.enumerated().map { index, option in
//            return "\(index + 1). \(option)"
//        }.joined(separator: "\n")
        content.body = "通知を開いて問題を解きましょう！"
        content.userInfo = ["destination": "quizTop"]

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            } else {
                print("通知がカスタム日時に設定されました：\(date), 次の通知までの時間: \(timeInterval)秒")
            }
        }
    }
    
    func listAllScheduledNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            for request in requests {
                print("Notification ID: \(request.identifier)")
                print("Title: \(request.content.title)")
                print("Body: \(request.content.body)")
                if let trigger = request.trigger as? UNTimeIntervalNotificationTrigger {
                    print("Next trigger in: \(trigger.timeInterval) seconds")
                }
            }
            
            if requests.isEmpty {
                print("現在保留中の通知はありません。")
            }
        }
    }
    
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests() // 保留中の通知を全て削除
        print("全ての通知がキャンセルされました。")
    }
}
