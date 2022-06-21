//
//  NotificationService.swift
//  NotificationService
//
//  Created by QuangND on 20/06/2022.
//

import UserNotifications
import Firebase
import Intents
import IntentsUI

class NotificationService: UNNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        if let bestAttemptContent = bestAttemptContent {
            if #available(iOSApplicationExtension 15.0, *) {
                var content = UNMutableNotificationContent()
                content.title = "\(bestAttemptContent.title)"
                content.subtitle = "\(bestAttemptContent.subtitle)"
                content.body = "\(bestAttemptContent.body)"
                content.sound = UNNotificationSound.default
                
                let personHandler = INPersonHandle(value: "unique-user-id-1", type: .unknown)
                let urlImage : String = bestAttemptContent.userInfo["image-url"] as! String
                let avatar = INImage(url: URL(string: urlImage)!)
                let sender = INPerson(personHandle: personHandler,
                                      nameComponents: nil,
                                      displayName: (bestAttemptContent.title),
                                      image: avatar,
                                      contactIdentifier: nil,
                                      customIdentifier: nil)
                let intent = INSendMessageIntent(recipients: nil,
                                                 outgoingMessageType: .outgoingMessageText,
                                                 content: "\(bestAttemptContent.body)",
                                                 speakableGroupName: INSpeakableString(spokenPhrase: "Test Group"),
                                                 conversationIdentifier: "unique-conversation-id-1",
                                                 serviceName: nil,
                                                 sender: sender,
                                                 attachments: nil)
                
                let incomingMessageIntent: INSendMessageIntent = intent
                let interaction = INInteraction(intent: incomingMessageIntent, response: nil)
                interaction.direction = .incoming
                interaction.donate(completion: nil)
                do {
                    content = try content.updating(from: incomingMessageIntent) as! UNMutableNotificationContent
                    contentHandler(content)
                } catch {
                    contentHandler(bestAttemptContent)
                }
            } else {
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

}
