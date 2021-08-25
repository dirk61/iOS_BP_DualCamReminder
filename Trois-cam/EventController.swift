//
//  EventController.swift
//  Trois-cam
//
//  Created by GIX on 2021/8/25.
//  Copyright © 2021 Joss Manger. All rights reserved.
//

import Foundation
import EventKit
class EventController{
    var store = EKEventStore()
    var isAdd:Bool
    
    init() {
        self.isAdd = false
        store.requestAccess(to: .reminder) { granted, error in
            // Handle the response to the request.
            
            let predicates = self.store.predicateForReminders(in: [self.store.defaultCalendarForNewReminders()!])
            self.store.fetchReminders(matching: predicates) { foundRemainder in
                for reminder in foundRemainder as! [EKReminder]{
                    print(reminder.title!)
                    if reminder.title! == "血压测量"
                    {
                     
                        self.isAdd = true
                    }
                    
                }
            }
        }
        sleep(1)
        print(self.isAdd)
        if (!self.isAdd)
        {
            self.addEvent(hour :8)
            self.addEvent(hour: 12)
            self.addEvent(hour: 17)
            self.addEvent(hour: 22)
            
        }
        
        
        
    }
    
    func addEvent(hour: Int){
        let calendar = store.defaultCalendarForNewReminders()!
        
        
        let newReminder = EKReminder(eventStore: store)
        newReminder.calendar = calendar
        newReminder.title = "血压测量"
        var dateComponents = DateComponents()
        dateComponents.year = 2021
        dateComponents.month = 8
        dateComponents.day = 26
        dateComponents.timeZone = TimeZone(abbreviation: "HKT") // Japan Standard Time
        dateComponents.hour = hour
        dateComponents.minute = 0
        
        // Create date from components
        let userCalendar = Calendar(identifier: .gregorian) // since the components above (like year 1980) are for Gregorian
        let someDateTime = userCalendar.date(from: dateComponents)
        
        //        let dueDate = Date().addingTimeInterval(120)
        newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: someDateTime!)
        newReminder.addRecurrenceRule(EKRecurrenceRule(recurrenceWith: .daily, interval: 1, end: nil))
        //        newReminder.addAlarm(EKAlarm(relativeOffset: TimeInterval(-60)))
        newReminder.addAlarm(EKAlarm(relativeOffset: TimeInterval(0)))
        
        newReminder.priority = Int(EKReminderPriority.high.rawValue)
        newReminder.notes = "请开始血压测量，并且打开app进行视频录制"
        
        try! store.save(newReminder, commit: true)
    }
}
