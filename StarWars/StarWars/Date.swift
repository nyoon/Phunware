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
		let formattedTimestamp = self.components(separatedBy: CharacterSet(charactersIn: "TZ")).joined()
		
		return dateFormatter.date(from: formattedTimestamp)!
	}
}
