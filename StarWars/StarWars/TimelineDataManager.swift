//
//  TimelineDataManager.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/10/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit
import CoreData

class TimelineDataManager {
	func loadData(withCompletion completionHandler: @escaping (_ data: Data?, _ repsonse: URLResponse?, _ error: Error?) -> ()) {
		let session = URLSession.shared
		let url = URL(string: "https://raw.githubusercontent.com/phunware/dev-interview-homework/master/feed.json")!
		let task = session.dataTask(with: url) { (data, response, error) in
			DispatchQueue.main.async {
				completionHandler(data, response, error)
			}
		}
		task.resume()
	}
}
