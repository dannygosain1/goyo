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
    
    @IBOutlet weak var label: UILabel!
    
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
//    let activityCompleted = ["2018/02/28": UIColor(red:18/255,green:135/255,blue:57/255,alpha:1.0), "2018/03/01": UIColor(red:18/255,green:135/255,blue:57/255,alpha:1.0),"2018/03/02": UIColor(red:18/255,green:135/255,blue:57/255,alpha:1.0),"2018/03/04": UIColor(red:18/255,green:135/255,blue:57/255,alpha:1.0), "2018/03/05": UIColor(red:18/255,green:135/255,blue:57/255,alpha:1.0)]
//
//    let activityNotCompleted = ["2018/02/27": UIColor.black, "2018/03/03": UIColor.black, "2018/03/06": UIColor.black]
    
    let fillSelectionColors = ["2018/02/28": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0), "2018/03/01": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/02": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/04": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0), "2018/03/05": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/07": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/10": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/13": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/14": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0)] // activityCompleted
    
    let fillDefaultColors = ["2018/02/28": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0), "2018/03/01": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/02": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/04": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0), "2018/03/05": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/07": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/10": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/13": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0),"2018/03/14": UIColor(red:35/255,green:209/255,blue:93/255,alpha:1.0)] // activityCompleted
    
    let borderDefaultColors = ["2018/02/27": UIColor.black, "2018/03/03": UIColor.black, "2018/03/06": UIColor.black,"2018/03/09": UIColor.black,"2018/03/11": UIColor.black,"2018/03/12": UIColor.black] // activityNotCompleted
    
    let borderSelectionColors = ["2018/02/27": UIColor.black, "2018/03/03": UIColor.black, "2018/03/06": UIColor.black,"2018/03/09": UIColor.black,"2018/03/11": UIColor.black,"2018/03/12": UIColor.black, "2018/03/08": UIColor.black] // activityNotCompleted
    
    
    override func loadView() {
//        let view = UIView(frame: UIScreen.main.bounds)
        let rect = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 250)
        let view = UIView(frame: rect)
        view.backgroundColor = UIColor.white
        self.view = view

        let height: CGFloat = UIDevice.current.model.hasPrefix("iPad") ? 450 : 300
        let calendar = FSCalendar(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:height))
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
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillSelectionColors[key] {
            return color
        }
        return appearance.selectionColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.fillDefaultColors[key] {
            return color
        }
        return nil
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.borderDefaultColors[key] {
            return color
        }
        return appearance.borderDefaultColor
    }
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
        let key = self.dateFormatter1.string(from: date)
        if let color = self.borderSelectionColors[key] {
            return color
        }
        return appearance.borderSelectionColor
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
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderDefaultColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
//        if let color = self.activityCompleted[key] {
//            return color
//        }
//        if let color = self.activityNotCompleted[key] {
//            return color
//        }
//        return appearance.borderDefaultColor
//    }
    
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderSelectionColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
//        if let color = self.borderSelectionColors[key] {
//            return color
//        }
//        return appearance.borderSelectionColor
//    }
//
//    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillSelectionColorFor date: Date) -> UIColor? {
//        let key = self.dateFormatter1.string(from: date)
//        if let color = self.fillSelectionColors[key] {
//            return color
//        }
//        return appearance.selectionColor
//    }
    
    
    func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, borderRadiusFor date: Date) -> CGFloat {
        if [8, 17, 21, 25].contains((self.gregorian.component(.day, from: date))) {
            return 0.0
        }
        return 1.0
    }
    
}
