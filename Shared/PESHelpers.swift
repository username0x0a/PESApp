
import Foundation

let PESRegionShortcut: [PESRegion: String] = [
	.Country:        "ČR",
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
}

#endif
