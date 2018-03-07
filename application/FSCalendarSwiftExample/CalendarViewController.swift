//
//  DelegateAppearanceViewController.swift
//  FSCalendarSwiftExample
//
//  Created by dingwenchao on 30/12/2016.
//  Copyright © 2016 wenchao. All rights reserved.
//
// navbar color: #0CDB5E or rgb(12,219,94)

import UIKit
import Charts

class CalendarViewController: UIViewController, FSCalendarDataSource, FSCalendarDelegate, FSCalendarDelegateAppearance {
    
    fileprivate weak var calendar: FSCalendar!
    
    fileprivate let gregorian: Calendar = Calendar(identifier: .gregorian)
    fileprivate lazy var dateFormatter1: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd"
        return formatter
    }()
    fileprivate lazy var dateFormatter2: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter
    }()
    
    // need the date variables (year, month, day, activity(bool))
    let activityCompleted = ["2018/02/28": UIColor.green, "2018/03/01": UIColor.green,"2018/03/02": UIColor.green,"2018/03/04": UIColor.green, "2018/03/05": UIColor.green]
    
    let activityNotCompleted = ["2018/02/27": UIColor.red, "2018/03/03": UIColor.red, "2018/03/06": UIColor.red]
    
    override func loadView() {

        let view = UIView(frame: UIScreen.main.bounds)
        view.backgroundColor = UIColor.white
        self.view = view

        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 450 : 300
        let calendar = FSCalendar(frame: CGRect(x:0, y:64, width:self.view.bounds.size.width, height:height))
        calendar.dataSource = self
        calendar.delegate = self
        calendar.allowsMultipleSelection = false
        calendar.swipeToChooseGesture.isEnabled = true
        calendar.backgroundColor = UIColor.white
        calendar.firstWeekday = 2
//        calendar.appearance.caseOptions = [.headerUsesUpperCase,.weekdayUsesSingleUpperCase]
        self.view.addSubview(calendar)
        self.calendar = calendar
        let today = dateFormatter1.string(from: Date())
        calendar.select(self.dateFormatter1.date(from: today))
//        let todayItem = UIBarButtonItem(title: "Today", style: .plain, target: self, action: #selector(self.todayItemClicked(sender:)))
//        self.navigationItem.rightBarButtonItem = todayItem

        // For UITest
        self.calendar.accessibilityIdentifier = "calendar"

    }
    
    deinit {
        print("\(#function)")
    }
    
    @objc
    func todayItemClicked(sender: AnyObject) {
        self.calendar.setCurrentPage(Date(), animated: false)
    }
    
    func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
        return 0
    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventColorFor date: Date) -> UIColor? {
//        let dateString = self.dateFormatter2.string(from: date)
//        if self.activityCompleted.contains(dateString) {
//            return UIColor.green
//        }
//        return nil
//    }
//
//    private func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, eventDefaultColorsFor date: Date) -> UIColor? {
//        let key = self.dateFormatter2.string(from: date)
//        if self.activityNotCompleted.contains(key) {
//            return UIColor.red
//        }
//        return nil
//    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.activityCompleted[key] {
            return color
        }
        if let color = self.activityNotCompleted[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        if [8, 17, 21, 25].contains((self.gregorian.component(.day, from: date))) {
            return 0.0
        }
        return 1.0
    }
    
}
