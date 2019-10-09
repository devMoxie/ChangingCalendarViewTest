//
//  ViewController.swift
//  ChangingCalendarViewTest
//
//  Created by devMoxie on 10/8/19.
//  Copyright © 2019 devMoxie. All rights reserved.
//

import UIKit
import JTAppleCalendar

class DateCell: JTACDayCell {
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var monthYearLabel: UILabel!
}

class ViewController: UIViewController {

    @IBOutlet weak var segmentedControl: UISegmentedControl! {
        didSet {
            segmentedControl.selectedSegmentIndex = 2
        }
    }
    @IBOutlet weak var calendarView: JTACMonthView!
    
    let calendarDayCellID = "DateCell"
    var cellDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/yy"
        return formatter
    }()
    var selectedDate: Date = Date()
    var numCalendarRows: Int = 6
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calendarView.scrollToDate(Date(), animateScroll: false)
        calendarView.ibCalendarDelegate = self
        calendarView.ibCalendarDataSource = self
    }
    
    @IBAction func segmentDidChange(_ sender: Any) {
        switch segmentedControl.selectedSegmentIndex {
        case 0:
            numCalendarRows = 1
            calendarView.cellSize = calendarView.frame.width
        case 1:
            numCalendarRows = 1
            calendarView.cellSize = calendarView.frame.width / 5
        case 2:
            numCalendarRows = 6
            calendarView.cellSize = 0.0
        default:
            print("default")
        }
        
        calendarView.reloadData(withAnchor: selectedDate, completionHandler: nil)
    }
}

extension ViewController: JTACMonthViewDataSource {
    func configureCalendar(_ calendar: JTACMonthView) -> ConfigurationParameters {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy MM dd"
        let startDate = formatter.date(from: "2019 01 01")!
        let endDate = formatter.date(from: "2022 01 01")!
        
        if numCalendarRows == 6 {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           numberOfRows: numCalendarRows,
                                           generateInDates: .forAllMonths,
                                           generateOutDates: .tillEndOfRow)
        } else {
            return ConfigurationParameters(startDate: startDate,
                                           endDate: endDate,
                                           numberOfRows: numCalendarRows,
                                           generateInDates: .forFirstMonthOnly,
                                           generateOutDates: .off,
                                           hasStrictBoundaries: false)
        }

    }
}

// MARK: - JTACMonthViewDelegate

extension ViewController: JTACMonthViewDelegate {
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
         super.viewWillTransition(to: size, with: coordinator)

         let visibleDates = calendarView.visibleDates()
         calendarView.viewWillTransition(to: .zero, with: coordinator, anchorDate: visibleDates.monthDates.first?.date)
     }
    
    func calendar(_ calendar: JTACMonthView, willDisplay cell: JTACDayCell, forItemAt date: Date, cellState: CellState, indexPath: IndexPath) {
        
        if let cell = cell as? DateCell {
            cell.dateLabel.text = cellState.text
            setCellText(cell: cell, cellState: cellState)
        }
    }
    
    func calendar(_ calendar: JTACMonthView, cellForItemAt date: Date, cellState: CellState, indexPath: IndexPath) -> JTACDayCell {
        
        let cell = calendar.dequeueReusableJTAppleCell(withReuseIdentifier: calendarDayCellID, for: indexPath) as! DateCell
        
        self.calendar(calendar, willDisplay: cell, forItemAt: date, cellState: cellState, indexPath: indexPath)
        
        return cell
    }

    func setCellText(cell: JTACDayCell, cellState: CellState) {
        guard let cell = cell as? DateCell else { fatalError("Unable to configure cell") }
        cell.dateLabel.text = cellState.text
        cell.monthYearLabel.text = cellDateFormatter.string(from: cellState.date)
        
        // label color for in/out days and today
        if cellState.dateBelongsTo == .thisMonth {
            cell.dateLabel.textColor = UIColor.black
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize, weight: .regular)
        } else {
            cell.dateLabel.textColor = UIColor.gray
        }
        
        let today = Calendar.current.dateComponents([.day, .year, .month], from: Date())
        let cellDate = Calendar.current.dateComponents([.day, .year, .month], from: cellState.date)
        
        if today == cellDate {
            cell.dateLabel.textColor = .red
            cell.dateLabel.font = UIFont.systemFont(ofSize: cell.dateLabel.font.pointSize, weight: .heavy)
        }
    }

} /// JTACMonthViewDelegate


