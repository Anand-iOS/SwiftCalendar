//
//  CalendarPickerHeaderView.swift
//  
//
//  Created by Anandhakumar on 1/13/21.
//  Copyright © 2021. All rights reserved.
//

import UIKit

class CalendarPickerHeaderView: LocalizationView {

	lazy var monthLabel: UILabel = {
		let label = UILabel()
		label.translatesAutoresizingMaskIntoConstraints = false
		label.font = .systemFont(ofSize: 26, weight: .bold)
		label.text = "Month"
//		label.accessibilityTraits = .header
		label.isAccessibilityElement = true
		return label
	}()
	
	lazy var closeButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		
		if #available(iOS 13.0, *) {
			let configuration = UIImage.SymbolConfiguration(scale: .large)
			let image = UIImage(systemName: "xmark.circle.fill", withConfiguration: configuration)
			button.setImage(image, for: .normal)
		} else {
			// Fallback on earlier versions
			let image = UIImage(named: "CancelViewBtn")
			button.setImage(image, for: .normal)
		}
		
		
		button.tintColor = .gray
		button.contentMode = .scaleAspectFill
		button.isUserInteractionEnabled = true
		button.isAccessibilityElement = true
		button.accessibilityLabel = "Close Picker"
		return button
	}()
	
	lazy var dayOfWeekStackView: UIStackView = {
		let stackView = UIStackView()
		stackView.translatesAutoresizingMaskIntoConstraints = false
		stackView.distribution = .fillEqually
		return stackView
	}()
	
	lazy var separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
		return view
	}()
	
	private lazy var dateFormatter: DateFormatter = {
		let dateFormatter = DateFormatter()
		dateFormatter.calendar = Calendar(identifier: .gregorian)
		dateFormatter.locale = Locale.init(identifier: AppUtility.getLocale())
		dateFormatter.dateFormat = "MMMM y"
		return dateFormatter
	}()
	
	var baseDate = Date() {
		didSet {
			monthLabel.text = dateFormatter.string(from: baseDate)
		}
	}
	
	var exitButtonTappedCompletionHandler: (() -> Void)
	
	init(exitButtonTappedCompletionHandler: @escaping (() -> Void)) {
		self.exitButtonTappedCompletionHandler = exitButtonTappedCompletionHandler
		
		super.init(frame: CGRect.zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		
		backgroundColor = .groupTableViewBackground
		
		layer.maskedCorners = [
			.layerMinXMinYCorner,
			.layerMaxXMinYCorner
		]
		if #available(iOS 13.0, *) {
			layer.cornerCurve = .continuous
		} else {
			// Fallback on earlier versions
		}
		layer.cornerRadius = 15
		
		addSubview(monthLabel)
		addSubview(closeButton)
		addSubview(dayOfWeekStackView)
		addSubview(separatorView)
		
		for dayNumber in 1...7 {
			let dayLabel = UILabel()
			dayLabel.font = .systemFont(ofSize: 12, weight: .bold)
			dayLabel.textColor = .gray
			dayLabel.textAlignment = .center
			dayLabel.text = dayOfWeekLetter(for: dayNumber)
			
			// VoiceOver users don't need to hear these days of the week read to them, nor do SwitchControl or Voice Control users need to select them
			// If fact, they get in the way!
			// When a VoiceOver user highlights a day of the month, the day of the week is read to them.
			// That method provides the same amount of context as this stack view does to visual users
			dayLabel.isAccessibilityElement = false
			dayOfWeekStackView.addArrangedSubview(dayLabel)
		}
		
		closeButton.addTarget(self, action: #selector(didTapExitButton), for: .touchUpInside)
	}
	
	@objc func didTapExitButton() {
		exitButtonTappedCompletionHandler()
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private func dayOfWeekLetter(for dayNumber: Int) -> String {
		switch dayNumber {
			case 1:
				return NSLocalizedString("day_label_sun", comment: "")
			case 2:
				return NSLocalizedString("day_label_mon", comment: "")
			case 3:
				return NSLocalizedString("day_label_tue", comment: "")
			case 4:
				return NSLocalizedString("day_label_wed", comment: "")
			case 5:
				return NSLocalizedString("day_label_thu", comment: "")
			case 6:
				return NSLocalizedString("day_label_fri", comment: "")
			case 7:
				return NSLocalizedString("day_label_sat", comment: "")
			default:
				return ""
		}
	}
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		NSLayoutConstraint.activate([
			monthLabel.topAnchor.constraint(equalTo: topAnchor, constant: 15),
			monthLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15),
			
			closeButton.centerYAnchor.constraint(equalTo: monthLabel.centerYAnchor),
			closeButton.heightAnchor.constraint(equalToConstant: 28),
			closeButton.widthAnchor.constraint(equalToConstant: 28),
			closeButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -15),
			
			dayOfWeekStackView.leftAnchor.constraint(equalTo: leftAnchor),
			dayOfWeekStackView.rightAnchor.constraint(equalTo: rightAnchor),
			dayOfWeekStackView.bottomAnchor.constraint(equalTo: separatorView.bottomAnchor, constant: -5),
			
			separatorView.leftAnchor.constraint(equalTo: leftAnchor),
			separatorView.rightAnchor.constraint(equalTo: rightAnchor),
			separatorView.bottomAnchor.constraint(equalTo: bottomAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: 1)
		])
	}
}
