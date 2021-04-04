//
//  PESManager.swift
//  PES
//
//  Created by Michal Zelinka on 20/03/2021.
//

import Foundation

class PESManager {

	struct Constants {
		static let onlineURL = URL(string: "https://pes.misacek.net/pes.json")!
		static let fileName = "pes.json"
		static let regionSelectionDefaultKey = "RegionSelection"
		static let lastUpdateCheckDefaultKey = "LastUpdateCheck"
		#if DEBUG && targetEnvironment(simulator)
		static let updateGracePeriod = TimeInterval(2 * 60)
		#else
		static let updateGracePeriod = TimeInterval(15 * 60)
		#endif
	}

	static let shared = PESManager()

	var data: PESData?
	let dataLock = NSLock()

	var regionSelection: PESRegion? {
		didSet {
			let selection = regionSelection?.rawValue
			UserDefaults.standard.set(selection, forKey: Constants.regionSelectionDefaultKey)
		}
	}

	var dataFilePath: String = {
		NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first!
			+ "/" + Constants.fileName
	}()

	init() {
		loadSelection()
		loadDataFromDisk()
	}

	func loadSelection() {
		if let selection = UserDefaults.standard.string(forKey: Constants.regionSelectionDefaultKey) {
			regionSelection = PESRegion(rawValue: selection) ?? .Czechia
		}
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
		case alreadyUpToDate
		case tooSoon
		case noDataError
		case dataError
		case parsingError
	}

	typealias UpdateCompletion = (UpdateCheckResult) -> Void

	let session: URLSession = {
		let configuration = URLSessionConfiguration.default
		configuration.requestCachePolicy = .reloadIgnoringLocalCacheData
		return URLSession(configuration: configuration)
	}()

	let updateQueue = DispatchQueue(label: "Update Queue")
	let updateGroup = DispatchGroup()

	func checkDataUpdate(completion: @escaping UpdateCompletion) {

		let now = Date()
		let currentData = data

		if let currentData = currentData {
			let today = PESData.dateFormatter.string(from: now)
			let date = PESData.dateFormatter.string(from: currentData.date)
			if today == date { completion(.alreadyUpToDate); return }
		}

		updateQueue.sync {

			if let lastUpdate = UserDefaults.standard.object(forKey: Constants.lastUpdateCheckDefaultKey) as? Date {
				if now.timeIntervalSince(lastUpdate) <= Constants.updateGracePeriod {
					completion(.tooSoon); return
				}
			}

			UserDefaults.standard.setValue(now, forKey: Constants.lastUpdateCheckDefaultKey)

			updateGroup.enter()

			session.dataTask(with: Constants.onlineURL) { (data, resp, err) in

				defer { self.updateGroup.leave() }

				guard let data = data else { completion(.dataError); return }
				guard let pes = self.parseData(data) else { completion(.parsingError); return }
				guard pes.date != self.data?.date else { completion(.alreadyUpToDate); return }

				self.dataLock.lock()

				if pes.date != self.data?.date {
					self.data = pes
					self.saveDataToDisk(pes)
				}

				#if DEBUG && targetEnvironment(simulator)
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
