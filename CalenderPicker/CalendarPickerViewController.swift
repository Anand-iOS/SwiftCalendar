//
//  CalendarPickerViewController.swift
// 
//
//  Created by Anandhakumar on 1/13/21.
//  Copyright © 2021. All rights reserved.
//

import UIKit

class CalendarPickerViewController: UIViewController {

	// MARK: Views
	private lazy var dimmedBackgroundView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.white.withAlphaComponent(0.3)
		return view
	}()
	
	private lazy var collectionView: UICollectionView = {
		let layout = UICollectionViewFlowLayout()
		layout.minimumLineSpacing = 0
		layout.minimumInteritemSpacing = 0
		
		let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
		collectionView.isScrollEnabled = false
		collectionView.translatesAutoresizingMaskIntoConstraints = false
		return collectionView
	}()
	
	private lazy var headerView = CalendarPickerHeaderView { [weak self] in
		guard let self = self else { return }
		
		self.dismiss(animated: true)
	}
	
	private lazy var footerView = CalendarPickerFooterView(
		didTapLastMonthCompletionHandler: { [weak self] in
			guard let self = self else { return }
			
			self.baseDate = self.calendar.date(
				byAdding: .month,
				value: -1,
				to: self.baseDate
			) ?? self.baseDate
		},
		didTapNextMonthCompletionHandler: { [weak self] in
			guard let self = self else { return }
			
			self.baseDate = self.calendar.date(
				byAdding: .month,
				value: 1,
				to: self.baseDate
			) ?? self.baseDate
		})
	
	// MARK: Calendar Data Values
	
	private let selectedDate: Date
	private var baseDate: Date {
		didSet {
			days = generateDaysInMonth(for: baseDate)
			collectionView.reloadData()
			headerView.baseDate = baseDate
		}
	}
	
	private lazy var days = generateDaysInMonth(for: baseDate)
	
	private var numberOfWeeksInBaseDate: Int {
		calendar.range(of: .weekOfMonth, in: .month, for: baseDate)?.count ?? 0
	}
	
	private let selectedDateChanged: ((Date) -> Void)
	private let calendar = Calendar(identifier: .gregorian)
	
	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.locale = Locale.init(identifier: AppUtility.getLocale())
		dateFormatter.dateFormat = "d"
		return dateFormatter
	}()
	
	// MARK: Initializers
	
	init(baseDate: Date, selectedDateChanged: @escaping ((Date) -> Void)) {
		self.selectedDate = baseDate
		self.baseDate = baseDate
		self.selectedDateChanged = selectedDateChanged
		
		super.init(nibName: nil, bundle: nil)
		
		modalPresentationStyle = .overCurrentContext
		modalTransitionStyle = .crossDissolve
		definesPresentationContext = true
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: View Lifecycle
	
	override func viewDidLoad() {
		super.viewDidLoad()
		collectionView.backgroundColor = .groupTableViewBackground
		
		view.addSubview(dimmedBackgroundView)
		view.addSubview(collectionView)
		view.addSubview(headerView)
		view.addSubview(footerView)
		
		var constraints = [
			dimmedBackgroundView.leftAnchor.constraint(equalTo: view.leftAnchor),
			dimmedBackgroundView.rightAnchor.constraint(equalTo: view.rightAnchor),
			dimmedBackgroundView.topAnchor.constraint(equalTo: view.topAnchor),
			dimmedBackgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
		]
		
		constraints.append(contentsOf: [
			//1
			collectionView.leftAnchor.constraint(
				equalTo: view.readableContentGuide.leftAnchor),
			collectionView.rightAnchor.constraint(
				equalTo: view.readableContentGuide.rightAnchor),
			//2
			collectionView.centerYAnchor.constraint(
				equalTo: view.centerYAnchor,
				constant: 10),
			//3
			collectionView.heightAnchor.constraint(
				equalTo: view.heightAnchor,
				multiplier: 0.5)
		])
		
		constraints.append(contentsOf: [
			headerView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
			headerView.rightAnchor.constraint(equalTo: collectionView.rightAnchor),
			headerView.bottomAnchor.constraint(equalTo: collectionView.topAnchor),
			headerView.heightAnchor.constraint(equalToConstant: 85),
			
			footerView.leftAnchor.constraint(equalTo: collectionView.leftAnchor),
			footerView.rightAnchor.constraint(equalTo: collectionView.rightAnchor),
			footerView.topAnchor.constraint(equalTo: collectionView.bottomAnchor),
			footerView.heightAnchor.constraint(equalToConstant: 60)
		])
		
		NSLayoutConstraint.activate(constraints)
		
		collectionView.register(
			CalendarDateCollectionViewCell.self,
			forCellWithReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier
		)
		
		collectionView.dataSource = self
		collectionView.delegate = self
		headerView.baseDate = baseDate
	}
	
	override func viewWillTransition(
		to size: CGSize,
		with coordinator: UIViewControllerTransitionCoordinator
	) {
		super.viewWillTransition(to: size, with: coordinator)
		collectionView.reloadData()
	}
}

