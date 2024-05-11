
import SwiftUI
import Firebase
import UserNotifications
import Firebase


@main
struct pushQuizApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appDelegate.navigationManager)
        }
    }
}

class NavigationManager: ObservableObject {
    @Published var currentView: AnyView = AnyView(TopView())

    func navigateToView(_ view: AnyView) {
        DispatchQueue.main.async {
            self.currentView = AnyView(view.id(UUID()))
        }
    }

    // 特定のタブを選択してTopViewを表示するための新しいメソッド
    func navigateToQuizTopView() {
        navigateToView(AnyView(TopView()))
    }
}


class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    let navigationManager = NavigationManager()
    var quizManager = QuizManager()
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // 通知の設定
        let center = UNUserNotificationCenter.current()
        center.delegate = self  // 通知デリゲートを設定
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            if granted {
                print("Notification permission granted.")
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
        let userDefaults = UserDefaults.standard
        let authManager = AuthManager()
        if !userDefaults.bool(forKey: "hasLaunchedBefore") {
            authManager.anonymousSignIn(){
                DispatchQueue.main.async {
                    authManager.createUser() {
                        DispatchQueue.main.async {
                            self.quizManager.createSampleData()
                        }
                    }
                }
            }
            userDefaults.set(true, forKey: "hasLaunchedBefore")
            userDefaults.synchronize()
        }
        
        return true
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                         fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("Received in application(_:didReceiveRemoteNotification:): \(userInfo)")
        handleNotification(userInfo)
        completionHandler(.newData)
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("Received in userNotificationCenter(_:didReceive:): \(userInfo)")
        handleNotification(userInfo)
        completionHandler()
    }

    private func handleNotification(_ userInfo: [AnyHashable: Any]) {
        print("userInfo:\(userInfo)")
        if let destination = userInfo["destination"] as? String {
            print("destination:\(destination)")
            switch destination {
            case "quizTop":
                navigationManager.navigateToView(AnyView(QuizNotificationTopView()))
            default:
                navigationManager.navigateToView(AnyView(TopView()))
            }
        }
    }
}

// ContentView.swift
struct ContentView: View {
    @EnvironmentObject var navigationManager: NavigationManager

    var body: some View {
        navigationManager.currentView
    }
}
