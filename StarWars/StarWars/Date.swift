//
//  Date.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/9/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import Foundation

extension String {
	var date: Date {
		let dateFormatter = DateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-ddHH:mm:ss.SSS"
		dateFormatter.timeZone = TimeZone(secondsFromGMT: 0)

		let formattedTimestamp = self.components(separatedBy: CharacterSet(charactersIn: "TZ")).joined()
		
		return dateFormatter.date(from: formattedTimestamp)!
	}
}

extension Date {
	func formattedDate() -> String {
		let dateFormatter = DateFormatter()
		dateFormatter.dateStyle = .medium
		dateFormatter.timeStyle = .short
		dateFormatter.timeZone = TimeZone(secondsFromGMT: NSTimeZone.local.secondsFromGMT())
		let localDateString = dateFormatter.string(from: self)

		let characterSet = CharacterSet(charactersIn: ",")
		var dateStrings = localDateString.components(separatedBy: characterSet)
		dateStrings.insert(",", at: 1)
		dateStrings.insert(" at", at: 2)
		
		return dateStrings.reduce("", +)
	}
}
