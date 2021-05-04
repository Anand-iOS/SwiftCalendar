//
//  AppUtility.swift
//  
//
//  Created by Anandhakumar on 1/13/21.
//  Copyright © 2021. All rights reserved.
//

import Foundation

class AppUtility {
	class func getLocale()->String {
		switch LanguageManagerSwift.getSelectedLanguage() {
			case ARABIC:
				return "ar_QA"
			default:
				return "en_US"
		}
	}
}
