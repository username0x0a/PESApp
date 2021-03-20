//
//  PESManager.swift
//  PESPES
//
//  Created by Michal Zelinka on 20/03/2021.
//

import Foundation

class PESManager {

	struct Constants {
		static let onlineURL = URL(string: "https://pes.misacek.net/pes.json")!
		static let fileName = "pes.json"
	}

	static let shared = PESManager()

	var data: PESData?
	let dataLock = NSLock()

	var dataFilePath: String = {
		NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
			+ "/" + Constants.fileName
	}()

	init() {
		loadDataFromDisk()
	}

	func loadDataFromDisk() {
		let path = dataFilePath
		if let data = FileManager.default.contents(atPath: path) {
			dataLock.lock()
			self.data = parseData(data)
			dataLock.unlock()
		}
	}

	func saveDataToDisk(_ data: PESData) {
		let path = dataFilePath
		if let cont = encodeData(data) {
			try? cont.write(to: URL(fileURLWithPath: path))
		}
	}

	func parseData(_ data: Data) -> PESData? {
		try? JSONDecoder().decode(PESData.self, from: data)
	}

	func encodeData(_ data: PESData) -> Data? {
		try? JSONEncoder().encode(data)
	}

	enum UpdateCheckResult {
		case success(PESData)
		case noDataError
		case dataError
		case parsingError
		case redundantError
	}

	typealias UpdateCompletion = (UpdateCheckResult) -> Void

	let session = URLSession(configuration: .default)

	func checkDataUpdate(completion: @escaping UpdateCompletion) {

		if let data = data {
			let dataDate = PESData.dateFormatter.string(from: data.date)
			let nowDate = PESData.dateFormatter.string(from: .init())
			if dataDate == nowDate { completion(.success(data)); return }
		}

		performDataUpdate(completion: completion)
	}

	let updateQueue = DispatchQueue(label: "Update Queue")
	let updateGroup = DispatchGroup()

	func performDataUpdate(completion: @escaping UpdateCompletion) {

		updateQueue.sync {

			updateGroup.enter()

			session.dataTask(with: Constants.onlineURL) { (data, resp, err) in

				defer { self.updateGroup.leave() }

				guard let data = data else { completion(.dataError); return }
				guard let pes = self.parseData(data) else { completion(.parsingError); return }
				guard pes.date != self.data?.date else { completion(.redundantError); return }

				self.dataLock.lock()

				if pes.date != self.data?.date {
					self.data = pes
					self.saveDataToDisk(pes)
				}

				#if DEBUG
				print("Stats for date \(pes.date):")
				print()

				print("\(pes.name): index \(pes.index) (R = \(pes.rValue))")
				print()

				pes.data.forEach { (key, value) in
					print("\(value.name): index \(value.index) (R = \(value.rValue))")
				}
				#endif

				self.dataLock.unlock()

				completion(.success(pes))

			}.resume()

			updateGroup.wait()
		}
	}
}
