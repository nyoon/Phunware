//
//  Image.swift
//  StarWars
//
//  Created by Nicholas Yoon on 11/9/16.
//  Copyright © 2016 nyoon. All rights reserved.
//

import UIKit

// Use url to get download image data and save to disk
extension URL {
	func downloadImageAndSave(withCompletion completionHandler: @escaping (_ data: Data?, _ repsonse: URLResponse?, _ error: Error?) -> ()) {
		print("Downloading image") // TODO: Maybe add spinner for fun
		getData { (data, response, error) in
			print("Retreived image")
			DispatchQueue.main.async {
				completionHandler(data, response, error)
			}
		}
	}
	
	private func getData(with completion: @escaping (_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Void) {
		let session = URLSession.shared
		let task = session.dataTask(with: self) {
			(data, response, error) in
			completion(data, response, error)
		}
		task.resume()
	}
}