// MARK: - Day Generation
private extension CalendarPickerViewController {
	// 1
	func monthMetadata(for baseDate: Date) throws -> MonthMetadata {
		// 2
		guard
			let numberOfDaysInMonth = calendar.range(
				of: .day,
				in: .month,
				for: baseDate)?.count,
			let firstDayOfMonth = calendar.date(
				from: calendar.dateComponents([.year, .month], from: baseDate))
		else {
			// 3
			throw CalendarDataError.metadataGeneration
		}
		
		// 4
		let firstDayWeekday = calendar.component(.weekday, from: firstDayOfMonth)
		
		// 5
		return MonthMetadata(
			numberOfDays: numberOfDaysInMonth,
			firstDay: firstDayOfMonth,
			firstDayWeekday: firstDayWeekday)
	}
	
	// 1
	func generateDaysInMonth(for baseDate: Date) -> [Day] {
		// 2
		guard let metadata = try? monthMetadata(for: baseDate) else {
			preconditionFailure("An error occurred when generating the metadata for \(baseDate)")
		}
		
		let numberOfDaysInMonth = metadata.numberOfDays
		let offsetInInitialRow = metadata.firstDayWeekday
		let firstDayOfMonth = metadata.firstDay
		
		// 3
		var days: [Day] = (1..<(numberOfDaysInMonth + offsetInInitialRow))
			.map { day in
				// 4
				let isWithinDisplayedMonth = day >= offsetInInitialRow
				// 5
				let dayOffset =
					isWithinDisplayedMonth ?
					day - offsetInInitialRow :
					-(offsetInInitialRow - day)
				
				// 6
				return generateDay(
					offsetBy: dayOffset,
					for: firstDayOfMonth,
					isWithinDisplayedMonth: isWithinDisplayedMonth)
			}
		
		days += generateStartOfNextMonth(using: firstDayOfMonth)
		
		return days
	}
	
	// 7
	func generateDay(
		offsetBy dayOffset: Int,
		for baseDate: Date,
		isWithinDisplayedMonth: Bool
	) -> Day {
		let date = calendar.date(
			byAdding: .day,
			value: dayOffset,
			to: baseDate)
			?? baseDate
		
		return Day(
			date: date,
			number: dateFormatter.string(from: date),
			isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
			isWithinDisplayedMonth: isWithinDisplayedMonth
		)
	}
	
	// 1
	func generateStartOfNextMonth(
		using firstDayOfDisplayedMonth: Date
	) -> [Day] {
		// 2
		guard
			let lastDayInMonth = calendar.date(
				byAdding: DateComponents(month: 1, day: -1),
				to: firstDayOfDisplayedMonth)
		else {
			return []
		}
		
		// 3
		let additionalDays = 7 - calendar.component(.weekday, from: lastDayInMonth)
		guard additionalDays > 0 else {
			return []
		}
		
		// 4
		let days: [Day] = (1...additionalDays)
			.map {
				generateDay(
					offsetBy: $0,
					for: lastDayInMonth,
					isWithinDisplayedMonth: false)
			}
		
		return days
	}
	
	enum CalendarDataError: Error {
		case metadataGeneration
	}
}

// MARK: - UICollectionViewDataSource
extension CalendarPickerViewController: UICollectionViewDataSource {
	func collectionView(
		_ collectionView: UICollectionView,
		numberOfItemsInSection section: Int
	) -> Int {
		days.count
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		cellForItemAt indexPath: IndexPath
	) -> UICollectionViewCell {
		let day = days[indexPath.row]
		
		let cell = collectionView.dequeueReusableCell(
			withReuseIdentifier: CalendarDateCollectionViewCell.reuseIdentifier,
			for: indexPath) as! CalendarDateCollectionViewCell
		// swiftlint:disable:previous force_cast
		
		cell.day = day
		return cell
	}
}

// MARK: - UICollectionViewDelegateFlowLayout
extension CalendarPickerViewController: UICollectionViewDelegateFlowLayout {
	func collectionView(
		_ collectionView: UICollectionView,
		didSelectItemAt indexPath: IndexPath
	) {
		let day = days[indexPath.row]
		if day.date.compare(Date()) != .orderedAscending || calendar.isDate(day.date, inSameDayAs: Date()){
			selectedDateChanged(day.date)
			dismiss(animated: true, completion: nil)
		}
	}
	
	func collectionView(
		_ collectionView: UICollectionView,
		layout collectionViewLayout: UICollectionViewLayout,
		sizeForItemAt indexPath: IndexPath
	) -> CGSize {
		let width = Int(collectionView.frame.width / 7)
		let height = Int(collectionView.frame.height) / numberOfWeeksInBaseDate
		return CGSize(width: width, height: height)
	}

}
