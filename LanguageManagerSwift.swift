//
//  LanguageManagerSwift.swift
//
//
//  Created by Anandhakumar on 1/13/21.
//  Copyright © 2021. All rights reserved.
//

import UIKit

let ARABIC = "ar"
let ENG = "en"

class LanguageManagerSwift {
	
	static func getSelectedLanguage() -> String {
		if let userDefaults = getUserDefaults(), let language = userDefaults.object(forKey: "language") as? String{
			var selectedLanguage = language
			if language == "arb" || language == ARABIC {
				selectedLanguage = ARABIC
			}
			return selectedLanguage
		}else{
			return ARABIC
		}
	}
	
	private static func getUserDefaults() -> UserDefaults? {
		return UserDefaults(suiteName: "com.yoursuitename")
	}
	
	static func setLanguageAR(){
		UserDefaults.standard.set(["ar"], forKey: "AppleLanguages")
		UserDefaults.standard.synchronize()
		BundleSwift.setLanguage("ar")
		
		if let userDefault = getUserDefaults(){
			userDefault.set("ar",forKey: "language")
			userDefault.synchronize()
		}
	}
	
	static func setLanguageEN(){
		UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
		UserDefaults.standard.synchronize()
		BundleSwift.setLanguage("en")
		
		if let userDefault = getUserDefaults(){
			userDefault.set("en",forKey: "language")
			userDefault.synchronize()
		}
	}
}
