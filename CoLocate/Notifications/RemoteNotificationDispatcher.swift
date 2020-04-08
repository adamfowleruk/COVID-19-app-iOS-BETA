//
//  RemoteNotificationDispatcher.swift
//  CoLocate
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

import Logging

protocol UserNotificationCenter: class {
    var delegate: UNUserNotificationCenterDelegate? { get set }

    func requestAuthorization(
        options: UNAuthorizationOptions,
        completionHandler: @escaping (Bool, Error?) -> Void
    )

    func add(
        _ request: UNNotificationRequest,
        withCompletionHandler completionHandler: ((Error?) -> Void)?
    )
}

extension UNUserNotificationCenter: UserNotificationCenter {
}


class RemoteNotificationDispatcher {
    static let shared = RemoteNotificationDispatcher()
    
    var pushToken: String?
    
    private var handlers = HandlerDictionary()
    private let notificationCenter: NotificationCenter
    private let userNotificationCenter: UserNotificationCenter
    private let persistence: Persisting
    
    init(notificationCenter: NotificationCenter, userNotificationCenter: UserNotificationCenter, persistence: Persisting) {
        self.notificationCenter = notificationCenter
        self.userNotificationCenter = userNotificationCenter
        self.persistence = persistence
    }
    
    convenience init() {
        self.init(
            notificationCenter: NotificationCenter.default,
            userNotificationCenter: UNUserNotificationCenter.current(),
            persistence: Persistence.shared
        )
    }

    func registerHandler(forType type: RemoteNotificationType, handler: @escaping RemoteNotificationHandler) {
        handlers[type] = handler
    }
    
    func removeHandler(forType type: RemoteNotificationType) {
        handlers[type] = nil
    }
    
    func hasHandler(forType type: RemoteNotificationType) -> Bool {
        return handlers.hasHandler(forType: type)
    }
    
    func handleNotification(userInfo: [AnyHashable : Any], completionHandler: @escaping RemoteNotificationCompletionHandler) {
        // TODO: Move this out of the dispatcher?
        if let status = userInfo["status"] {
            handleStatusUpdated(status: status)
            return
        }
        
        guard let type = notificationType(userInfo: userInfo) else {
            logger.warning("unrecognized notification with user info: \(userInfo)")
            completionHandler(.failed)
            return
        }
        
        logger.debug("Remote notification is a \(type)")
        
        guard let handler = handlers[type] else {
            logger.warning("No registered handler for type \(type)")
            completionHandler(.failed)
            return
        }
        
        handler(userInfo, completionHandler)
    }
    
    func receiveRegistrationToken(fcmToken: String) {
        pushToken = fcmToken
        notificationCenter.post(name: PushTokenReceivedNotification, object: fcmToken, userInfo: nil)
    }
    
    private func notificationType(userInfo: [AnyHashable : Any]) -> RemoteNotificationType? {
        if userInfo["activationCode"] as? String != nil {
            return .registrationActivationCode
        } else if userInfo["status"] as? String != nil {
            return .statusChange
        } else {
            return nil
        }
    }
    
    private func handleStatusUpdated(status: Any) {
        guard status as? String == "Potential" else {
            logger.warning("Received unexpected status from remote notification: '\(status)'")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "POTENTIAL_STATUS_TITLE".localized
        content.body = "POTENTIAL_STATUS_BODY".localized

        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)

        userNotificationCenter.add(request) { error in
            if error != nil {
                logger.critical("Unable to add local notification: \(String(describing: error))")
            }
        }

        persistence.diagnosis = .potential
    }
}

private class HandlerDictionary {
    private var handlers: [RemoteNotificationType : RemoteNotificationHandler] = [:]
    
    subscript(index: RemoteNotificationType) -> RemoteNotificationHandler? {
        get {
            let handler = handlers[index]
            
            if handler == nil {
                complainAboutMissingHandler(type: index)
            }
            
            return handler
        }
        set {
            if newValue != nil && handlers[index] != nil {
                complainAboutHandlerReplacement(type: index)
            }
            
            handlers[index] = newValue
        }
    }
    
    func hasHandler(forType type: RemoteNotificationType) -> Bool {
        return handlers[type] != nil
    }
    
    private func complainAboutMissingHandler(type: RemoteNotificationType) {
        #if DEBUG
        fatalError("Remote notification HandlerDictionary: no handler for notification type \(type)")
        #else
        logger.warning("Remote notification HandlerDictionary: no handler for notification type \(type)")
        #endif
    }
    
    private func complainAboutHandlerReplacement(type: RemoteNotificationType) {
        #if DEBUG
        fatalError("Remote notification HandlerDictionary: attempted to replace handler for \(type)")
        #else
        logger.warning("Remote notification HandlerDictionary replacing existing handler for \(type)")
        #endif
    }
}

private let logger = Logger(label: "Notifications")
