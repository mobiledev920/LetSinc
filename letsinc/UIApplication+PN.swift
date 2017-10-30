//
//  UIApplication+PN.swift
//  UpWatch
//
//  Created by Mateo Kozomara on 14/11/2016.
//  Copyright © 2016 Mateo Kozomara. All rights reserved.
//

import Foundation
import UIKit

extension UIApplication {
    func remoteNotificationsEnabled() -> Bool {
        var notificationsEnabled = false
        if let userNotificationSettings = currentUserNotificationSettings {
            notificationsEnabled = userNotificationSettings.types.contains(.alert)
        }
        return notificationsEnabled
    }
}
