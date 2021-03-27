//
//  RegionSelectionController.swift
//  PES
//
//  Created by Michal Zelinka on 20/03/2021.
//

import WatchKit
import Foundation

class RegionSelectionController: WKInterfaceController {

	@IBOutlet var buttonsGroup: WKInterfaceGroup!
	@IBOutlet var czechiaButton: WKInterfaceButton!
	@IBOutlet var pragueButton: WKInterfaceButton!
	@IBOutlet var centralBohemiaButton: WKInterfaceButton!
	@IBOutlet var southBohemiaButton: WKInterfaceButton!
	@IBOutlet var pilsenButton: WKInterfaceButton!
	@IBOutlet var karlovyVaryButton: WKInterfaceButton!
	@IBOutlet var ustiButton: WKInterfaceButton!
	@IBOutlet var liberecButton: WKInterfaceButton!
	@IBOutlet var hradecKraloveButton: WKInterfaceButton!
	@IBOutlet var pardubiceButton: WKInterfaceButton!
	@IBOutlet var vysocinaButton: WKInterfaceButton!
	@IBOutlet var southMoraviaButton: WKInterfaceButton!
	@IBOutlet var olomoucButton: WKInterfaceButton!
	@IBOutlet var zlinButton: WKInterfaceButton!
	@IBOutlet var moraviaSilesiaButton: WKInterfaceButton!

	let regions = PESRegion.allCases

	override func awake(withContext context: Any?) { }

	@IBAction func czechiaButtonAction() { regionButtonAction(.Czechia) }
	@IBAction func pragueButtonAction() { regionButtonAction(.Prague) }
	@IBAction func centralBohemiaButtonAction() { regionButtonAction(.CentralBohemia) }
	@IBAction func southBohemiaButtonAction() { regionButtonAction(.SouthBohemia) }
	@IBAction func pilsenButtonAction() { regionButtonAction(.Pilsen) }
	@IBAction func karlovyVaryButtonAction() { regionButtonAction(.KarlovyVary) }
	@IBAction func ustiButtonAction() { regionButtonAction(.Usti) }
	@IBAction func liberecButtonAction() { regionButtonAction(.Liberec) }
	@IBAction func hradecKraloveButtonAction() { regionButtonAction(.HradecKralove) }
	@IBAction func pardubiceButtonAction() { regionButtonAction(.Pardubice) }
	@IBAction func vysocinaButtonAction() { regionButtonAction(.Vysocina) }
	@IBAction func southMoraviaButtonAction() { regionButtonAction(.SouthMoravia) }
	@IBAction func olomoucButtonAction() { regionButtonAction(.Olomouc) }
	@IBAction func zlinButtonAction() { regionButtonAction(.Zlin) }
	@IBAction func moraviaSilesiaButtonAction() { regionButtonAction(.MoraviaSilesia) }

	func regionButtonAction(_ region: PESRegion?) {
		PESManager.shared.regionSelection = region
		self.pop()
	}

	override func willActivate() {
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	override func didAppear() {
		super.didAppear()
	}

}
