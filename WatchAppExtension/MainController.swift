//
//  MainController.swift
//  watchapp Extension
//
//  Created by Michal Zelinka on 17/11/2020.
//

import Foundation
import WatchKit
import ClockKit

class MainController: WKInterfaceController {

	@IBOutlet var contentGroup: WKInterfaceGroup!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var indexLabel: WKInterfaceLabel!

	override func awake(withContext context: Any?) {
		nameLabel.setText(nil)
		indexLabel.setText(nil)

		self.clearAllMenuItems()
		self.addMenuItem(with: .more, title: "Pick Region", action: #selector(pickRegionAction))
	}

	@objc func pickRegionAction() {
		self.presentController(withName: "RegionSelectionController", context: nil)
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
			nameLabel.setText("No data")
			indexLabel.setText(nil)
			contentGroup.setBackgroundColor(.darkGray)
			return
		}
		nameLabel.setText(PESRegionName[elm.id])
		indexLabel.setText("\(elm.index)")
		if let color = PESRatingColor[elm._rating] {
			contentGroup.setBackgroundColor(UIColor(rgb: color))
		}
	}

	func reloadComplications() {
		let server = CLKComplicationServer.sharedInstance()
		for complication in server.activeComplications ?? [] {
			server.reloadTimeline(for: complication)
		}

	}

	override func willActivate() {
		PESManager.shared.checkDataUpdate { result in
			DispatchQueue.main.async {
				if case .success(let data) = result {
					self.data = data
				} else if case .redundantError = result {
					self.data = PESManager.shared.data
				} else {
					self.data = nil
				}
			}
		}
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

}
