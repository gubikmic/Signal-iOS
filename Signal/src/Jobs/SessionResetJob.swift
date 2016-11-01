//  Created by Michael Kirk on 10/31/16.
//  Copyright © 2016 Open Whisper Systems. All rights reserved.

import Foundation

@objc(OWSSessionResetJob)
class SessionResetJob: NSObject {

    let TAG = "SessionResetJob"

    let recipientId: String
    let thread: TSThread
    let storageManager: TSStorageManager

    required init(recipientId: String, thread: TSThread, storageManager: TSStorageManager) {
        self.thread = thread
        self.recipientId = recipientId
        self.storageManager = storageManager
    }

    func run() {
        Logger.info("\(TAG) Local user reset session.")
        storageManager.removeIdentityKey(forRecipient: recipientId)
        storageManager.deleteAllSessions(forContact: recipientId)

        TSInfoMessage(timestamp: NSDate.ows_millisecondTimeStamp(),
                      in: thread,
                      messageType: TSInfoMessageType.typeSessionDidEnd).save()
        
    }

    class func run(corruptedMessage: TSErrorMessage, contactThread: TSContactThread, storageManager: TSStorageManager) {
        let job = self.init(recipientId: contactThread.contactIdentifier(),
                            thread: contactThread,
                            storageManager: storageManager)
        job.run()
    }

    class func run(recipientId: String, thread: TSThread, storageManager: TSStorageManager) {
        let job = self.init(recipientId: recipientId, thread: thread, storageManager: storageManager)
        job.run()
    }
}
