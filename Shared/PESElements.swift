//
//  PESElements.swift
//  PESPES
//
//  Created by Michal Zelinka on 20/03/2021.
//

import Foundation

protocol PESElement {
	var id: PESRegion { get }
	var name: String { get }
	var index: Int { get }
	var rValue: Float { get }
	var _rating: PESRating { get }
}

enum PESError: Error {
	case dateParsing
	case dataParsing
}

enum PESRegion: String, Codable, CodingKey, CaseIterable {
	case Czechia        = "CZ000"
	case Prague         = "CZ010"
	case CentralBohemia = "CZ020"
	case SouthBohemia   = "CZ031"
	case Pilsen         = "CZ032"
	case KarlovyVary    = "CZ041"
	case Usti           = "CZ042"
	case Liberec        = "CZ051"
	case HradecKralove  = "CZ052"
	case Pardubice      = "CZ053"
	case Vysocina       = "CZ063"
	case SouthMoravia   = "CZ064"
	case Olomouc        = "CZ071"
	case Zlin           = "CZ072"
	case MoraviaSilesia = "CZ080"
}

enum PESRating: Int, Codable {
	case no1 = 1
	case no2 = 2
	case no3 = 3
	case no4 = 4
	case no5 = 5
}

struct PESData: PESElement, Codable {

	// MARK: Definition

	let id = PESRegion.Czechia
	let name = "Česko"
	let date: Date
	let index: Int
	let rValue: Float
	let _rating: PESRating
	let _ratings: [String: _Rating]
	let data: [PESRegion: Region]

	enum CodingKeys: String, CodingKey {
		case date
		case index
		case rValue = "r_value"
		case _rating
		case _ratings
		case data
	}

	struct _Rating: Codable {
		let minIndex: Int
		let maxIndex: Int
		let severity: Int

		enum CodingKeys: String, CodingKey {
			case minIndex = "min"
			case maxIndex = "max"
			case severity
		}
	}

	struct Region: PESElement, Codable {
		let id: PESRegion
		let name: String
		let index: Int
		let rValue: Float
		let _rating: PESRating

		enum CodingKeys: String, CodingKey {
			case id, name, index
			case rValue = "r_value"
			case _rating
		}
	}

	// MARK: Implementation

	static var dateFormatter: ISO8601DateFormatter = {
		var df = ISO8601DateFormatter()
		df.timeZone = TimeZone.current
		df.formatOptions = .withFullDate
		return df
	}()

	init(from decoder: Decoder) throws {
		let values = try decoder.container(keyedBy: CodingKeys.self)

		let dateString = try values.decode(String.self, forKey: .date)
		guard let parsedDate = Self.dateFormatter.date(from: dateString) else {
			throw PESError.dateParsing
		}
		date = parsedDate

		index = try values.decode(Int.self, forKey: .index)
		rValue = try values.decode(Float.self, forKey: .rValue)
		_rating = try values.decode(PESRating.self, forKey: ._rating)
		_ratings = try values.decode([String: _Rating].self, forKey: ._ratings)

		if let keyedData = try? values.decode([PESRegion.RawValue: Region].self, forKey: .data) {
			var niceData = [PESRegion: Region]()
			try keyedData.forEach { (key, value) in
				if let region = PESRegion(rawValue: key) {
					niceData[region] = value
				} else { throw PESError.dataParsing }
			}
			data = niceData
		} else { throw PESError.dataParsing }
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)

		try container.encode(Self.dateFormatter.string(from: date), forKey: .date)
		try container.encode(index, forKey: .index)
		try container.encode(rValue, forKey: .rValue)
		try container.encode(_rating, forKey: ._rating)
		try container.encode(_ratings, forKey: ._ratings)

		var uglyData = [String: Region]()
		data.forEach { (key, value) in
			uglyData[key.rawValue] = value
		}

		try container.encode(uglyData, forKey: .data)
	}

}
