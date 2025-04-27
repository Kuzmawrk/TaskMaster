import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
   func application(
       _ application: UIApplication,
       didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
   ) -> Bool {
       configureNotifications(application)
       AppRatingManager.shared.incrementLaunchCount()
       return true
   }
   
   private func configureNotifications(_ application: UIApplication) {
       UNUserNotificationCenter.current().delegate = self
       
       let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
       UNUserNotificationCenter.current().requestAuthorization(
           options: authOptions,
           completionHandler: { _, _ in }
       )
   }
   
   func application(_ application: UIApplication,
                   didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
   }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
   func userNotificationCenter(
       _ center: UNUserNotificationCenter,
       willPresent notification: UNNotification,
       withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
   ) {
       completionHandler([[.banner, .sound]])
   }
   
   func userNotificationCenter(
       _ center: UNUserNotificationCenter,
       didReceive response: UNNotificationResponse,
       withCompletionHandler completionHandler: @escaping () -> Void
   ) {
       completionHandler()
   }
}
