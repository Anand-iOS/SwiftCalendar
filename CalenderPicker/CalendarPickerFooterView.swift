//
//  CalendarPickerFooterView.swift
// 
//
//  Created by Anandhakumar on 1/13/21.
//  Copyright © 2021. All rights reserved.
//

import UIKit

class CalendarPickerFooterView: LocalizationView {

	lazy var separatorView: UIView = {
		let view = UIView()
		view.translatesAutoresizingMaskIntoConstraints = false
		view.backgroundColor = UIColor.gray.withAlphaComponent(0.2)
		return view
	}()
	
	lazy var previousMonthButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
		button.titleLabel?.textAlignment = .left
		
		if #available(iOS 13.0, *) {
			var imageName = "chevron.right.circle.fill"
			if LanguageManagerSwift.getSelectedLanguage() == ENG {
				imageName = "chevron.left.circle.fill"
			}
			if let chevronImage = UIImage(systemName:imageName) {
				let attributedString = NSMutableAttributedString()
				let imageAttachment = NSTextAttachment(image: chevronImage)
//				attributedString.append(
//					NSAttributedString(attachment: imageAttachment)
//				)
				attributedString.append(
					NSAttributedString(string:" ")
				)
				attributedString.append(
					NSAttributedString(string:NSLocalizedString("Widget_previous", comment: ""))
				)
				button.setAttributedTitle(attributedString, for: .normal)
				button.titleLabel?.textColor = .label
			}
		} else {
			button.setTitle(NSLocalizedString("Widget_previous", comment: ""), for: .normal)
			button.setTitleColor(UIColor.gray, for: .normal)
		}
		
		
		button.addTarget(self, action: #selector(didTapPreviousMonthButton), for: .touchUpInside)
		return button
	}()
	
	lazy var nextMonthButton: UIButton = {
		let button = UIButton()
		button.translatesAutoresizingMaskIntoConstraints = false
		button.titleLabel?.font = .systemFont(ofSize: 17, weight: .medium)
		button.titleLabel?.textAlignment = .right
		
		if #available(iOS 13.0, *) {
			var imageName = "chevron.left.circle.fill"
			if LanguageManagerSwift.getSelectedLanguage() == ENG {
				imageName = "chevron.right.circle.fill"
			}
			if let chevronImage = UIImage(systemName: imageName) {
				let attributedString = NSMutableAttributedString(string: NSLocalizedString("Widget_next", comment: ""))
				attributedString.append(
					NSAttributedString(string:" ")
				)
//				let imageAttachment = NSTextAttachment(image: chevronImage)
//				attributedString.append(
//					NSAttributedString(attachment: imageAttachment)
//				)
				button.setAttributedTitle(attributedString, for: .normal)
				button.titleLabel?.textColor = .label
			}
		} else {
			button.setTitle(NSLocalizedString("Widget_next", comment: ""), for: .normal)
			button.setTitleColor(UIColor.gray, for: .normal)
		}
				
		button.addTarget(self, action: #selector(didTapNextMonthButton), for: .touchUpInside)
		return button
	}()
	
	let didTapLastMonthCompletionHandler: (() -> Void)
	let didTapNextMonthCompletionHandler: (() -> Void)
	
	init(
		didTapLastMonthCompletionHandler: @escaping (() -> Void),
		didTapNextMonthCompletionHandler: @escaping (() -> Void)
	) {
		self.didTapLastMonthCompletionHandler = didTapLastMonthCompletionHandler
		self.didTapNextMonthCompletionHandler = didTapNextMonthCompletionHandler
		
		super.init(frame: CGRect.zero)
		
		translatesAutoresizingMaskIntoConstraints = false
		backgroundColor = .groupTableViewBackground
		
		layer.maskedCorners = [
			.layerMinXMaxYCorner,
			.layerMaxXMaxYCorner
		]
		if #available(iOS 13.0, *) {
			layer.cornerCurve = .continuous
		} else {
			// Fallback on earlier versions
		}
		layer.cornerRadius = 15
		
		addSubview(separatorView)
		addSubview(previousMonthButton)
		addSubview(nextMonthButton)
	}
	
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	private var previousOrientation: UIDeviceOrientation = UIDevice.current.orientation
	
	override func layoutSubviews() {
		super.layoutSubviews()
		
		let smallDevice = UIScreen.main.bounds.width <= 350
		
		let fontPointSize: CGFloat = smallDevice ? 14 : 17
		
		previousMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
		nextMonthButton.titleLabel?.font = .systemFont(ofSize: fontPointSize, weight: .medium)
		
		NSLayoutConstraint.activate([
			separatorView.leftAnchor.constraint(equalTo: leftAnchor),
			separatorView.rightAnchor.constraint(equalTo: rightAnchor),
			separatorView.topAnchor.constraint(equalTo: topAnchor),
			separatorView.heightAnchor.constraint(equalToConstant: 1),
			
			previousMonthButton.leftAnchor.constraint(equalTo: leftAnchor, constant: 10),
			previousMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor),
			
			nextMonthButton.rightAnchor.constraint(equalTo: rightAnchor, constant: -10),
			nextMonthButton.centerYAnchor.constraint(equalTo: centerYAnchor)
		])
	}
	
	@objc func didTapPreviousMonthButton() {
		didTapLastMonthCompletionHandler()
	}
	
	@objc func didTapNextMonthButton() {
		didTapNextMonthCompletionHandler()
	}


}
