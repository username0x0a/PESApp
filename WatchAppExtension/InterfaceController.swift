//
//  InterfaceController.swift
//  watchapp Extension
//
//  Created by Michal Zelinka on 17/11/2020.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

	@IBOutlet var contentGroup: WKInterfaceGroup!
	@IBOutlet var nameLabel: WKInterfaceLabel!
	@IBOutlet var indexLabel: WKInterfaceLabel!

	override func awake(withContext context: Any?) {
		// Configure interface objects here.
	}

	var data: PESData? {
		didSet { refresh() }
	}

	func refresh() {
		guard let jmk = data?.data[.SouthMoravia] else {
			nameLabel.setText("No data")
			return
		}
		nameLabel.setText(jmk.name)
		indexLabel.setText("\(jmk.index)")
		if let color = PESRatingColor[jmk._rating] {
			contentGroup.setBackgroundColor(UIColor(rgb: color))
		}
	}

	override func willActivate() {
		PESManager.shared.checkDataUpdate { result in
			DispatchQueue.main.async {
				if case .success(let data) = result {
					self.data = data
				} else {
					self.data = nil
				}
			}
		}
	}

	override func didDeactivate() {
		// This method is called when watch view controller is no longer visible
	}

	override func didAppear() {
		super.didAppear()
		hideTime()
	}

	func hideTime() {

//		NSArray *views = [[[[[[[NSClassFromString(@"UIApplication") sharedApplication] keyWindow] rootViewController] viewControllers] firstObject] view] subviews];
//
//		for (NSObject *view in views)
//		{
//			if ([view isKindOfClass:NSClassFromString(@"SPFullScreenView")])
//			[[[view timeLabel] layer] setOpacity:0];
//		}
//	}

	}

}
