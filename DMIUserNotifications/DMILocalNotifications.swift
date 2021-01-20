//
//  DLLocalNotifications.swift
//  DLLocalNotifications
//
//  Created by Kamlesh on 19/01/21.
//

import Foundation
import UserNotifications

let MAX_ALLOWED_NOTIFICATIONS = 64

@available(iOS 10.0, *)
 public class DMINotificationScheduler {
    
    // Apple allows you to only schedule 64 notifications at a time
    static let maximumScheduledNotifications = 60
    
   public init () {}
    
  public func cancelAlllNotifications () {
        
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        DMIQueue.queue.clear()
    }
    
    
    // Returns all notifications in the notifications queue.
  public func notificationsQueue() -> [DMINotification] {
        return DMIQueue.queue.notificationsQueue()
    }
    

    
    // Cancel the notification if scheduled or queued
  public func cancelNotification (notification: DMINotification) {
        
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [(notification.localNotificationRequest?.identifier)!])
        let queue = DMIQueue.queue.notificationsQueue()
        var i = 0
        for noti in queue {
            if notification.identifier == noti.identifier {
                DMIQueue.queue.removeAtIndex(i)
                break
            }
            i += 1
        }
        notification.scheduled = false
    }
    
  public func getScheduledNotifications(handler:@escaping (_ request:[UNNotificationRequest]?)-> Void) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
             handler(requests)
        })
        
    }
    
    
    
  public func getScheduledNotification(with identifier: String, handler:@escaping (_ request:UNNotificationRequest?)-> Void) {
        
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
           
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    if (request.identifier == identifier) {
                         print("Timer interval notificaiton: \(request1.nextTriggerDate().debugDescription)")
                        handler(request)
                    }
                    break
                   
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    if (request.identifier == identifier) {
                        handler(request)
                        if(request2.repeats) {
                            print(request)
                            print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                        } else {
                            print("Calendar notification: \(request2.nextTriggerDate().debugDescription) does not repeat")
                        }
                        break
                    }
                    
                }
                if let request3 = request.trigger as? UNLocationNotificationTrigger {
                    
                    print("Location notification: \(request3.region.debugDescription)")
                }
            }
        })
    
    }
    
  public func printAllNotifications () {
        
        print("printing all notifications")
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
            print(requests.count)
            for request  in  requests {
                if let request1 =  request.trigger as?  UNTimeIntervalNotificationTrigger {
                    print("Timer interval notificaiton: \(request1.nextTriggerDate().debugDescription)")
                }
                if let request2 =  request.trigger as?  UNCalendarNotificationTrigger {
                    if(request2.repeats) {
                        print(request)
                        print("Calendar notification: \(request2.nextTriggerDate().debugDescription) and repeats")
                    } else {
                        print("Calendar notification: \(request2.nextTriggerDate().debugDescription) does not repeat")
                    }
                }
                if let request3 = request.trigger as? UNLocationNotificationTrigger {
                    
                    print("Location notification: \(request3.region.debugDescription)")
                }
            }
        })
    }
    
    private func convertToNotificationDateComponent (notification: DMINotification, repeatInterval: RepeatingInterval   ) -> DateComponents {
        
        var newComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second ], from: notification.fireDate!)
        
        if repeatInterval != .none {
            
            switch repeatInterval {
            case .minute:
                newComponents = Calendar.current.dateComponents([ .second], from: notification.fireDate!)
            case .hourly:
                newComponents = Calendar.current.dateComponents([ .minute], from: notification.fireDate!)
            case .daily:
                newComponents = Calendar.current.dateComponents([.hour, .minute], from: notification.fireDate!)
            case .weekly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .weekday], from: notification.fireDate!)
            case .monthly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day], from: notification.fireDate!)
            case .yearly:
                newComponents = Calendar.current.dateComponents([.hour, .minute, .day, .month], from: notification.fireDate!)
            default:
                break
            }
        }
        
        return newComponents
    }
    
    fileprivate func queueNotification (notification: DMINotification) -> String? {
        
        if notification.scheduled {
            return nil
        } else {
            DMIQueue.queue.push(notification)
        }
        
        return notification.identifier
    }
    
  public func scheduleNotification ( notification: DMINotification) {
        
        queueNotification(notification: notification)
        
    }
    
    
  public func scheduleAllNotifications () {
        
        let queue = DMIQueue.queue.notificationsQueue()
        
        var count = 0
        for _ in queue {
            
            if count < min(DMINotificationScheduler.maximumScheduledNotifications, MAX_ALLOWED_NOTIFICATIONS) {
                let popped = DMIQueue.queue.pop()
                let _ = scheduleNotificationInternal(notification: popped)
                count += 1
            } else { break }
            
        }
    }
    
    // Refactored for backwards compatability
    fileprivate func scheduleNotificationInternal ( notification: DMINotification) -> String? {
        
        if notification.scheduled {
            return nil
        } else {
            
            var trigger: UNNotificationTrigger
            
            if (notification.region != nil) {
                trigger = UNLocationNotificationTrigger(region: notification.region!, repeats: false)
                if (notification.repeatInterval == .hourly) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(3600)), repeats: notification.repeats)
                    
                }
                
            } else {
                
                trigger = UNCalendarNotificationTrigger(dateMatching: convertToNotificationDateComponent(notification: notification, repeatInterval: notification.repeatInterval), repeats: notification.repeats)
                
                if (notification.repeatInterval == .minute) {
                    trigger = UNTimeIntervalNotificationTrigger.init(timeInterval: (TimeInterval(60)), repeats: notification.repeats)
                    
                }
 
            }
            let content = UNMutableNotificationContent()
            
            content.title = notification.alertTitle!
            
            content.body = notification.alertBody!
            
            content.sound = notification.soundName == "" ? UNNotificationSound.default : UNNotificationSound.init(named: UNNotificationSoundName(rawValue: notification.soundName))

            
            if (notification.soundName == "1") { content.sound = nil}
            
            if !(notification.attachments == nil) { content.attachments = notification.attachments! }
            
            if !(notification.launchImageName == nil) { content.launchImageName = notification.launchImageName! }
            
            if !(notification.category == nil) { content.categoryIdentifier = notification.category! }
            
            notification.localNotificationRequest = UNNotificationRequest(identifier: notification.identifier!, content: content, trigger: trigger)
            
            let center = UNUserNotificationCenter.current()
          center.requestAuthorization(options: [.alert,.sound]) {(accepted, error) in
                  if !accepted {
                      print("Notification access denied")
                  }
              }
          center.add(notification.localNotificationRequest!, withCompletionHandler: {(error) in
                if error != nil {
                    print(error.debugDescription)
                }
            })
            
            notification.scheduled = true
        }
        
        return notification.identifier
        
    }
    
    ///Persists the notifications queue to the disk
    ///> Call this method whenever you need to save changes done to the queue and/or before terminating the app.
  public func saveQueue() -> Bool {
        return DMIQueue.queue.save()
    }
    ///- returns: Count of scheduled notifications by iOS.
    func scheduledCount(completion: @escaping (Int) -> Void) {
        UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (localNotifications) in
            completion(localNotifications.count)
        })
        
    }
    
    // You have to manually keep in mind ios 64 notification limit
    
  public func repeatsFromToDate (identifier: String, alertTitle: String, alertBody: String, fromDate: Date, toDate: Date, interval: Double, repeats: RepeatingInterval, category: String = " ", sound: String = " ") {
        
        let notification = DMINotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: fromDate, repeats: repeats)
        notification.category = category
        notification.soundName = sound
        // Create multiple Notifications
        
        self.queueNotification(notification: notification)
        let intervalDifference = Int( toDate.timeIntervalSince(fromDate) / interval )
        
        var nextDate = fromDate
        
        for i in 0..<intervalDifference {
            
            // Next notification Date
            
            nextDate = nextDate.addingTimeInterval(interval)
            let identifier = identifier + String(i + 1)
            
            let notification = DMINotification(identifier: identifier, alertTitle: alertTitle, alertBody: alertBody, date: nextDate, repeats: repeats)
            notification.category = category
            notification.soundName = sound
           let identify = self.queueNotification(notification: notification)
        }
        
    }
    
  public func scheduleCategories(categories: [DMICategory]) {
        
        var notificationCategories = Set<UNNotificationCategory>()
        
        for category in categories {
            
            guard let categoryInstance = category.categoryInstance else { continue }
            notificationCategories.insert(categoryInstance)
            
        }
        
        UNUserNotificationCenter.current().setNotificationCategories(notificationCategories)
        
    }
    
}

// Repeating Interval Times

 public enum RepeatingInterval: String {
    case none, minute, hourly, daily, weekly, monthly, yearly
}

extension Date {

func removeSeconds() -> Date {
    let calendar = Calendar.current
    let components = (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute], from: self)
    return calendar.date(from: components)!
}
}


