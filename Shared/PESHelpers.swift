
import Foundation

let PESRegionShortcut: [PESRegion: String] = [
	.Czechia:        "ČR",
	.Prague:         "PH",
	.CentralBohemia: "SC",
	.SouthBohemia:   "JC",
	.Pilsen:         "PL",
	.KarlovyVary:    "KV",
	.Usti:           "UL",
	.Liberec:        "LI",
	.HradecKralove:  "HK",
	.Pardubice:      "PD",
	.Vysocina:       "VY",
	.SouthMoravia:   "JM",
	.Olomouc:        "OL",
	.Zlin:           "ZL",
	.MoraviaSilesia: "MS",
]

let PESRegionName: [PESRegion: String] = [
	.Czechia:        NSLocalizedString("Czechia", comment: "Region name"),
	.Prague:         NSLocalizedString("Prague", comment: "Region name"),
	.CentralBohemia: NSLocalizedString("Central Bohemia", comment: "Region name"),
	.SouthBohemia:   NSLocalizedString("South Bohemia", comment: "Region name"),
	.Pilsen:         NSLocalizedString("Pilsen", comment: "Region name"),
	.KarlovyVary:    NSLocalizedString("Karlovy Vary", comment: "Region name"),
	.Usti:           NSLocalizedString("Ustí nad Labem", comment: "Region name"),
	.Liberec:        NSLocalizedString("Liberec", comment: "Region name"),
	.HradecKralove:  NSLocalizedString("Hradec Králové", comment: "Region name"),
	.Pardubice:      NSLocalizedString("Pardubice", comment: "Region name"),
	.Vysocina:       NSLocalizedString("Vysočina", comment: "Region name"),
	.SouthMoravia:   NSLocalizedString("South Moravia", comment: "Region name"),
	.Olomouc:        NSLocalizedString("Olomouc", comment: "Region name"),
	.Zlin:           NSLocalizedString("Zlín", comment: "Region name"),
	.MoraviaSilesia: NSLocalizedString("Moravia-Silesia", comment: "Region name"),
]

let PESRatingColor: [PESRating: UInt] = [
	.no1: 0x58C169,
	.no2: 0xEAD046,
	.no3: 0xEA560D,
	.no4: 0xD01A31,
	.no5: 0x6648FF,
]

func PESRatingForIndex(_ index: Int) -> PESRating {
	if index >= 75 { return .no5 }
	if index >= 60 { return .no4 }
	if index >= 40 { return .no3 }
	if index >= 20 { return .no2 }
	return .no1
}

extension PESData {
	var isToday: Bool {
		let dataDate = Self.dateFormatter.string(from: date)
		let nowDate = Self.dateFormatter.string(from: Date())
		return dataDate == nowDate
	}
}

#if canImport(UIKit)
import UIKit
#endif

#if canImport(WatchKit)
import WatchKit
#endif

#if canImport(UIKit) || canImport(WatchKit)

extension UIColor {

	convenience public init(rgb: UInt, alpha: CGFloat = 1) {
		let red = CGFloat((rgb & 0xFF0000) >> 16) / 255
		let green = CGFloat((rgb & 0xFF00) >> 8) / 255
		let blue = CGFloat((rgb & 0xFF) >> 0) / 255
		self.init(red: red, green: green, blue: blue, alpha: alpha)
	}

	func adjusted(by step: CGFloat) -> UIColor {
		var r: CGFloat = 0; var g: CGFloat = 0
		var b: CGFloat = 0; var a: CGFloat = 0
		self.getRed(&r, green: &g, blue: &b, alpha: &a)
		r = max(0, min(r + step, 1))
		g = max(0, min(g + step, 1))
		b = max(0, min(b + step, 1))
		return .init(red: r, green: g, blue: b, alpha: a)
	}

}

#endif
