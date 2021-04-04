//
//  MainController.swift
//  PES
//
//  Created by Michal Zelinka on 17/11/2020.
//

import Foundation
import WatchKit
import ClockKit

class MainController: WKInterfaceController {

	@IBOutlet var contentGroup: WKInterfaceGroup!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var chanageLabel: WKInterfaceLabel!
	@IBOutlet var indexLabel: WKInterfaceLabel!
	@IBOutlet var outdatedIndicator: WKInterfaceGroup!

	override func awake(withContext context: Any?) {
		nameLabel.setText(nil)
		indexLabel.setText(nil)

		self.clearAllMenuItems()
		self.addMenuItem(with: .more,
		                title: NSLocalizedString("Pick Region", comment: "Menu item"),
		               action: #selector(pickRegionAction))
	}

	@objc func pickRegionAction() {
		self.pushController(withName: "RegionSelectionController", context: nil)
	}

	@IBAction
	func regionTitleTapped() {
		pickRegionAction()
	}

	var data: PESData? {
		didSet { refresh() }
	}

	func refresh() {
		let region = PESManager.shared.regionSelection ?? .Czechia

		var element: PESElement?

		if region == .Czechia {
			element = data
		} else {
			element = data?.data[region]
		}

		reloadComplications()

		guard let elm = element else {
			nameLabel.setText(NSLocalizedString("No data", comment: "View label"))
			chanageLabel.setHidden(true)
			indexLabel.setText(nil)
			contentGroup.setBackgroundColor(.darkGray)
			outdatedIndicator.setHidden(true)
			return
		}

		let todaysData = data?.isToday == true
		let alpha: CGFloat = todaysData ? 1 : 0.45
		let colorValue = PESRatingColor[elm._rating]!
		let color = UIColor(rgb: colorValue).withAlphaComponent(alpha)

		nameLabel.setText(PESRegionName[elm.id])
		chanageLabel.setHidden(region != .Czechia)
		indexLabel.setText("\(elm.index)")
		contentGroup.setBackgroundColor(color)
		outdatedIndicator.setHidden(todaysData)
	}

	func reloadComplications() {
		ComplicationController.reloadComplications()
	}

	override func willActivate() {
		PESManager.shared.checkDataUpdate { result in
			DispatchQueue.main.async {
				if case .success(let data) = result {
					self.data = data
				} else {
					self.data = PESManager.shared.data
				}
			}
		}
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

}
